import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import '../repository/user_repository.dart';
import 'package:helpride/features/rides/repository/ride_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:helpride/core/providers/session_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _usernameController = TextEditingController();
  final _telegramController = TextEditingController();
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
      
      if (data['lastUsernameChange'] != null) {
        _lastUsernameChange = (data['lastUsernameChange'] as Timestamp).toDate();
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
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

  Future<void> _saveProfile() async {
    if (_usernameController.text.isEmpty) return;
    
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
          SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdatedMessage)),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfileTitle)),
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
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            : l10n.usernameChangeLimitError,
                        helperStyle: TextStyle(
                          color: !_canChangeUsername ? Colors.red : null,
                        ),
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
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      key: const Key('profile_save_button'),
                      onPressed: _saveProfile,
                      child: Text(l10n.saveProfileButton),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
