import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpride/features/home/repository/user_repository.dart';
import 'package:helpride/core/presentation/counter_input_widget.dart';
import 'package:helpride/features/rides/presentation/widgets/vehicle_type_selector.dart';
import 'package:helpride/features/rides/domain/ride_options.dart';

import 'package:helpride/features/rides/repository/vehicle_type_repository.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:helpride/core/providers/session_provider.dart';

class DriverOnboardingScreen extends ConsumerStatefulWidget {
  const DriverOnboardingScreen({super.key});

  @override
  ConsumerState<DriverOnboardingScreen> createState() => _DriverOnboardingScreenState();
}

class _DriverOnboardingScreenState extends ConsumerState<DriverOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form Fields
  String? _vehicleTypeId;
  final _vehicleColorController = TextEditingController();
  final _licensePlateController = TextEditingController();
  int _capacity = 4;
  
  // Conditions
  bool _acceptPets = false;
  bool _acceptWheelchair = false;
  bool _acceptCargo = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final session = ref.read(sessionProvider);
    if (session == null) return;

    try {
      final userDoc = await ref.read(userRepositoryProvider).getUser(session.uid);
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        if (data.containsKey('vehicle')) {
          final vehicle = data['vehicle'] as Map<String, dynamic>;
          
          setState(() {
            // Parse Vehicle Type ID
            _vehicleTypeId = vehicle['type'] as String?;
            
            _vehicleColorController.text = vehicle['color'] ?? '';
            _licensePlateController.text = vehicle['licensePlate'] ?? '';
            _capacity = vehicle['capacity'] ?? 4;
            
            if (vehicle.containsKey('conditions')) {
              final conditions = vehicle['conditions'] as Map<String, dynamic>;
              _acceptPets = conditions['pets'] ?? false;
              _acceptWheelchair = conditions['wheelchair'] ?? false;
              _acceptCargo = conditions['cargo'] ?? false;
            }
          });
        }
      }
    } catch (e) {
      // Ignore errors, just start fresh
    }
  }

  @override
  void dispose() {
    _vehicleColorController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_vehicleTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.selectVehicleTypeError)),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final vehicleData = {
        'type': _vehicleTypeId,
        'color': _vehicleColorController.text.trim(),
        'licensePlate': _licensePlateController.text.trim(),
        'capacity': _capacity,
        'conditions': {
          'pets': _acceptPets,
          'wheelchair': _acceptWheelchair,
          'cargo': _acceptCargo,
        },
      };

      try {
        final session = ref.read(sessionProvider);
        if (session != null) {
          await ref.read(userRepositoryProvider).updateUserVehicle(
            session.uid,
            vehicleData,
          );
          
          if (mounted) {
            context.pop(true); // Return success
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context)!.saveError}$e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vehicleTypesAsync = ref.watch(vehicleTypesProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.driverSetupTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.vehicleDetailsTitle,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.vehicleDetailsSubtitle,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Vehicle Type
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.vehicleTypeLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    VehicleTypeSelector(
                      selectedTypeIds: _vehicleTypeId != null ? [_vehicleTypeId!] : [],
                      multiSelect: false,
                      onChanged: (ids) {
                        setState(() {
                          _vehicleTypeId = ids.firstOrNull;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Vehicle Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Vehicle Color
                    TextFormField(
                      controller: _vehicleColorController,
                      maxLength: 10,
                      decoration: InputDecoration(
                        labelText: l10n.vehicleColorLabel,
                        hintText: l10n.vehicleColorHint,
                        prefixIcon: const Icon(Icons.color_lens),
                      ),
                      validator: (val) => val == null || val.isEmpty ? l10n.enterColorError : null,
                    ),
                    const SizedBox(height: 16),

                    // License Plate
                    TextFormField(
                      controller: _licensePlateController,
                      maxLength: 8,
                      decoration: InputDecoration(
                        labelText: l10n.licensePlateLabel,
                        prefixIcon: const Icon(Icons.confirmation_number),
                        helperText: l10n.licensePlateHelper,
                        helperMaxLines: 2,
                      ),
                      validator: (val) => val == null || val.isEmpty ? l10n.enterLicensePlateError : null,
                    ),
                    const SizedBox(height: 16),

                    // Capacity
                    CounterInputWidget(
                      label: l10n.capacityLabel,
                      value: _capacity,
                      onChanged: (val) => setState(() => _capacity = val),
                      min: 0,
                      max: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              l10n.conditionsTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(l10n.acceptPetsLabel),
                    secondary: const Icon(Icons.pets),
                    value: _acceptPets,
                    onChanged: (val) => setState(() => _acceptPets = val),
                  ),
                  SwitchListTile(
                    title: Text(l10n.acceptWheelchairsLabel),
                    secondary: const Icon(Icons.accessible),
                    value: _acceptWheelchair,
                    onChanged: (val) => setState(() => _acceptWheelchair = val),
                  ),
                  SwitchListTile(
                    title: Text(l10n.acceptCargoLabel),
                    secondary: const Icon(Icons.luggage),
                    value: _acceptCargo,
                    onChanged: (val) => setState(() => _acceptCargo = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(false), // Cancel
                    child: Text(l10n.cancelButton),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(l10n.saveAndContinueButton),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
