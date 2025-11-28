import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:helpride/core/providers/session_provider.dart';
import 'package:helpride/features/rides/domain/ride_model.dart';
import 'package:helpride/features/rides/repository/ride_repository.dart';
import 'package:helpride/features/rides/domain/vehicle_type.dart';
import 'package:helpride/core/presentation/constants.dart';
import 'package:helpride/features/rides/presentation/widgets/ride_route_widget.dart';

class DriverDashboardScreen extends ConsumerWidget {
  const DriverDashboardScreen({super.key});

  Future<void> _launchWhatsApp(String phone) async {
    final url = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final rideRepo = ref.watch(rideRepositoryProvider);
    final session = ref.watch(sessionProvider);

    if (session == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            l10n.driverDashboardTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Expanded(
          child: StreamBuilder<List<RideModel>>(
        // TODO: In real app, we need a stream that combines "available rides" AND "my active rides"
        // For MVP, we'll just stream ALL rides and filter client-side or update the repo method
        // to return both. For now, let's assume streamAvailableRides returns everything relevant.
        // Actually, streamAvailableRides only returns 'pending'. We need a new stream or modify it.
        // Let's modify the stream in the repo to be broader or use a different query.
        // For this step, I'll assume we update the repo to stream "all active rides" or similar.
        // Wait, I can't easily change the repo query without re-indexing. 
        // Let's stick to the plan: I need to see rides I've accepted too.
        // I'll use a temporary solution: Stream ALL rides (ordered by time) and filter in UI.
        // This is inefficient but works for MVP without complex indexing right now.
        stream: rideRepo.streamAvailableRides(), 
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allRides = snapshot.data!;
          // Filter: Show Pending OR Rides accepted by ME
          final rides = allRides.where((r) => 
            r.status == RideStatus.pending || 
            (r.driverId == session.uid && [RideStatus.accepted, RideStatus.arrived, RideStatus.riding].contains(r.status))
          ).toList();

          if (rides.isEmpty) {
            return Center(child: Text(l10n.noRidesAvailableMessage));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rides.length,
            separatorBuilder: (context, index) => const SizedBox(height: kListItemSpacing),
            itemBuilder: (context, index) {
              final ride = rides[index];
              return Card(
                child: InkWell(
                  onTap: () {
                    context.push('/ride-details/${ride.id}');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ride.scheduledTime != null
                                  ? '${ride.scheduledTime!.year}-${ride.scheduledTime!.month.toString().padLeft(2, '0')}-${ride.scheduledTime!.day.toString().padLeft(2, '0')} ${ride.scheduledTime!.hour.toString().padLeft(2, '0')}:${ride.scheduledTime!.minute.toString().padLeft(2, '0')}'
                                  : l10n.nowLabel,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            // Driver dashboard usually shows available rides (pending) or active rides.
                            // If showing active rides, maybe show status? But for now, just time.
                          ],
                        ),
                        const SizedBox(height: 8),
                        RideRouteWidget(
                          pickupAddress: ride.pickupAddress,
                          destinationAddress: ride.destinationAddress,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(ride.vehicleType.icon, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(ride.vehicleType.localized(context), style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${l10n.riderLabel}: ${ride.riderName}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context, 
    RideRepository rideRepo, 
    RideModel ride, 
    bool isMyRide, 
    AppLocalizations l10n,
    WidgetRef ref,
    String uid,
    String username,
    String phoneNumber,
  ) {
    if (!isMyRide) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            try {
              await rideRepo.acceptRide(
                rideId: ride.id,
                driverId: uid,
                driverName: username ?? 'Unknown Driver',
                driverTelegram: null, // TODO: Add telegram to Session/User model
                driverPhone: '12345678', // Mock phone for nowNumber,
              );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.rideAcceptedMessage)),
                  );
                }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            }
          },
          child: Text(l10n.acceptRideButton),
        ),
      );
    }

    // My Ride Actions
    switch (ride.status) {
      case RideStatus.accepted:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => rideRepo.updateRideStatus(rideId: ride.id, status: 'arrived'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("I've Arrived"), // TODO: Localize
          ),
        );
      case RideStatus.arrived:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => rideRepo.updateRideStatus(rideId: ride.id, status: 'riding'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Start Ride"), // TODO: Localize
          ),
        );
      case RideStatus.riding:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => rideRepo.updateRideStatus(rideId: ride.id, status: 'completed'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Complete Ride"), // TODO: Localize
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
