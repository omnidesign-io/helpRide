import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:helpride/core/providers/session_provider.dart';
import '../repository/ride_repository.dart';
import '../domain/ride_options.dart';
import '../domain/vehicle_type.dart';

class RequestRideScreen extends ConsumerStatefulWidget {
  const RequestRideScreen({super.key});

  @override
  ConsumerState<RequestRideScreen> createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends ConsumerState<RequestRideScreen> {
  bool _isLoading = false;
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _requestRide() async {
    final l10n = AppLocalizations.of(context)!;
    
    setState(() => _isLoading = true);

    try {
      final session = ref.read(sessionProvider);
      if (session != null) {
        final rideRepo = ref.read(rideRepositoryProvider);
        await rideRepo.createRideRequest(
          riderId: session.uid,
          riderPhone: session.phoneNumber,
          pickupAddress: _pickupController.text,
          destinationAddress: _destinationController.text,
          options: const RideOptions(vehicleType: VehicleType.sedan),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.rideRequestedMessage)),
          );
          context.pop(); // Go back to home
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.requestRideTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _pickupController,
              decoration: InputDecoration(
                labelText: l10n.pickupLocationLabel,
                prefixIcon: const Icon(Icons.my_location),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                labelText: l10n.destinationLabel,
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_pickupController.text.isNotEmpty && _destinationController.text.isNotEmpty && !_isLoading) ? _requestRide : null,
                icon: const Icon(Icons.hail),
                label: _isLoading 
                    ? const CircularProgressIndicator() 
                    : Text(l10n.requestNowButton),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
