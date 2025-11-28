import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:helpride/core/providers/locale_provider.dart';
import 'package:helpride/core/providers/role_provider.dart';
import 'package:helpride/features/rides/repository/ride_repository.dart';
import 'package:helpride/features/rides/domain/ride_model.dart'; // Added import
import 'package:helpride/features/home/repository/user_repository.dart';
import 'package:helpride/features/home/presentation/driver_onboarding_screen.dart';
import 'package:helpride/core/providers/session_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentRole = ref.watch(roleProvider);
    final session = ref.watch(sessionProvider);
    final currentUserPhone = session?.phoneNumber;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: session == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.loginRequiredMessage,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.go('/login'),
                      child: Text(l10n.goToLoginButton),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Group 1: Profile
                Card(
                  child: ListTile(
                    key: const Key('settings_edit_profile_tile'),
                    leading: const Icon(Icons.person),
                    title: Text(l10n.editProfileTitle),
                    subtitle: Text(currentUserPhone!),
                    onTap: () {
                      context.push('/profile');
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Group 2: Role
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.switchRoleLabel,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        SegmentedButton<UserRole>(
                          segments: [
                            ButtonSegment<UserRole>(
                              value: UserRole.rider,
                              label: Text(l10n.riderLabel),
                              icon: const Icon(Icons.person_outline),
                            ),
                            ButtonSegment<UserRole>(
                              value: UserRole.driver,
                              label: Text(l10n.driverLabel),
                              icon: const Icon(Icons.drive_eta),
                            ),
                          ],
                          selected: {currentRole},
                          onSelectionChanged: (Set<UserRole> newSelection) async {
                            final newRole = newSelection.first;
                            if (newRole == currentRole) return;

                            // 1. Check for Active Rides based on CURRENT role
                            bool hasActiveRide = false;
                            if (currentRole == UserRole.rider) {
                              final activeRides = await ref.read(rideRepositoryProvider).streamRiderRides(session!.uid).first;
                              hasActiveRide = activeRides.any((r) => 
                                r.status != RideStatus.completed && 
                                r.status != RideStatus.cancelled
                              );
                            } else {
                              // Current role is Driver
                              final activeRides = await ref.read(rideRepositoryProvider).streamDriverRides(session!.uid).first;
                              hasActiveRide = activeRides.any((r) => 
                                r.status != RideStatus.completed && 
                                r.status != RideStatus.cancelled
                              );
                            }
                            
                            if (hasActiveRide) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.cannotSwitchRoleError),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              return;
                            }

                            // 2. If Switching to Driver, Check Onboarding
                            if (newRole == UserRole.driver) {
                               final userDoc = await ref.read(userRepositoryProvider).getUser(session.uid);
                               final hasVehicle = userDoc.exists && (userDoc.data() as Map<String, dynamic>)['vehicle'] != null;

                               if (!hasVehicle) {
                                 if (context.mounted) {
                                   // Show Onboarding
                                   final result = await Navigator.of(context).push<bool>(
                                     MaterialPageRoute(builder: (_) => const DriverOnboardingScreen()),
                                   );
                                   
                                   if (result != true) {
                                     // User cancelled onboarding
                                     return;
                                   }
                                 }
                               }
                            }

                            // 3. Proceed with Switch & Persist
                            try {
                              await ref.read(userRepositoryProvider).updateUserRole(session.uid, newRole.name);
                              await ref.read(sessionProvider.notifier).updateRole(newRole.name); // Update local session
                              ref.read(roleProvider.notifier).setRole(newRole);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to update role: $e')),
                                );
                              }
                            }
                          },
                        ),
                        
                        // Vehicle Settings Button (Driver Only)
                        if (currentRole == UserRole.driver) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.settings_applications),
                            title: Text(l10n.vehicleDetailsTitle),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const DriverOnboardingScreen()),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Group 3: Language & About
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: Text(l10n.languageTitle), // "Language / 語言"
                        subtitle: Text(Localizations.localeOf(context).languageCode == 'zh' ? '繁體中文 (香港)' : 'English'),
                        onTap: () => _showLanguageDialog(context, ref),
                      ),
                      const Divider(height: 1, indent: 56, color: Color.fromRGBO(0, 0, 0, 0.12)), // Indent to match text start
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: Text(l10n.aboutTitle),
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: l10n.appTitle,
                            applicationVersion: '1.0.0',
                            applicationLegalese: '© 2024 HelpRide',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        final currentLocale = ref.watch(localeProvider);
        return AlertDialog(
          title: const Text('Select Language / 選擇語言'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('English'),
                value: 'en',
                groupValue: currentLocale.languageCode,
                onChanged: (String? value) {
                  if (value != null) {
                    ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                    Navigator.pop(context);
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('繁體中文 (香港)'),
                value: 'zh',
                groupValue: currentLocale.languageCode,
                onChanged: (String? value) {
                  if (value != null) {
                    ref.read(localeProvider.notifier).setLocale(const Locale('zh', 'HK'));
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
