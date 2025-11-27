import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpride/features/rides/domain/ride_model.dart';
import 'package:helpride/features/rides/repository/ride_repository.dart';
import 'package:helpride/features/rides/domain/ride_status_extension.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:helpride/features/rides/domain/vehicle_type.dart';
import 'package:intl/intl.dart';

class RideDetailsScreen extends ConsumerWidget {
  final String rideId;

  const RideDetailsScreen({super.key, required this.rideId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final rideAsync = ref.watch(rideStreamProvider(rideId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.rideDetailsTitle),
      ),
      body: rideAsync.when(
        data: (ride) {
          final isActive = ride.isActive;
          final canCancel = ride.status == RideStatus.pending ||
              ride.status == RideStatus.accepted ||
              ride.status == RideStatus.arrived;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Ride #${ride.shortId}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(ride.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _getStatusColor(ride.status)),
                        ),
                        child: Text(
                          ride.status.localized(context),
                          style: TextStyle(
                            color: _getStatusColor(ride.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Origin -> Destination
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.originLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
                                Text(ride.pickupAddress, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(Icons.arrow_forward, color: Colors.grey),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(l10n.destinationLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
                                Text(ride.destinationAddress, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Color.fromRGBO(0, 0, 0, 0.12)),
                      _buildDetailRow(context, Icons.calendar_today, l10n.dateLabel, DateFormat('yyyy-MM-dd HH:mm').format(ride.createdAt)),
                      const Divider(color: Color.fromRGBO(0, 0, 0, 0.12)),
                      _buildDetailRow(context, Icons.directions_car, l10n.vehicleTypeLabel, ride.vehicleType.localized(context)),
                      const Divider(color: Color.fromRGBO(0, 0, 0, 0.12)),
                      _buildDetailRow(context, Icons.people, l10n.passengerCountLabel, ride.passengerCount.toString()),
                      if (ride.acceptPets || ride.acceptWheelchair || ride.acceptCargo) ...[
                        const Divider(color: Color.fromRGBO(0, 0, 0, 0.12)),
                        Text('${l10n.conditionsLabel}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (ride.acceptPets) _buildConditionChip(context, l10n.conditionPets, Icons.pets),
                            if (ride.acceptWheelchair) _buildConditionChip(context, l10n.conditionWheelchair, Icons.accessible),
                            if (ride.acceptCargo) _buildConditionChip(context, l10n.conditionCargo, Icons.luggage),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Cancel Button
              if (canCancel)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmCancel(context, ref, rideId, l10n),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.cancel),
                    label: Text(l10n.cancelRideButton),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Color _getStatusColor(RideStatus status) {
    switch (status) {
      case RideStatus.pending: return Colors.orange;
      case RideStatus.accepted: return Colors.blue;
      case RideStatus.arrived: return Colors.purple;
      case RideStatus.riding: return Colors.green;
      case RideStatus.completed: return Colors.grey;
      case RideStatus.cancelled: return Colors.red;
    }
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.black54)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildConditionChip(BuildContext context, String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref, String rideId, AppLocalizations l10n) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelRideButton),
        content: Text(l10n.confirmCancelMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.noButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.yesButton),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(rideRepositoryProvider).cancelRide(rideId);
      if (context.mounted) {
        Navigator.pop(context); // Go back to list
      }
    }
  }
}

final rideStreamProvider = StreamProvider.family<RideModel, String>((ref, rideId) {
  return ref.watch(rideRepositoryProvider).streamRide(rideId);
});
