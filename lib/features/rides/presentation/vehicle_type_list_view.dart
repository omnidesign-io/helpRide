import 'package:flutter/material.dart';

import 'package:helpride/features/rides/domain/vehicle_type.dart';

class VehicleTypeListView extends StatelessWidget {
  final VehicleType? selectedType;
  final ValueChanged<VehicleType> onSelected;

  const VehicleTypeListView({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: VehicleType.values.length,
      itemBuilder: (context, index) {
        final type = VehicleType.values[index];
        final isSelected = type == selectedType;

        return ListTile(
          title: Text(type.localized(context)),
          leading: Icon(
            type.icon,
            color: isSelected ? Theme.of(context).primaryColor : null,
          ),
          trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
          selected: isSelected,
          onTap: () => onSelected(type),
        );
      },
    );
  }
}
