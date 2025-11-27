import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:helpride/core/providers/locale_provider.dart';
import 'package:helpride/core/providers/role_provider.dart';
import 'package:helpride/features/rides/repository/ride_repository.dart';
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
                      context.push('/profile/$currentUserPhone');
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Group 2: Role
                Card(
                  child: SwitchListTile(
                    key: const Key('settings_switch_role_tile'),
                    title: Text(currentRole == UserRole.rider ? l10n.riderLabel : l10n.driverLabel),
                    subtitle: Text(l10n.switchRoleLabel),
                    value: currentRole == UserRole.driver,
                    onChanged: (value) async {
                      // 1. Check for Active Rides
                      final activeRides = await ref.read(rideRepositoryProvider).streamRiderRides(currentUserPhone).first;
                      final hasActiveRide = activeRides.any((r) => r.isActive);
                      
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
                      if (value == true) { // Switching TO Driver
                         final userDoc = await ref.read(userRepositoryProvider).getUser(currentUserPhone);
                         final hasVehicle = userDoc.exists && (userDoc.data() as Map<String, dynamic>)['vehicle'] != null;

                         if (!hasVehicle) {
                           if (context.mounted) {
                             // Show Onboarding
                             final result = await Navigator.of(context).push<bool>(
                               MaterialPageRoute(builder: (_) => DriverOnboardingScreen(phoneNumber: currentUserPhone)),
                             );
                             
                             if (result != true) {
                               // User cancelled onboarding
                               return;
                             }
                           }
                         }
                      }

                      // 3. Proceed with Switch
                      ref.read(roleProvider.notifier).toggleRole();
                    },
                    secondary: const Icon(Icons.swap_horiz),
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
