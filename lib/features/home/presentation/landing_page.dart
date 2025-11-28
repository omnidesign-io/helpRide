import 'package:flutter/material.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpride/core/providers/role_provider.dart';
import 'package:helpride/features/rides/repository/ride_repository.dart';
import 'package:helpride/features/rides/domain/ride_model.dart';
import 'package:helpride/core/presentation/constants.dart';
import 'package:helpride/features/rides/presentation/widgets/ride_route_widget.dart';
import 'package:helpride/features/rides/presentation/widgets/condition_chip.dart';
import 'package:helpride/core/presentation/widgets/pulsing_green_dot.dart';
import 'package:helpride/core/providers/connectivity_provider.dart';
import 'package:helpride/features/rides/domain/ride_options.dart';
import 'package:helpride/features/rides/repository/vehicle_type_repository.dart';
import 'package:helpride/core/providers/session_provider.dart';
import 'package:helpride/features/home/repository/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for DocumentSnapshot
import 'package:helpride/features/rides/presentation/providers/ride_request_provider.dart';

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

  // RideOptions is now managed by rideRequestProvider

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
        _toController.text.isEmpty) {
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
            options: ref.read(rideRequestProvider),
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
          // _rideOptions = null; // Reset options - actually we might want to keep them or reset provider
          ref.read(rideRequestProvider.notifier).state = const RideOptions();
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

    // Auto-select default vehicle type
    ref.listen(vehicleTypesProvider, (previous, next) {
      next.whenData((types) {
        final currentOptions = ref.read(rideRequestProvider);
        if (currentOptions.vehicleTypeIds.isEmpty) {
          final defaultType = types.where((t) => t.isDefault).firstOrNull;
          if (defaultType != null) {
            // Schedule update to avoid build-phase modification
            Future.microtask(() {
              ref.read(rideRequestProvider.notifier).state = currentOptions.copyWith(
                vehicleTypeIds: [defaultType.id],
                passengerCount: 1,
                acceptPets: false,
                acceptWheelchair: false,
                acceptCargo: false,
              );
            });
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
    final vehicleTypesAsync = ref.watch(vehicleTypesProvider);

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
            onTap: isInputDisabled ? null : () {
              context.push('/vehicle-selection');
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
                  const SizedBox(height: 8),
                  Consumer(
                    builder: (context, ref, child) {
                      final rideOptions = ref.watch(rideRequestProvider);
                      if (rideOptions.vehicleTypeIds.isEmpty) {
                        return Text(l10n.selectVehicleLabel, style: const TextStyle(fontSize: 16));
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.directions_car, size: 20), // Generic icon or first selected
                              const SizedBox(width: 8),
                              Expanded(
                                child: vehicleTypesAsync.when(
                                  data: (types) {
                                    final isZh = Localizations.localeOf(context).languageCode == 'zh';
                                    final names = rideOptions.vehicleTypeIds.map((id) {
                                      final type = types.where((t) => t.id == id).firstOrNull;
                                      return type != null ? (isZh ? type.nameZh : type.nameEn) : id;
                                    }).join(', ');
                                    return Text(
                                      names,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  },
                                  loading: () => const Text('...'),
                                  error: (_, __) => const Text('Error'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${l10n.passengerCountLabel}: ${rideOptions.passengerCount}',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                          if (rideOptions.acceptPets || rideOptions.acceptWheelchair || rideOptions.acceptCargo) ...[
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              children: [
                                if (rideOptions.acceptPets) ConditionChip(label: l10n.conditionPets, icon: Icons.pets),
                                if (rideOptions.acceptWheelchair) ConditionChip(label: l10n.conditionWheelchair, icon: Icons.accessible),
                                if (rideOptions.acceptCargo) ConditionChip(label: l10n.conditionCargo, icon: Icons.luggage),
                              ],
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Time Selection Section
        Opacity(
          opacity: isInputDisabled ? 0.6 : 1.0,
          child: Card(
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
                                : null, // Use default color to match Ride Options
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
        ),
        const SizedBox(height: 24),

        // Request Button
        ElevatedButton(
          onPressed: (!isInputDisabled && 
                      _fromController.text.isNotEmpty && 
                      _toController.text.isNotEmpty && 
                      _fromController.text.isNotEmpty && 
                      _toController.text.isNotEmpty && 
                      // _rideOptions != null && // Always have default options now
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
    final isConnected = ref.watch(isConnectedProvider);
    final vehicleTypesAsync = ref.watch(vehicleTypesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Status Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                isConnected
                    ? const PulsingGreenDot(size: 12)
                    : SizedBox(
                        width: 36,
                        height: 36,
                        child: Center(
                          child: Icon(Icons.wifi_off, color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.driverModeLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        isConnected
                            ? l10n.lookingForRidesMessage
                            : l10n.offlineRefreshMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isConnected ? null : Theme.of(context).colorScheme.error,
                            ),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
                              Icon(Icons.directions_car, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: vehicleTypesAsync.when(
                                  data: (types) {
                                    final isZh = Localizations.localeOf(context).languageCode == 'zh';
                                    final names = ride.requestedVehicleTypeIds.map((id) {
                                      final type = types.where((t) => t.id == id).firstOrNull;
                                      return type != null ? (isZh ? type.nameZh : type.nameEn) : id;
                                    }).join(', ');
                                    return Text(names, style: Theme.of(context).textTheme.bodySmall);
                                  },
                                  loading: () => const Text('...'),
                                  error: (_, __) => const Text(''),
                                ),
                              ),
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


}
