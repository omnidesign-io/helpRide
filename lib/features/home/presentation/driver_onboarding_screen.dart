import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpride/features/home/repository/user_repository.dart';
import 'package:helpride/core/presentation/counter_input_widget.dart';
import 'package:helpride/features/rides/presentation/vehicle_selection_screen.dart';
import 'package:helpride/features/rides/domain/ride_options.dart';
import 'package:helpride/features/rides/domain/vehicle_type.dart';
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
  VehicleType? _vehicleType;
  final _vehicleColorController = TextEditingController();
  final _licensePlateController = TextEditingController();
  int _capacity = 4;
  
  // Conditions
  bool _acceptPets = false;
  bool _acceptWheelchair = false;
  bool _acceptCargo = false;

  @override
  void dispose() {
    _vehicleColorController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_vehicleType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.selectVehicleTypeError)),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final vehicleData = {
        'type': _vehicleType.toString().split('.').last,
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
    return Scaffold(
      appBar: AppBar(
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
              child: ListTile(
                title: Text(l10n.vehicleTypeLabel),
                subtitle: Text(_vehicleType?.localized(context) ?? l10n.selectVehicleLabel),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final currentOptions = _vehicleType != null ? RideOptions(vehicleType: _vehicleType!) : null;
                  final result = await Navigator.of(context).push<RideOptions>(
                    MaterialPageRoute(
                      builder: (_) => VehicleSelectionScreen(currentOptions: currentOptions),
                    ),
                  );
                  if (result != null) {
                    setState(() => _vehicleType = result.vehicleType);
                  }
                },
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
                      decoration: InputDecoration(
                        labelText: l10n.vehicleColorLabel,
                        hintText: l10n.vehicleColorHint,
                        prefixIcon: Icon(Icons.color_lens),
                      ),
                      validator: (val) => val == null || val.isEmpty ? l10n.enterColorError : null,
                    ),
                    const SizedBox(height: 16),

                    // License Plate
                    TextFormField(
                      controller: _licensePlateController,
                      maxLength: 20,
                      decoration: InputDecoration(
                        labelText: l10n.licensePlateLabel,
                        prefixIcon: Icon(Icons.confirmation_number),
                        helperText: l10n.licensePlateHelper,
                        helperMaxLines: 2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Capacity
                    CounterInputWidget(
                      label: l10n.capacityLabel,
                      value: _capacity,
                      onChanged: (val) => setState(() => _capacity = val),
                      min: 1,
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
