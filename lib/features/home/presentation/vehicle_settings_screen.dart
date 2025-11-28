import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpride/features/home/repository/user_repository.dart';
import 'package:helpride/features/rides/repository/ride_repository.dart';
import 'package:helpride/core/presentation/counter_input_widget.dart';
import 'package:helpride/features/rides/presentation/widgets/vehicle_type_selector.dart';
import 'package:helpride/features/rides/repository/vehicle_type_repository.dart';
import 'package:helpride/core/providers/session_provider.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';

class VehicleSettingsScreen extends ConsumerStatefulWidget {
  const VehicleSettingsScreen({super.key});

  @override
  ConsumerState<VehicleSettingsScreen> createState() => _VehicleSettingsScreenState();
}

class _VehicleSettingsScreenState extends ConsumerState<VehicleSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _hasActiveRide = false;
  
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
    _loadData();
  }

  Future<void> _loadData() async {
    final session = ref.read(sessionProvider);
    if (session == null) return;

    // Check for active ride first
    final activeRides = await ref.read(rideRepositoryProvider).streamRiderRides(session.uid).first;
    _hasActiveRide = activeRides.any((r) => r.isActive);

    // Load User Data
    final userDoc = await ref.read(userRepositoryProvider).getUser(session.uid);
    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      final vehicle = data['vehicle'] as Map<String, dynamic>?;
      
      if (vehicle != null) {
        _vehicleTypeId = vehicle['type'] as String?;
        _vehicleColorController.text = vehicle['color'] ?? '';
        _licensePlateController.text = vehicle['licensePlate'] ?? '';
        _capacity = vehicle['capacity'] ?? 4;
        
        final conditions = vehicle['conditions'] as Map<String, dynamic>?;
        if (conditions != null) {
          _acceptPets = conditions['pets'] ?? false;
          _acceptWheelchair = conditions['wheelchair'] ?? false;
          _acceptCargo = conditions['cargo'] ?? false;
        }
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _vehicleColorController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_hasActiveRide) return; // Double check

    if (_vehicleTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle type')),
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vehicle settings updated!')),
            );
            Navigator.of(context).pop();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving details: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Vehicle Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: 'Seed Default Types',
            onPressed: () async {
              try {
                await ref.read(vehicleTypeRepositoryProvider).seedDefaultTypes();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vehicle types seeded successfully!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error seeding types: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: _hasActiveRide 
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'You cannot edit vehicle settings while you have an active ride. Please complete your ride first.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          )
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Vehicle Type
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vehicle Type',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                          label: 'Capacity (excluding driver)',
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

                const Text(
                  'Conditions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Accept Pets?'),
                        secondary: const Icon(Icons.pets),
                        value: _acceptPets,
                        onChanged: (val) => setState(() => _acceptPets = val),
                      ),
                      SwitchListTile(
                        title: const Text('Accept Wheelchairs?'),
                        secondary: const Icon(Icons.accessible),
                        value: _acceptWheelchair,
                        onChanged: (val) => setState(() => _acceptWheelchair = val),
                      ),
                      SwitchListTile(
                        title: const Text('Accept Cargo/Luggage?'),
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
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Save Changes'),
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
