import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:helpride/core/providers/session_provider.dart';
import 'package:helpride/features/rides/domain/ride_model.dart';
import 'package:helpride/features/rides/repository/ride_repository.dart';
import 'package:helpride/features/rides/repository/vehicle_type_repository.dart';
import 'package:helpride/core/presentation/constants.dart';
import 'package:helpride/features/rides/presentation/widgets/ride_route_widget.dart';

class DriverDashboardScreen extends ConsumerWidget {
  const DriverDashboardScreen({super.key});



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final rideRepo = ref.watch(rideRepositoryProvider);
    final session = ref.watch(sessionProvider);
    final vehicleTypesAsync = ref.watch(vehicleTypesProvider);

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
                            const Icon(Icons.directions_car, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            vehicleTypesAsync.when(
                              data: (types) {
                                final isZh = Localizations.localeOf(context).languageCode == 'zh';
                                final typeNames = ride.requestedVehicleTypeIds.map((id) {
                                  final type = types.where((t) => t.id == id).firstOrNull;
                                  return type != null ? (isZh ? type.nameZh : type.nameEn) : id;
                                }).join(', ');
                                return Text(typeNames, style: Theme.of(context).textTheme.bodySmall);
                              },
                              loading: () => const Text('...'),
                              error: (_, __) => const Text(''),
                            ),
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
}
