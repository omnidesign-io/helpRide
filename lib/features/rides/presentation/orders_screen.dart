import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:helpride/features/rides/repository/ride_repository.dart';
import 'package:helpride/features/rides/domain/ride_model.dart';
import 'package:helpride/features/rides/domain/ride_status_extension.dart';
import 'package:helpride/core/providers/session_provider.dart';

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
        stream: ref.watch(rideRepositoryProvider).streamRideHistory(session.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final rides = snapshot.data!;
          if (rides.isEmpty) return Center(child: Text(l10n.noHistoryMessage));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index];
              return Semantics(
                label: 'Ride ${ride.shortId}, Status: ${ride.status.localized(context)}',
                child: Card(
                  child: ListTile(
                    key: Key('order_tile_${ride.shortId}'),
                    title: Text('Ride #${ride.shortId}'),
                    subtitle: Text('${ride.status.localized(context)} - ${ride.createdAt}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      context.push('/ride-details/${ride.id}');
                    },
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
