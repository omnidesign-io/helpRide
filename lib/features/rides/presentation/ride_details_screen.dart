import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpride/features/rides/domain/ride_model.dart';
import 'package:helpride/features/rides/repository/ride_repository.dart';
import 'package:helpride/features/rides/domain/ride_status_extension.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:helpride/features/rides/domain/vehicle_type.dart';
import 'package:intl/intl.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:helpride/features/rides/presentation/widgets/ride_route_widget.dart';
import 'package:helpride/core/providers/session_provider.dart';

class RideDetailsScreen extends ConsumerWidget {
  final String rideId;

  const RideDetailsScreen({super.key, required this.rideId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final rideAsync = ref.watch(rideStreamProvider(rideId));
    final session = ref.watch(sessionProvider);
    final currentUserId = session?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.rideDetailsTitle),
      ),
      body: rideAsync.when(
        data: (ride) {

          final canCancel = ride.status == RideStatus.pending ||
              ride.status == RideStatus.accepted ||
              ride.status == RideStatus.arrived;

          // Determine roles
          final isRider = ride.riderId == currentUserId;
          final isDriver = ride.driverId == currentUserId;
          
          // Determine other party info




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
                          color: _getStatusColor(ride.status).withValues(alpha: 0.1),
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



              // Party Info (Context Aware)
              if ((ride.status == RideStatus.accepted || 
                   ride.status == RideStatus.arrived || 
                   ride.status == RideStatus.riding) && 
                  (isRider || isDriver)) ...[
                Builder(
                  builder: (context) {
                    final isShowingDriver = isRider;
                    final name = isShowingDriver ? ride.driverName : ride.riderName;
                    final phone = isShowingDriver ? ride.driverPhone : ride.riderPhone;
                    final telegram = isShowingDriver ? ride.driverTelegram : ride.riderTelegram;
                    final licensePlate = isShowingDriver ? ride.driverLicensePlate : null;
                    final label = isShowingDriver ? l10n.driverLabel : l10n.riderLabel;

                    if (name == null) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          if (licensePlate != null && licensePlate.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                                              ),
                                              child: Text(
                                                licensePlate,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    if (phone != null)
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: FilledButton.tonal(
                                            onPressed: () => _launchUrl('tel:$phone'),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.phone, size: 18),
                                                const SizedBox(width: 8),
                                                Flexible(child: Text(l10n.callButtonLabel, overflow: TextOverflow.ellipsis)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (phone != null)
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: FilledButton.tonal(
                                            onPressed: () => _launchUrl('https://wa.me/${phone.replaceAll('+', '')}'),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.message, size: 18),
                                                const SizedBox(width: 8),
                                                Flexible(child: Text(l10n.messageButtonLabel, overflow: TextOverflow.ellipsis)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (telegram != null && telegram.isNotEmpty)
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: FilledButton.tonal(
                                            onPressed: () => _launchUrl('https://t.me/$telegram'),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.send, size: 18),
                                                const SizedBox(width: 8),
                                                Flexible(child: Text(l10n.telegramButtonLabel, overflow: TextOverflow.ellipsis)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }
                ),
              ],

              // Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Origin -> Destination
                      RideRouteWidget(
                        pickupAddress: ride.pickupAddress,
                        destinationAddress: ride.destinationAddress,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Divider(color: Color.fromRGBO(0, 0, 0, 0.12)),
                      // Replaced Date Row with Time Row
                      _buildDetailRow(
                        context, 
                        Icons.access_time, 
                        l10n.timeLabel, 
                        ride.scheduledTime != null
                          ? '${ride.scheduledTime!.year}-${ride.scheduledTime!.month.toString().padLeft(2, '0')}-${ride.scheduledTime!.day.toString().padLeft(2, '0')} ${ride.scheduledTime!.hour.toString().padLeft(2, '0')}:${ride.scheduledTime!.minute.toString().padLeft(2, '0')}'
                          : l10n.nowLabel
                      ),
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
              const SizedBox(height: 16),

              // Audit Trail
              if (ride.auditTrail.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.activityHeader, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        _buildGroupedAuditTrail(context, ride),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],



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





  String _localizeAction(BuildContext context, String action) {
    final l10n = AppLocalizations.of(context)!;
    switch (action.toLowerCase()) {
      case 'created': return l10n.auditActionCreated;
      case 'accepted': return l10n.auditActionAccepted;
      case 'arrived': return l10n.auditActionArrived;
      case 'riding': return l10n.auditActionRiding;
      case 'completed': return l10n.auditActionCompleted;
      case 'cancelled': return l10n.auditActionCancelled;
      default: return action.toUpperCase();
    }
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

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
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

  Widget _buildGroupedAuditTrail(BuildContext context, RideModel ride) {
    // Group logs by date
    final Map<String, List<Map<String, dynamic>>> groupedLogs = {};
    for (var log in ride.auditTrail) {
      final timestamp = (log['timestamp'] as dynamic)?.toDate() ?? DateTime.now();
      final dateKey = DateFormat('yyyy-MM-dd').format(timestamp);
      if (!groupedLogs.containsKey(dateKey)) {
        groupedLogs[dateKey] = [];
      }
      groupedLogs[dateKey]!.add(log);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedLogs.entries.map((entry) {
        final dateKey = entry.key;
        final logs = entry.value;
        final date = DateTime.parse(dateKey); // Assuming yyyy-MM-dd format parses correctly

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                DateFormat('EEE, MMM d, yyyy').format(date),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            ...logs.map((log) {
              final timestamp = (log['timestamp'] as dynamic)?.toDate() ?? DateTime.now();
              final action = log['action'].toString();
              final actorId = log['actorId'] as String?;
              
              String actorName = 'System';
              if (actorId != null) {
                if (actorId == ride.riderId) {
                  actorName = ride.riderName;
                } else if (actorId == ride.driverId) {
                  actorName = ride.driverName ?? 'Driver';
                }
              }

              return Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(timestamp),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13),
                          children: [
                            TextSpan(
                              text: '$actorName ',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: _localizeAction(context, action),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }
}

final rideStreamProvider = StreamProvider.family<RideModel, String>((ref, rideId) {
  return ref.watch(rideRepositoryProvider).streamRide(rideId);
});
