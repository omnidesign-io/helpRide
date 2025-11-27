import 'package:flutter/material.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';

enum VehicleType {
  sedan,
  van,
  suv,
  motorcycle,
  accessibleVan,
}

extension VehicleTypeExtension on VehicleType {
  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case VehicleType.sedan:
        return l10n.vehicleTypeSedan;
      case VehicleType.van:
        return l10n.vehicleTypeVan;
      case VehicleType.suv:
        return l10n.vehicleTypeSUV;
      case VehicleType.motorcycle:
        return l10n.vehicleTypeMotorcycle;
      case VehicleType.accessibleVan:
        return l10n.vehicleTypeAccessibleVan;
    }
  }

  IconData get icon {
    switch (this) {
      case VehicleType.sedan:
        return Icons.directions_car;
      case VehicleType.van:
        return Icons.airport_shuttle;
      case VehicleType.suv:
        return Icons.directions_car_filled;
      case VehicleType.motorcycle:
        return Icons.two_wheeler;
      case VehicleType.accessibleVan:
        return Icons.accessible;
    }
  }
}
