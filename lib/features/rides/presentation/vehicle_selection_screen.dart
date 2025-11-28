import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:helpride/features/rides/presentation/widgets/vehicle_type_selector.dart';
import 'package:helpride/features/rides/presentation/providers/ride_request_provider.dart';
import 'package:helpride/core/presentation/counter_input_widget.dart';

class VehicleSelectionScreen extends ConsumerWidget {
  const VehicleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final rideOptions = ref.watch(rideRequestProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.rideOptionsTitle),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
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
                  Row(
                    children: [
                      Text(
                        l10n.vehicleTypeLabel,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.multipleChoicesPossible,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  VehicleTypeSelector(
                    selectedTypeIds: rideOptions.vehicleTypeIds,
                    multiSelect: true, // Riders can select multiple
                    onChanged: (ids) {
                      ref.read(rideRequestProvider.notifier).state = rideOptions.copyWith(vehicleTypeIds: ids);
                    },
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
                    value: rideOptions.passengerCount,
                    onChanged: (val) {
                      ref.read(rideRequestProvider.notifier).state = rideOptions.copyWith(passengerCount: val);
                    },
                    min: 0,
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
                    value: rideOptions.acceptPets,
                    onChanged: (val) {
                      ref.read(rideRequestProvider.notifier).state = rideOptions.copyWith(acceptPets: val);
                    },
                  ),
                  SwitchListTile(
                    title: Text(l10n.conditionWheelchair),
                    secondary: const Icon(Icons.accessible),
                    value: rideOptions.acceptWheelchair,
                    onChanged: (val) {
                      ref.read(rideRequestProvider.notifier).state = rideOptions.copyWith(acceptWheelchair: val);
                    },
                  ),
                  SwitchListTile(
                    title: Text(l10n.conditionCargo),
                    secondary: const Icon(Icons.luggage),
                    value: rideOptions.acceptCargo,
                    onChanged: (val) {
                      ref.read(rideRequestProvider.notifier).state = rideOptions.copyWith(acceptCargo: val);
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.pop(),
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
