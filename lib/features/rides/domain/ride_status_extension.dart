import 'package:helpride/features/rides/domain/ride_model.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

extension RideStatusExtension on RideStatus {
  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case RideStatus.pending:
        return l10n.rideStatusPending;
      case RideStatus.accepted:
        return l10n.rideStatusAccepted;
      case RideStatus.arrived:
        return l10n.rideStatusArrived;
      case RideStatus.riding:
        return l10n.rideStatusRiding;
      case RideStatus.completed:
        return l10n.rideStatusCompleted;
      case RideStatus.cancelled:
        return l10n.rideStatusCancelled;
    }
  }
}
