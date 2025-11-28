import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:helpride/features/rides/repository/ride_repository.dart';
import 'package:helpride/features/rides/domain/ride_model.dart';

import 'package:helpride/core/providers/session_provider.dart';
import 'package:helpride/core/providers/role_provider.dart'; // Added import
import 'package:helpride/core/presentation/constants.dart';
import 'package:helpride/features/rides/presentation/widgets/ride_route_widget.dart';
import 'package:helpride/features/rides/presentation/widgets/status_chip.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(sessionProvider);

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.orderHistoryTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.loginRequiredMessage,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: Text(l10n.goToLoginButton),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderHistoryTitle)),
      body: StreamBuilder<List<RideModel>>(
        // We need a stream for ALL rides, not just active ones.
        // Reusing streamRiderRides but we might need to remove the limit(1) in the repo 
        // or create a new streamHistoryRides method.
        // For now, let's assume we create a new method or modify the existing one.
        // I'll use a new stream method name here and implement it next.
        // Stream based on role
        stream: ref.watch(rideRepositoryProvider).streamRideHistory(
          session.uid, 
          isDriver: ref.watch(roleProvider) == UserRole.driver,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final rides = snapshot.data!;
          if (rides.isEmpty) return Center(child: Text(l10n.noHistoryMessage));

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
                              StatusChip(status: ride.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          RideRouteWidget(
                            pickupAddress: ride.pickupAddress,
                            destinationAddress: ride.destinationAddress,
                          ),
                          Builder(
                            builder: (context) {
                              final isDriver = ride.driverId == session.uid;
                              final otherPartyName = isDriver ? ride.riderName : ride.driverName;
                              final otherPartyLabel = isDriver ? l10n.riderLabel : l10n.driverLabel;

                              if (otherPartyName != null) {
                                return Column(
                                  children: [
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.person, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$otherPartyLabel: $otherPartyName',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            },
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
    );
  }
}
