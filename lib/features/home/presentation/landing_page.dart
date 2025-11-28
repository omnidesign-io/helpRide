import 'package:flutter/material.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpride/core/providers/role_provider.dart';
import 'package:helpride/features/rides/repository/ride_repository.dart';
import 'package:helpride/features/rides/domain/ride_model.dart';
import 'package:helpride/core/presentation/constants.dart';
import 'package:helpride/features/rides/presentation/widgets/ride_route_widget.dart';
import 'package:helpride/features/rides/domain/vehicle_type.dart';
import 'package:helpride/features/rides/domain/ride_options.dart';
import 'package:helpride/core/providers/session_provider.dart';
import 'package:helpride/features/home/repository/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for DocumentSnapshot

final userProfileProvider = StreamProvider.family<DocumentSnapshot<Map<String, dynamic>>, String>((ref, uid) {
  return ref.watch(userRepositoryProvider).getUserStream(uid);
});

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


  bool _isLoading = false;
  bool _isBooking = false; // Prevent double-click
  String? _riderName;
  String? _riderPhone;
  String? _riderTelegram;
  DateTime? _scheduledTime; // Null means "Now"

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _fromController.addListener(_onFieldChanged);
    _toController.addListener(_onFieldChanged);
  }

  Future<void> _loadUserProfile() async {
    final session = ref.read(sessionProvider);
    if (session != null) {
      setState(() {
        _riderName = session.username;
        _riderPhone = session.phoneNumber;
        // _riderTelegram = session.telegramHandle; // TODO: Add to session
      });
    }
  }

  Future<void> _selectScheduledTime() async {
    final now = DateTime.now();
    final initialDate = _scheduledTime ?? now;
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year, now.month, now.day), // Disable past dates
      lastDate: now.add(const Duration(days: 30)),
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (pickedTime != null) {
        setState(() {
          _scheduledTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _createRideRequest() async {
    if (_fromController.text.isEmpty ||
        _toController.text.isEmpty ||
        _rideOptions == null) {
       // Should be handled by button disable state, but good for safety
      return;
    }

    // Validate scheduled time
    if (_scheduledTime != null && _scheduledTime!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.scheduledTimePastError)),
      );
      return;
    }

    if (_isBooking) return;

    setState(() {
      _isLoading = true;
      _isBooking = true;
    });

    try {
      final session = ref.read(sessionProvider);
      if (session == null) throw Exception('User not logged in');

      // Use session data if available, otherwise fallback (shouldn't happen if logged in)
      final name = _riderName ?? 'Unknown Rider';
      final phone = _riderPhone ?? 'Unknown Phone';

      await ref.read(rideRepositoryProvider).createRideRequest(
            riderId: session.uid,
            riderName: name,
            riderPhone: phone,
            riderTelegram: _riderTelegram,
            pickupAddress: _fromController.text,
            destinationAddress: _toController.text,
            options: _rideOptions!,
            scheduledTime: _scheduledTime,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.rideRequestedMessage)),
        );
        // Clear fields after successful request
        _fromController.clear();
        _toController.clear();
        setState(() {
          _rideOptions = null; // Reset options
          _scheduledTime = null; // Reset time
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isBooking = false;
        });
      }
    }
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

    // Sync Role with Firestore
    ref.listen(userProfileProvider(currentUserId), (previous, next) {
      next.whenData((doc) {
        if (doc.exists) {
          final data = doc.data();
          final roleStr = data?['role'] as String?;
          if (roleStr != null) {
            final role = roleStr == 'driver' ? UserRole.driver : UserRole.rider;
            // Only update if different to avoid loops/rebuilds
            if (ref.read(roleProvider) != role) {
               // Schedule update to avoid build-phase modification
               Future.microtask(() {
                 ref.read(roleProvider.notifier).setRole(role);
                 // Also update session to keep it in sync for next boot
                 ref.read(sessionProvider.notifier).updateRole(roleStr);
               });
            }
          }
        }
      });
    });

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
        const SizedBox(height: 16),

        // Time Selection Section
        Card(
          color: (_scheduledTime != null && _scheduledTime!.isBefore(DateTime.now()))
              ? Theme.of(context).colorScheme.errorContainer
              : null,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isInputDisabled ? null : () {
              if (_scheduledTime == null) {
                // Switch to scheduled -> open picker
                _selectScheduledTime();
              } else {
                // Already scheduled -> show options (Change or Reset to Now)
                showModalBottomSheet(
                  context: context,
                  builder: (context) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: Text(l10n.changeTimeButton),
                          onTap: () {
                            Navigator.pop(context);
                            _selectScheduledTime();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.restore),
                          title: Text(l10n.resetToNowButton),
                          onTap: () {
                            setState(() => _scheduledTime = null);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                );
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
                        l10n.timeLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: (_scheduledTime != null && _scheduledTime!.isBefore(DateTime.now()))
                              ? Theme.of(context).colorScheme.onErrorContainer
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: (_scheduledTime != null && _scheduledTime!.isBefore(DateTime.now()))
                              ? Theme.of(context).colorScheme.onErrorContainer
                              : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _scheduledTime == null ? Icons.access_time_filled : Icons.event,
                        size: 20,
                        color: (_scheduledTime != null && _scheduledTime!.isBefore(DateTime.now()))
                              ? Theme.of(context).colorScheme.onErrorContainer
                              : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _scheduledTime == null
                            ? l10n.nowLabel
                            : '${_scheduledTime!.year}-${_scheduledTime!.month.toString().padLeft(2, '0')}-${_scheduledTime!.day.toString().padLeft(2, '0')} ${_scheduledTime!.hour.toString().padLeft(2, '0')}:${_scheduledTime!.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16,
                          color: (_scheduledTime != null && _scheduledTime!.isBefore(DateTime.now()))
                              ? Theme.of(context).colorScheme.onErrorContainer
                              : null,
                        ),
                      ),
                    ],
                  ),
                  if (_scheduledTime != null && _scheduledTime!.isBefore(DateTime.now()))
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        l10n.timeInPastError,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Request Button
        ElevatedButton(
          onPressed: (!isInputDisabled && 
                      _fromController.text.isNotEmpty && 
                      _toController.text.isNotEmpty && 
                      _rideOptions != null && 
                      !_isBooking &&
                      (_scheduledTime == null || _scheduledTime!.isAfter(DateTime.now()))) 
              ? _createRideRequest
              : null, // Disable if invalid or active ride exists
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade600,
          ),
          child: Text(_scheduledTime == null ? l10n.requestNowButton : l10n.submitBookingButton),
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
              children: [
                const Icon(Icons.work, color: Colors.green),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.driverModeLabel, // You might need to add this key or use "Driver Mode"
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        l10n.lookingForRidesMessage, // You might need to add this key or use "Looking for rides..."
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        StreamBuilder<List<RideModel>>(
          stream: ref.watch(rideRepositoryProvider).streamAvailableRides(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            
            final rides = snapshot.data!.where((r) => r.status == RideStatus.pending).toList();

            if (rides.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.directions_car_outlined, size: 48, color: Theme.of(context).colorScheme.outline),
                      const SizedBox(height: 16),
                      Text(l10n.noPendingRidesMessage),
                    ],
                  ),
                ),
              );
            }



// ...

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rides.length,
              separatorBuilder: (context, index) => const SizedBox(height: kListItemSpacing),
              itemBuilder: (context, index) {
                final ride = rides[index];
                return Card(
                  child: InkWell(
                    onTap: () {
                      context.push('/ride-details/${ride.id}');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ride.scheduledTime != null
                                    ? '${ride.scheduledTime!.year}-${ride.scheduledTime!.month.toString().padLeft(2, '0')}-${ride.scheduledTime!.day.toString().padLeft(2, '0')} ${ride.scheduledTime!.hour.toString().padLeft(2, '0')}:${ride.scheduledTime!.minute.toString().padLeft(2, '0')}'
                                    : l10n.nowLabel,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  ref.read(rideRepositoryProvider).acceptRide(
                                    rideId: ride.id,
                                    driverId: uid,
                                    driverName: username ?? 'Unknown Driver',
                                    driverPhone: phone,
                                    driverTelegram: null, // TODO: Add telegram to Session/User model
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                                child: Text(l10n.acceptButton),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          RideRouteWidget(
                            pickupAddress: ride.pickupAddress,
                            destinationAddress: ride.destinationAddress,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(ride.vehicleType.icon, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(ride.vehicleType.localized(context), style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
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
