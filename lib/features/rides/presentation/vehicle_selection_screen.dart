import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:helpride/features/rides/domain/ride_options.dart';
import 'package:helpride/features/rides/domain/vehicle_type.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:helpride/features/rides/presentation/vehicle_type_list_view.dart';
import 'package:helpride/core/presentation/counter_input_widget.dart';

class VehicleSelectionScreen extends StatefulWidget {
  final RideOptions? currentOptions;

  const VehicleSelectionScreen({super.key, this.currentOptions});

  @override
  State<VehicleSelectionScreen> createState() => _VehicleSelectionScreenState();
}

class _VehicleSelectionScreenState extends State<VehicleSelectionScreen> {
  late VehicleType _selectedType;
  late int _passengerCount;
  late bool _acceptPets;
  late bool _acceptWheelchair;
  late bool _acceptCargo;

  @override
  void initState() {
    super.initState();
    final options = widget.currentOptions ?? const RideOptions(vehicleType: VehicleType.sedan);
    _selectedType = options.vehicleType;
    _passengerCount = options.passengerCount;
    _acceptPets = options.acceptPets;
    _acceptWheelchair = options.acceptWheelchair;
    _acceptCargo = options.acceptCargo;
  }

  void _submit() {
    final options = RideOptions(
      vehicleType: _selectedType,
      passengerCount: _passengerCount,
      acceptPets: _acceptPets,
      acceptWheelchair: _acceptWheelchair,
      acceptCargo: _acceptCargo,
    );
    context.pop(options);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.rideOptionsTitle),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(l10n.saveButton),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Vehicle Type Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.vehicleTypeLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 300, // Fixed height for the list
                    child: VehicleTypeListView(
                      selectedType: _selectedType,
                      onSelected: (type) {
                        setState(() {
                          _selectedType = type;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Passenger Count Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.passengerCountLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  CounterInputWidget(
                    label: l10n.passengerCountLabel,
                    value: _passengerCount,
                    onChanged: (val) => setState(() => _passengerCount = val),
                    min: 0, // Allow 0 for goods-only
                    max: 10,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Conditions Section
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      l10n.conditionsLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SwitchListTile(
                    title: Text(l10n.conditionPets),
                    secondary: const Icon(Icons.pets),
                    value: _acceptPets,
                    onChanged: (val) => setState(() => _acceptPets = val),
                  ),
                  SwitchListTile(
                    title: Text(l10n.conditionWheelchair),
                    secondary: const Icon(Icons.accessible),
                    value: _acceptWheelchair,
                    onChanged: (val) => setState(() => _acceptWheelchair = val),
                  ),
                  SwitchListTile(
                    title: Text(l10n.conditionCargo),
                    secondary: const Icon(Icons.luggage),
                    value: _acceptCargo,
                    onChanged: (val) => setState(() => _acceptCargo = val),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.saveButton),
          ),
        ],
      ),
    );
  }
}
