import 'package:flutter/material.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpride/core/providers/role_provider.dart';
import 'package:helpride/features/rides/repository/ride_repository.dart';
import 'package:helpride/features/rides/domain/ride_model.dart';
import 'package:helpride/features/rides/domain/vehicle_type.dart';
import 'package:helpride/features/rides/domain/ride_options.dart';
import 'package:helpride/core/providers/session_provider.dart';
import 'package:helpride/features/home/repository/user_repository.dart';

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
    final String currentUserId = session.uid;

    // Watch for active rides
    final activeRidesAsync = ref.watch(rideRepositoryProvider).streamRiderRides(currentUserId);

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

          // 2. MAIN LIST VIEW (No Map)
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: currentRole == UserRole.driver
                ? _buildDriverControls(context, ref, l10n, currentUserPhone, currentUserId, session.username)
                : _buildRiderControls(context, ref, l10n, currentUserPhone, currentUserId, session.username, activeRide),
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

  Widget _buildRiderControls(BuildContext context, WidgetRef ref, AppLocalizations l10n, String phone, String uid, String? username, RideModel? activeRide) {
    final bool isInputDisabled = activeRide != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.requestRideTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),

        // Location Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // From Field
                TextFormField(
                  controller: _fromController,
                  enabled: !isInputDisabled,
                  decoration: InputDecoration(
                    labelText: l10n.pickupLocationLabel,
                    prefixIcon: const Icon(Icons.my_location),
                  ),
                ),
                const SizedBox(height: 16),

                // To Field
                TextFormField(
                  controller: _toController,
                  enabled: !isInputDisabled,
                  decoration: InputDecoration(
                    labelText: l10n.destinationLabel,
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Ride Options Section
        Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isInputDisabled ? null : () async {
              final result = await context.push('/vehicle-selection', extra: _rideOptions);
              if (result != null && result is RideOptions) {
                setState(() {
                  _rideOptions = result;
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.rideOptionsTitle,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
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
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
        ),
        const SizedBox(height: 24),

        const SizedBox(height: 24),

        // Request Button
        ElevatedButton(
          onPressed: (!isInputDisabled && 
                      _fromController.text.isNotEmpty && 
                      _toController.text.isNotEmpty && 
                      _rideOptions != null) 
              ? () async {
                  // Create Ride Request
                  try {
                    await ref.read(rideRepositoryProvider).createRideRequest(
                      riderId: uid,
                      riderName: username ?? 'Unknown Rider',
                      riderTelegram: null, // TODO: Add telegram to Session/User model
                      riderPhone: phone,
                      pickupAddress: _fromController.text,
                      destinationAddress: _toController.text,
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
              : null, // Disable if invalid or active ride exists
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

  Widget _buildDriverControls(BuildContext context, WidgetRef ref, AppLocalizations l10n, String phone, String uid, String? username) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Status Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isDriverOnline ? l10n.youAreOnlineMessage : l10n.youAreOfflineMessage,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isDriverOnline ? Colors.green : Theme.of(context).colorScheme.onSurface,
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
          ),
        ),
        const SizedBox(height: 16),

        if (!_isDriverOnline)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                l10n.goOnlineMessage,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                            driverId: uid,
                            driverName: username ?? 'Unknown Driver',
                            driverTelegram: null, // TODO: Add telegram to Session/User model
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
