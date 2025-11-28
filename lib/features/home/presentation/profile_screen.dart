import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import '../repository/user_repository.dart';
import 'package:helpride/features/rides/repository/ride_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:helpride/core/providers/session_provider.dart';

import 'package:helpride/features/auth/repository/auth_repository.dart';
import 'package:helpride/core/presentation/widgets/phone_input_widget.dart';
import 'package:country_picker/country_picker.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _usernameController = TextEditingController();
  final _telegramController = TextEditingController();
  String? _phoneNumber;
  String _countryCode = '852';
  String _numberBody = '';
  
  bool _isLoading = true;
  bool _hasActiveRide = false;
  DateTime? _lastUsernameChange;
  String? _originalUsername;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final session = ref.read(sessionProvider);
    if (session == null) return;
    
    // 1. Check Active Rides
    final activeRides = await ref.read(rideRepositoryProvider).streamRiderRides(session.uid).first;
    _hasActiveRide = activeRides.any((r) => r.isActive);

    // 2. Load User Data
    final userDoc = await ref.read(userRepositoryProvider).getUser(session.uid);
    if (userDoc.exists) {
      final data = userDoc.data()!;
      _usernameController.text = data['username'] ?? '';
      _originalUsername = data['username'];
      _telegramController.text = data['telegramHandle'] ?? '';
      _phoneNumber = session.phoneNumber;
      
      _parsePhoneNumber(_phoneNumber);

      if (data['lastUsernameChange'] != null) {
        _lastUsernameChange = (data['lastUsernameChange'] as Timestamp).toDate();
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _parsePhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return;
    
    // Remove '+' if present
    String cleanPhone = phone.startsWith('+') ? phone.substring(1) : phone;
    
    // Try to find matching country code
    // This is a simple heuristic. For production, use libphonenumber.
    // We iterate through countries and check if phone starts with their code.
    // We prioritize longer codes to avoid partial matches (e.g. 1 vs 1242)
    // But CountryService might not be sorted.
    
    // For MVP, we'll try to match against the default (852) first, then iterate.
    if (cleanPhone.startsWith('852')) {
      _countryCode = '852';
      _numberBody = cleanPhone.substring(3);
      return;
    }

    final countries = CountryService().getAll();
    // Sort by phone code length descending to match longest prefix first
    countries.sort((a, b) => b.phoneCode.length.compareTo(a.phoneCode.length));

    for (final country in countries) {
      if (cleanPhone.startsWith(country.phoneCode)) {
        _countryCode = country.phoneCode;
        _numberBody = cleanPhone.substring(country.phoneCode.length);
        return;
      }
    }
    
    // Fallback
    _numberBody = cleanPhone;
  }

  bool get _canChangeUsername {
    if (_lastUsernameChange == null) return true;
    final timeSinceChange = DateTime.now().difference(_lastUsernameChange!);
    return timeSinceChange.inHours >= 1;
  }

  String get _timeRemaining {
    if (_lastUsernameChange == null) return '';
    final timeSinceChange = DateTime.now().difference(_lastUsernameChange!);
    final remaining = const Duration(hours: 1) - timeSinceChange;
    return '${remaining.inMinutes}m';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _telegramController.dispose();
    super.dispose();
  }

  bool _validateUsername(String username) {
    if (username.isEmpty) return false;
    if (username.length > 20) return false;
    // Allow letters, numbers, Chinese characters, and single spaces
    final regex = RegExp(r'^[a-zA-Z0-9\u4e00-\u9fa5]+( [a-zA-Z0-9\u4e00-\u9fa5]+)*$');
    return regex.hasMatch(username);
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;
    if (_usernameController.text.isEmpty) return;
    
    if (!_validateUsername(_usernameController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.usernameValidationError)),
      );
      return;
    }
    
    final session = ref.read(sessionProvider);
    if (session == null) return;

    setState(() => _isLoading = true);

    try {
      final isUsernameChanged = _usernameController.text != _originalUsername;

      await ref.read(userRepositoryProvider).updateProfile(
            uid: session.uid,
            username: _usernameController.text,
            telegramHandle: _telegramController.text.isNotEmpty 
                ? _telegramController.text 
                : null,
            isUsernameChanged: isUsernameChanged,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileUpdatedMessage)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    try {
      await ref.read(authRepositoryProvider).signOut();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccountTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.deleteAccountMessage),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: l10n.deleteAccountConfirmation,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () {
              if (controller.text == l10n.deleteConfirmationKeyword) {
                Navigator.pop(context, true);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.deleteAccountButton),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _executeAccountDeletion();
    }
  }

  Future<void> _executeAccountDeletion() async {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.read(sessionProvider);
    if (session == null) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(userRepositoryProvider).deleteAccount(session.uid);
      
      // Clear session and redirect
      await ref.read(sessionProvider.notifier).clearSession();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: _hasActiveRide
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  l10n.cannotEditProfileError,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phone Number (Read-only)
                    PhoneInputWidget(
                      initialCountryCode: _countryCode,
                      initialPhoneNumber: _numberBody,
                      enabled: false,
                      onChanged: (_) {},
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                      child: Text(
                        l10n.phoneInfoText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),

                    Semantics(
                      label: l10n.usernameLabel,
                      child: TextField(
                        key: const Key('profile_username_input'),
                        controller: _usernameController,
                        enabled: _canChangeUsername,
                        decoration: InputDecoration(
                          labelText: l10n.usernameLabel,
                          border: const OutlineInputBorder(),
                          helperText: !_canChangeUsername 
                              ? l10n.usernameChangeCooldownError(_timeRemaining)
                              : null, // Removed generic limit error in favor of info text
                          helperStyle: TextStyle(
                            color: !_canChangeUsername ? Colors.red : null,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        l10n.usernameInfoText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Semantics(
                      label: l10n.telegramHandleLabel,
                      child: TextField(
                        key: const Key('profile_telegram_input'),
                        controller: _telegramController,
                        decoration: InputDecoration(
                          labelText: l10n.telegramHandleLabel,
                          border: const OutlineInputBorder(),
                          prefixText: '@',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        l10n.telegramInfoText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        key: const Key('profile_save_button'),
                        onPressed: _saveProfile,
                        child: Text(l10n.saveProfileButton),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _logout,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: Text(l10n.logoutButton),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _confirmDeleteAccount,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: Text(l10n.deleteAccountButton),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.privacyInfoText,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
