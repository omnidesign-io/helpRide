import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpride/features/rides/repository/vehicle_type_repository.dart';

class VehicleTypeSelector extends ConsumerWidget {
  final List<String> selectedTypeIds;
  final Function(List<String>) onChanged;
  final bool multiSelect;

  const VehicleTypeSelector({
    super.key,
    required this.selectedTypeIds,
    required this.onChanged,
    this.multiSelect = false,
  });

  IconData _getIcon(String iconCode) {
    switch (iconCode) {
      case 'directions_car':
        return Icons.directions_car;
      case 'airport_shuttle':
        return Icons.airport_shuttle;
      case 'directions_car_filled':
        return Icons.directions_car_filled;
      case 'two_wheeler':
        return Icons.two_wheeler;
      case 'accessible':
        return Icons.accessible;
      case 'pedal_bike':
        return Icons.pedal_bike;
      case 'local_taxi':
        return Icons.local_taxi;
      case 'local_shipping':
        return Icons.local_shipping;
      default:
        return Icons.directions_car;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleTypesAsync = ref.watch(vehicleTypesProvider);

    return vehicleTypesAsync.when(
      data: (types) {
        if (types.isEmpty) {
          return const Center(child: Text('No vehicle types available'));
        }
        
        // Handle default selection if nothing selected and not multi-select
        // Note: This is a bit tricky in a build method, ideally should be done in parent or state init
        // But for display purposes, we just render. The parent needs to handle the initial state.
        
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: types.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final type = types[index];
            final isSelected = selectedTypeIds.contains(type.id);
            final isZh = Localizations.localeOf(context).languageCode == 'zh';
            final name = isZh ? type.nameZh : type.nameEn;
            final description = isZh ? type.descriptionZh : type.descriptionEn;

            return InkWell(
              onTap: () {
                if (multiSelect) {
                  final newSelection = List<String>.from(selectedTypeIds);
                  if (isSelected) {
                    newSelection.remove(type.id);
                  } else {
                    newSelection.add(type.id);
                  }
                  onChanged(newSelection);
                } else {
                  onChanged([type.id]);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                      : const Color(0xFFF2F2F2),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIcon(type.iconCode),
                      size: 32,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                          ),
                          if (description.isNotEmpty)
                            Text(
                              description,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
