import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:helpride/features/rides/domain/ride_model.dart';
import 'package:helpride/features/rides/repository/ride_repository.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';

class ActiveRideScreen extends ConsumerWidget {
  final RideModel ride;
  final bool isDriver;

  const ActiveRideScreen({
    super.key,
    required this.ride,
    required this.isDriver,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rideRepo = ref.read(rideRepositoryProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_car, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  isDriver ? 'Rider: ${ride.riderPhone}' : 'Driver: ${ride.driverPhone ?? "Finding..."}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ride.status.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (ride.status == RideStatus.accepted || ride.status == RideStatus.arrived || ride.status == RideStatus.riding)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () async {
                      final phone = isDriver ? ride.riderPhone : ride.driverPhone;
                      if (phone != null) {
                        final url = Uri.parse('https://wa.me/$phone');
                        if (await canLaunchUrl(url)) await launchUrl(url);
                      }
                    },
                    icon: const Icon(Icons.message, color: Colors.green),
                    tooltip: 'WhatsApp',
                  ),
                  IconButton(
                    onPressed: () async {
                       final phone = isDriver ? ride.riderPhone : ride.driverPhone;
                       if (phone != null) {
                         final url = Uri.parse('https://t.me/$phone'); 
                         if (await canLaunchUrl(url)) await launchUrl(url);
                       }
                    },
                    icon: const Icon(Icons.telegram, color: Colors.blue),
                    tooltip: 'Telegram',
                  ),
                  IconButton(
                    onPressed: () {
                      // Call functionality (mock)
                    },
                    icon: const Icon(Icons.call, color: Colors.green),
                    tooltip: 'Call',
                  ),
                ],
              ),
            
            // Driver Actions
            if (isDriver && ride.status == RideStatus.riding)
               Padding(
                 padding: const EdgeInsets.only(top: 16.0),
                 child: ElevatedButton(
                    onPressed: () => rideRepo.updateRideStatus(rideId: ride.id, status: 'completed'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Complete Ride'),
                 ),
               ),
          ],
        ),
      ),
    );
  }
}
