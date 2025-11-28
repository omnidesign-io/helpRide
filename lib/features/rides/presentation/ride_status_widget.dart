import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpride/features/rides/domain/ride_model.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../repository/ride_repository.dart';

class RideStatusWidget extends ConsumerWidget {
  final RideModel ride;

  const RideStatusWidget({super.key, required this.ride});

  Future<void> _launchWhatsApp(String phone) async {
    final url = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final rideRepo = ref.read(rideRepositoryProvider);

    String statusMessage;
    switch (ride.status) {
      case RideStatus.pending:
        statusMessage = l10n.searchingForDriverMessage;
        break;
      case RideStatus.accepted:
        statusMessage = l10n.driverFoundMessage;
        break;
      case RideStatus.arrived:
        statusMessage = "Driver has arrived!"; // TODO: Localize
        break;
      case RideStatus.riding:
        statusMessage = "Ride in progress..."; // TODO: Localize
        break;
      case RideStatus.completed:
        statusMessage = "Ride completed. Thank you!"; // TODO: Localize
        break;
      case RideStatus.cancelled:
        statusMessage = "Ride cancelled.";
        break;
    }

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              statusMessage,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (ride.status != RideStatus.pending && ride.driverPhone != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${l10n.driverLabel}: ${ride.driverPhone}'),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.message, color: Colors.green),
                    onPressed: () => _launchWhatsApp(ride.driverPhone!),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (ride.status == RideStatus.pending)
              ElevatedButton(
                onPressed: () async {
                  try {
                    await rideRepo.cancelRide(ride.id);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade100,
                  foregroundColor: Colors.red.shade900,
                ),
                child: Text(l10n.cancelRideButton),
              ),
            if (ride.status == RideStatus.completed)
              ElevatedButton(
                onPressed: () {
                  // TODO: Reset flow / Rate driver
                  // For MVP, just reload or navigate home (which will reset if we filter out completed rides)
                  // Actually, LandingPage filters for 'pending' or 'accepted'. 
                  // We need to update LandingPage to handle 'completed' state properly (e.g. show a "Done" button to clear).
                },
                child: const Text("Close"),
              ),
          ],
        ),
      ),
    );
  }
}
