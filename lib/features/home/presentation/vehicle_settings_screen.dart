import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpride/features/home/repository/user_repository.dart';
import 'package:helpride/features/rides/repository/ride_repository.dart';
import 'package:helpride/core/presentation/counter_input_widget.dart';
import 'package:helpride/features/rides/presentation/vehicle_selection_screen.dart';
import 'package:helpride/features/rides/domain/ride_options.dart';
import 'package:helpride/features/rides/domain/vehicle_type.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:helpride/core/providers/session_provider.dart';

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
  VehicleType? _vehicleType;
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
        _vehicleType = VehicleType.values.firstWhere(
          (e) => e.toString().split('.').last == vehicle['type'],
          orElse: () => VehicleType.sedan,
        );
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

    if (_vehicleType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle type')),
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
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Settings'),
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
                  child: ListTile(
                    title: const Text('Vehicle Type'),
                    subtitle: Text(_vehicleType?.localized(context) ?? 'Select Type'),
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
                          decoration: const InputDecoration(
                            labelText: 'Vehicle Color',
                            hintText: 'e.g. White',
                            prefixIcon: Icon(Icons.color_lens),
                          ),
                          validator: (val) => val == null || val.isEmpty ? 'Please enter a color' : null,
                        ),
                        const SizedBox(height: 16),

                        // License Plate
                        TextFormField(
                          controller: _licensePlateController,
                          maxLength: 20,
                          decoration: const InputDecoration(
                            labelText: 'License Plate (Optional)',
                            prefixIcon: Icon(Icons.confirmation_number),
                            helperText: 'For privacy, you may enter only part of the plate (e.g., numbers only).',
                            helperMaxLines: 2,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Capacity
                        CounterInputWidget(
                          label: 'Capacity (excluding driver)',
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
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
    );
  }
}
