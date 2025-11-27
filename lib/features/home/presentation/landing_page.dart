import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpride/core/providers/role_provider.dart';
import 'package:helpride/features/rides/repository/ride_repository.dart';
import 'package:helpride/features/rides/domain/ride_model.dart';
import 'package:helpride/features/rides/domain/vehicle_type.dart';
import 'package:helpride/features/rides/domain/ride_options.dart';
import 'package:helpride/features/home/presentation/map_placeholder_widget.dart';
import 'package:helpride/features/rides/presentation/active_ride_screen.dart';
import 'package:helpride/core/providers/session_provider.dart';
import 'package:helpride/features/home/repository/user_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

typedef CloudFirestoreGeoPoint = GeoPoint;

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  // Rider State
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  RideOptions? _rideOptions;

  // Driver State
  bool _isDriverOnline = false;
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLocating = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _fromController.addListener(_onFieldChanged);
    _toController.addListener(_onFieldChanged);
    _loadCurrentLocation();
  }

  void _onFieldChanged() {
    setState(() {});
  }

  Future<void> _loadCurrentLocation() async {
    setState(() {
      _isLocating = true;
      _locationError = null;
    });

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _locationError = AppLocalizations.of(context)!.locationPermissionDenied;
            _isLocating = false;
          });
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      String? address;
      try {
        final placemarks = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final parts = [
            place.name,
            place.street,
            place.subLocality,
            place.locality,
          ].where((element) => element != null && element!.isNotEmpty).toList();
          address = parts.join(', ');
        }
      } catch (_) {
        // Ignore geocoding errors; fall back to lat/lng display.
      }

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _currentAddress = address;
          _fromController.text = address ??
              '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
          _isLocating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = AppLocalizations.of(context)!.locationFetchError;
          _isLocating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fromController.removeListener(_onFieldChanged);
    _toController.removeListener(_onFieldChanged);
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentRole = ref.watch(roleProvider);
    final session = ref.watch(sessionProvider);

    if (session == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle),
          centerTitle: true,
        ),
        body: _buildLoginPrompt(context, l10n),
      );
    }

    final String currentUserPhone = session.phoneNumber;

    // Watch for active rides
    final activeRidesAsync = ref.watch(rideRepositoryProvider).streamRiderRides(currentUserPhone);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        centerTitle: true,
      ),
      body: StreamBuilder<List<RideModel>>(
        stream: activeRidesAsync,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final rides = snapshot.data!;
          final activeRide = rides.isNotEmpty && rides.first.isActive ? rides.first : null;

          // 1. ACTIVE RIDE VIEW (Overrides everything else)
          if (activeRide != null) {
            return ActiveRideScreen(
              ride: activeRide,
              isDriver: currentRole == UserRole.driver,
            );
          }

          // 2. MAIN SPLIT VIEW (Map + Controls)
          return Stack(
            children: [
              // Map (Full Screen Background)
              Positioned.fill(
                child: StreamBuilder<List<RideModel>>(
                  stream: ref.watch(rideRepositoryProvider).streamAvailableRides(),
                  builder: (context, snapshot) {
                    final pendingRides = snapshot.data ?? [];
                    return MapPlaceholderWidget(
                      isDriver: currentRole == UserRole.driver,
                      pendingRides: currentRole == UserRole.driver ? pendingRides : [],
                    );
                  },
                ),
              ),

              // Draggable Bottom Sheet
              DraggableScrollableSheet(
                initialChildSize: currentRole == UserRole.driver ? 0.5 : 0.65, // Increased for riders to show full form
                minChildSize: 0.2,
                maxChildSize: 0.9,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      child: currentRole == UserRole.driver
                          ? _buildDriverControls(context, ref, l10n, currentUserPhone)
                          : _buildRiderControls(context, ref, l10n, currentUserPhone),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.loginRequiredMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: Text(l10n.goToLoginButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiderControls(BuildContext context, WidgetRef ref, AppLocalizations l10n, String phone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.requestRideTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        
        // From Field with Refresh
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _fromController,
                decoration: InputDecoration(
                  labelText: l10n.pickupLocationLabel,
                  prefixIcon: const Icon(Icons.my_location),
                  border: const OutlineInputBorder(),
                  helperText: _isLocating
                      ? l10n.gettingLocationMessage
                      : _currentAddress,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: _isLocating ? null : _loadCurrentLocation,
              icon: const Icon(Icons.refresh),
              tooltip: l10n.updateLocationButton,
            ),
          ],
        ),
        if (_locationError != null) ...[
          const SizedBox(height: 8),
          Text(
            _locationError!,
            style: const TextStyle(color: Colors.red),
          ),
        ],
        const SizedBox(height: 16),

        // To Field
        TextField(
          controller: _toController,
          decoration: InputDecoration(
            labelText: l10n.destinationLabel,
            prefixIcon: Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        // Ride Options Selector (Custom Container)
        InkWell(
          onTap: () async {
            final result = await context.push('/vehicle-selection', extra: _rideOptions);
            if (result != null && result is RideOptions) {
              setState(() {
                _rideOptions = result;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.rideOptionsTitle,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[700]),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
                const SizedBox(height: 8),
                if (_rideOptions == null)
                  Text(l10n.selectRideOptionsButton, style: const TextStyle(fontSize: 16))
                else ...[
                  Row(
                    children: [
                      Icon(_rideOptions!.vehicleType.icon, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _rideOptions!.vehicleType.localized(context),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.passengerCountLabel}: ${_rideOptions!.passengerCount}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (_rideOptions!.acceptPets || _rideOptions!.acceptWheelchair || _rideOptions!.acceptCargo) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (_rideOptions!.acceptPets) _buildConditionChip(l10n.conditionPets, Icons.pets),
                        if (_rideOptions!.acceptWheelchair) _buildConditionChip(l10n.conditionWheelchair, Icons.accessible),
                        if (_rideOptions!.acceptCargo) _buildConditionChip(l10n.conditionCargo, Icons.luggage),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        const SizedBox(height: 24),

        // Request Button
        ElevatedButton(
          onPressed: (_fromController.text.isNotEmpty && 
                      _toController.text.isNotEmpty && 
                      _rideOptions != null) 
              ? () async {
                  // Create Ride Request
                  try {
                    await ref.read(rideRepositoryProvider).createRideRequest(
                      riderPhone: phone,
                      pickupLocation: _currentPosition != null
                          ? CloudFirestoreGeoPoint(_currentPosition!.latitude, _currentPosition!.longitude)
                          : const CloudFirestoreGeoPoint(22.3193, 114.1694), // Fallback
                      options: _rideOptions!,
                    );
                    // UI will auto-update due to stream
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                }
              : null, // Disable if invalid
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade600,
          ),
          child: Text(l10n.requestNowButton),
        ),
      ],
    );
  }

  Widget _buildDriverControls(BuildContext context, WidgetRef ref, AppLocalizations l10n, String phone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Online/Offline Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isDriverOnline ? l10n.youAreOnlineMessage : l10n.youAreOfflineMessage,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _isDriverOnline ? Colors.green : Colors.grey,
              ),
            ),
            Switch(
              value: _isDriverOnline,
              onChanged: (val) {
                setState(() {
                  _isDriverOnline = val;
                });
              },
              activeColor: Colors.green,
            ),
          ],
        ),
        const Divider(),

        if (!_isDriverOnline)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                l10n.goOnlineMessage,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          StreamBuilder<List<RideModel>>(
            stream: ref.watch(rideRepositoryProvider).streamAvailableRides(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              final rides = snapshot.data!.where((r) => r.status == RideStatus.pending).toList();

              if (rides.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text(l10n.noPendingRidesMessage)),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rides.length,
                itemBuilder: (context, index) {
                  final ride = rides[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text('${l10n.rideIdLabel}${ride.shortId}'),
                      subtitle: Text(l10n.pickupProximityMessage), // Mock proximity
                      trailing: ElevatedButton(
                        onPressed: () {
                          ref.read(rideRepositoryProvider).acceptRide(
                            rideId: ride.id,
                            driverPhone: phone,
                          );
                        },
                        child: Text(l10n.acceptButton),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () async {
             try {
               await ref.read(userRepositoryProvider).updateLocation(phone);
               if (context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text(l10n.locationUpdatedMessage)),
                 );
               }
             } catch (e) {
               if (context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text(l10n.locationFetchError)),
                 );
               }
             }
          },
          icon: const Icon(Icons.my_location),
          label: Text(l10n.updateMyLocationButton),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildConditionChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}
