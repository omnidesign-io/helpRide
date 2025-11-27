import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:helpride/features/rides/repository/ride_repository.dart';
import 'package:helpride/features/rides/domain/ride_model.dart';
import 'package:helpride/features/rides/presentation/active_ride_screen.dart';
import 'package:helpride/core/providers/session_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
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
        context.go('/settings');
        break;
    }
  }

  // Sync selected index with current route
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/orders')) {
      _selectedIndex = 1;
    } else if (location.startsWith('/settings')) {
      _selectedIndex = 2;
    } else {
      _selectedIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(sessionProvider);

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: widget.child),
          // Sticky Active Ride Banner
          if (session != null)
            StreamBuilder<List<RideModel>>(
              stream: ref.watch(rideRepositoryProvider).streamRiderRides(session.phoneNumber),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final rides = snapshot.data!;
                
                RideModel? activeRide;
                try {
                  activeRide = rides.firstWhere((r) => r.status != RideStatus.completed && r.status != RideStatus.cancelled);
                } catch (_) {
                  activeRide = null;
                }

                if (activeRide == null) return const SizedBox.shrink();

                return ActiveRideScreen(ride: activeRide, isDriver: false);
              },
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: _onItemTapped,
        selectedIndex: _selectedIndex,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: l10n.homeLabel,
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.history),
            icon: Icon(Icons.history_outlined),
            label: l10n.ordersLabel,
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: l10n.settingsLabel,
          ),
        ],
      ),
    );
  }
}
