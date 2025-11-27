import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpride/core/providers/role_provider.dart';
import 'package:helpride/features/rides/repository/ride_repository.dart';
import 'package:helpride/features/rides/domain/ride_model.dart';
import 'package:helpride/features/rides/domain/vehicle_type.dart';
import 'package:helpride/features/home/presentation/map_placeholder_widget.dart';
import 'package:helpride/features/rides/presentation/active_ride_screen.dart';
import 'package:helpride/core/presentation/counter_input_widget.dart';

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
  VehicleType? _selectedVehicle;
  int _passengerCount = 1;

  // Driver State
  bool _isDriverOnline = false;

  @override
  void initState() {
    super.initState();
    _fromController.addListener(_onFieldChanged);
    _toController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
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
    // Temporary: Hardcoded phone for MVP
    const String currentUserPhone = '+85212345678';

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
          // 2. MAIN SPLIT VIEW (Map + Draggable Sheet)
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
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: () {
                // Mock Location Update
                _fromController.text = "Current Location (${DateTime.now().second})";
              },
              icon: const Icon(Icons.refresh),
              tooltip: l10n.updateLocationButton,
            ),
          ],
        ),
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

        // Vehicle Type Selector
        InkWell(
          onTap: () async {
            final result = await context.push('/vehicle-selection', extra: _selectedVehicle);
            if (result != null && result is VehicleType) {
              setState(() {
                _selectedVehicle = result;
              });
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.vehicleTypeLabel,
              prefixIcon: Icon(Icons.directions_car),
              border: OutlineInputBorder(),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_selectedVehicle?.localized(context) ?? l10n.selectVehicleLabel),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
          
        // Passenger Count
        CounterInputWidget(
          label: l10n.passengerCountLabel,
          value: _passengerCount,
          onChanged: (val) => setState(() => _passengerCount = val),
          min: 1,
          max: 10,
        ),
        const SizedBox(height: 24),

        const SizedBox(height: 24),

        // Request Button
        ElevatedButton(
          onPressed: (_fromController.text.isNotEmpty && 
                      _toController.text.isNotEmpty && 
                      _selectedVehicle != null) 
              ? () async {
                  // Create Ride Request
                  try {
                    await ref.read(rideRepositoryProvider).createRideRequest(
                      riderPhone: phone,
                      pickupLocation: const CloudFirestoreGeoPoint(22.3193, 114.1694), // Mong Kok
                      passengerCount: _passengerCount,
                      vehicleType: _selectedVehicle!,
                      // dropoffLocation: ... 
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
          onPressed: () {
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.locationUpdatedMessage)),
              );
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
}


