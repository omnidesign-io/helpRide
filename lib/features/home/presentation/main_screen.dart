import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:helpride/features/rides/repository/ride_repository.dart';
import 'package:helpride/features/rides/domain/ride_model.dart';
import 'package:helpride/features/rides/presentation/active_ride_screen.dart';
import 'package:helpride/core/providers/session_provider.dart';

import 'package:helpride/core/providers/role_provider.dart'; // Added import

class MainScreen extends ConsumerStatefulWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  // Helper to calculate selected index based on route
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/orders')) {
      return 1;
    } else if (location.startsWith('/settings')) { // Assuming /settings is now /profile
      return 2;
    } else {
      return 0;
    }
  }

  // Updated _onItemTapped to match the new signature
  void _onItemTapped(int index, BuildContext context) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/orders');
        break;
      case 2:
        context.go('/settings'); // Assuming /settings is now /profile
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(sessionProvider);
    final currentUserId = session?.uid;
    final currentRole = ref.watch(roleProvider); // Use roleProvider

    // Watch for active rides
    final activeRidesAsync = (currentUserId != null)
        ? (currentRole == UserRole.driver
            ? ref.watch(rideRepositoryProvider).streamDriverRides(currentUserId)
            : ref.watch(rideRepositoryProvider).streamRiderRides(currentUserId))
        : null; // Handle case where session is null

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active Ride Section
          if (activeRidesAsync != null)
            StreamBuilder<List<RideModel>>(
              stream: activeRidesAsync,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }

                // Find the first truly active ride
                final activeRides = snapshot.data!.where((r) => 
                  r.status != RideStatus.completed && 
                  r.status != RideStatus.cancelled
                ).toList();

                if (activeRides.isEmpty) {
                  return const SizedBox.shrink();
                }

                final activeRide = activeRides.first;
                
                // Don't show if we are already on the details screen or active ride screen
                final location = GoRouterState.of(context).uri.toString();
                if (location.contains('/ride-details') || location.contains('/active-ride')) {
                  return const SizedBox.shrink();
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ActiveRideScreen(
                      ride: activeRide,
                      isDriver: currentRole == UserRole.driver,
                    ),
                    Divider(height: 1, thickness: 1, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)),
                  ],
                );
              },
            ),

          // Navigation Bar
          NavigationBar(
            selectedIndex: _calculateSelectedIndex(context),
            onDestinationSelected: (index) => _onItemTapped(index, context),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: l10n.homeLabel,
              ),
              NavigationDestination(
                icon: const Icon(Icons.history_outlined),
                selectedIcon: const Icon(Icons.history),
                label: l10n.ordersLabel,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outlined),
                selectedIcon: const Icon(Icons.person),
                label: l10n.settingsLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
