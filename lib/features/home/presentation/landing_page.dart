import 'package:flutter/material.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/user_repository.dart';
import '../../rides/repository/ride_repository.dart';
import '../../rides/domain/ride_model.dart';
import '../../rides/presentation/ride_status_widget.dart';

import 'package:helpride/core/providers/locale_provider.dart';

class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    // Temporary: In a real app, we'd get the current user's phone from state
    // For MVP testing, we might need to store it or ask user to re-enter if session lost
    // Let's assume for now we just navigate to login if no session, 
    // or if we have a session, we'd know the phone.
    // For this specific step, I'll add a temporary text field to simulate "Current User" 
    // or just hardcode a navigation for testing if not logged in.
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              ref.read(localeProvider.notifier).toggleLocale();
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: Get actual logged in phone
              context.push('/profile/+85212345678'); 
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.welcomeMessage,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.push('/login');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(AppLocalizations.of(context)!.loginButton),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                // TODO: Implement Location Update
              },
              child: Text(AppLocalizations.of(context)!.updateLocationButton),
            ),
            const SizedBox(height: 16),
            // Ride Status Section
            StreamBuilder<List<Ride>>(
              stream: ref.watch(rideRepositoryProvider).streamRiderRides('+85212345678'), // Demo Phone
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                
                final rides = snapshot.data ?? [];
                // Filter for active rides (pending, accepted, arrived, in_progress, completed)
                // We show 'completed' so the user can see the final status and close it.
                final activeRide = rides.isNotEmpty && 
                                  ['pending', 'accepted', 'arrived', 'in_progress', 'completed'].contains(rides.first.status)
                                  ? rides.first 
                                  : null;

                if (activeRide != null) {
                  return RideStatusWidget(ride: activeRide);
                }

                return ElevatedButton.icon(
                  onPressed: () {
                    context.push('/request-ride/+85212345678');
                  },
                  icon: const Icon(Icons.local_taxi),
                  label: const Text('Request Ride (Demo)'),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/driver-dashboard/+85212345678');
              },
              icon: const Icon(Icons.drive_eta),
              label: const Text('Driver Dashboard (Demo)'),
            ),
          ],
        ),
      ),
    );
  }
}
