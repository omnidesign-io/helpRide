import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:helpride/features/rides/repository/ride_repository.dart';
import 'package:helpride/features/rides/domain/ride_model.dart';
import 'package:helpride/features/rides/domain/ride_status_extension.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    const String currentUserPhone = '+85212345678';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderHistoryTitle)),
      body: StreamBuilder<List<RideModel>>(
        // We need a stream for ALL rides, not just active ones.
        // Reusing streamRiderRides but we might need to remove the limit(1) in the repo 
        // or create a new streamHistoryRides method.
        // For now, let's assume we create a new method or modify the existing one.
        // I'll use a new stream method name here and implement it next.
        stream: ref.watch(rideRepositoryProvider).streamRideHistory(currentUserPhone),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final rides = snapshot.data!;
          if (rides.isEmpty) return const Center(child: Text('No history'));

          return ListView.builder(
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index];
              return Semantics(
                label: 'Ride ${ride.shortId}, Status: ${ride.status.localized(context)}',
                child: ListTile(
                  key: Key('order_tile_${ride.shortId}'),
                  title: Text('Ride #${ride.shortId}'),
                subtitle: Text('${ride.status.localized(context)} - ${ride.createdAt}'),
                  trailing: Text(ride.status.localized(context)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
