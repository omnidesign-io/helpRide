import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../repository/user_repository.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const ProfileScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _usernameController = TextEditingController();
  final _telegramController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // In a real app, we might want to fetch this from the provider or pass it in.
    // For now, let's just listen to the stream in the build or fetch once.
    // Simplified: relying on user to input or pre-fill if we had state.
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _telegramController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_usernameController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(userRepositoryProvider).updateProfile(
            phoneNumber: widget.phoneNumber,
            username: _usernameController.text,
            telegramHandle: _telegramController.text.isNotEmpty 
                ? _telegramController.text 
                : null,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Updated')),
        );
        context.go('/'); // Go back home
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
    
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username (Required)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _telegramController,
              decoration: const InputDecoration(
                labelText: 'Telegram Handle (Optional)',
                border: OutlineInputBorder(),
                prefixText: '@',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading 
                    ? const CircularProgressIndicator() 
                    : const Text('Save Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
