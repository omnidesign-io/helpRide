import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/user_repository.dart';

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
          ],
        ),
      ),
    );
  }
}
