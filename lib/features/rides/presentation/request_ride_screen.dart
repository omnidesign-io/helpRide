import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';

import '../repository/ride_repository.dart';
import '../domain/ride_options.dart';
import '../domain/vehicle_type.dart';

class RequestRideScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  const RequestRideScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<RequestRideScreen> createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends ConsumerState<RequestRideScreen> {
  bool _isLoading = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      // Check permissions (Assuming already handled in Phase 2, but good to be safe)
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        setState(() => _currentPosition = position);
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _requestRide() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location needed to request ride')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final rideRepo = ref.read(rideRepositoryProvider);
      await rideRepo.createRideRequest(
        riderPhone: widget.phoneNumber,
        pickupLocation: GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
        options: const RideOptions(vehicleType: VehicleType.sedan),
        // Dropoff is optional for now
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride Requested!')),
        );
        context.pop(); // Go back to home
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
            if (_currentPosition != null)
              Text('${l10n.pickupLocationLabel}: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}')
            else
              Text(l10n.gettingLocationMessage),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_currentPosition != null && !_isLoading) ? _requestRide : null,
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
