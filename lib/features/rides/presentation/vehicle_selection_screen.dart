import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:helpride/features/rides/presentation/vehicle_type_list_view.dart';
import 'package:helpride/features/rides/domain/vehicle_type.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';

class VehicleSelectionScreen extends StatelessWidget {
  final VehicleType? currentSelection;

  const VehicleSelectionScreen({super.key, this.currentSelection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.selectVehicleTypeTitle)),
      body: VehicleTypeListView(
        selectedType: currentSelection,
        onSelected: (type) {
          context.pop(type);
        },
      ),
    );
  }
}
