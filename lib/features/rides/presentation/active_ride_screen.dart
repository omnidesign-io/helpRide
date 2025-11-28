import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:helpride/features/rides/domain/ride_status_extension.dart';
import 'package:helpride/features/rides/domain/ride_model.dart';
import 'package:helpride/features/rides/repository/ride_repository.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:helpride/features/rides/presentation/widgets/status_chip.dart';
import 'package:helpride/features/rides/domain/vehicle_type.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final rideRepo = ref.read(rideRepositoryProvider);

    // Determine other party details
    final otherPartyName = isDriver ? ride.riderName : (ride.driverName ?? l10n.findingDriverMessage);
    final otherPartyPhone = isDriver ? ride.riderPhone : ride.driverPhone;
    final otherPartyTelegram = isDriver ? ride.riderTelegram : ride.driverTelegram;
    
    // Vehicle details (only relevant for Rider view)
    final vehiclePlate = !isDriver && ride.driverLicensePlate != null ? ride.driverLicensePlate : null;
    final vehicleColor = !isDriver && ride.driverVehicleColor != null ? '(${ride.driverVehicleColor})' : null;

    // Calculate opaque background color to prevent shadow from showing through
    final backgroundColor = Color.alphaBlend(
      Colors.teal.withValues(alpha: 0.05),
      Theme.of(context).scaffoldBackgroundColor,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor, // Opaque color matching the tint
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), // Subtle upward shadow
            offset: const Offset(0, -3), // Slightly more upward to be visible
            blurRadius: 5,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push('/ride-details/${ride.id}');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Route + Status
                Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                          children: [
                            TextSpan(text: ride.pickupAddress.split(',')[0].trim()),
                            const WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                child: Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                              ),
                            ),
                            TextSpan(text: ride.destinationAddress.split(',')[0].trim()),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(status: ride.status),
                  ],
                ),
                const SizedBox(height: 8),

                // Row 2: Name / Searching...
                Text(
                  ride.status == RideStatus.pending ? l10n.findingDriverMessage : otherPartyName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                // Row 3: Vehicle Info (if available)
                if (vehiclePlate != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Text(
                      '${ride.vehicleType.localized(context)} • $vehiclePlate${vehicleColor != null ? " $vehicleColor" : ""}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],

                // Row 4: Actions
                if (ride.status == RideStatus.accepted || ride.status == RideStatus.arrived || ride.status == RideStatus.riding) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (otherPartyPhone != null)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilledButton.tonal(
                              onPressed: () async {
                                final url = Uri.parse('tel:$otherPartyPhone');
                                if (await canLaunchUrl(url)) await launchUrl(url);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.call, size: 18),
                                  const SizedBox(width: 8),
                                  Text(l10n.callButtonLabel),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (otherPartyPhone != null) // Assuming WhatsApp uses phone number
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: FilledButton.tonal(
                              onPressed: () async {
                                final url = Uri.parse('https://wa.me/$otherPartyPhone');
                                if (await canLaunchUrl(url)) await launchUrl(url);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.message, size: 18),
                                  const SizedBox(width: 8),
                                  const Text('WhatsApp'), // Hardcoded as per sketch, or use l10n
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method removed as we are using standard buttons now
}
