import 'package:flutter/material.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/auth_repository.dart';
import 'package:helpride/features/home/repository/user_repository.dart';
import 'package:helpride/core/providers/session_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _telegramController = TextEditingController();
  
  bool _isCaptchaVerified = false;
  bool _isLoading = false;
  bool _isNewUser = false;
  bool _hasCheckedUser = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _usernameController.dispose();
    _telegramController.dispose();
    super.dispose();
  }

  Future<void> _checkUser() async {
    if (_phoneController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final exists = await authRepo.checkUserExists(_phoneController.text);
      
      setState(() {
        _hasCheckedUser = true;
        _isNewUser = !exists;
      });
      
      if (exists) {
        // If user exists, just log them in (MVP flow)
        await authRepo.login(_phoneController.text);
        final userDoc = await ref.read(userRepositoryProvider).getUser(_phoneController.text);
        final data = userDoc.data();
        if (data != null) {
          await ref.read(sessionProvider.notifier).setSession(
                UserSession(
                  phoneNumber: _phoneController.text,
                  username: data['username'] as String?,
                  sessionToken: data['sessionToken'] as String?,
                ),
              );
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.welcomeBackMessage)),
          );
          context.go('/');
        }
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

  Future<void> _completeSignUp() async {
    final l10n = AppLocalizations.of(context)!;
    if (_usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.usernameLabel)), // Reusing label as error for now or add specific error
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final sessionToken = await authRepo.signUp(
        phoneNumber: _phoneController.text,
        username: _usernameController.text,
        telegramHandle: _telegramController.text.isNotEmpty 
            ? _telegramController.text 
            : null,
      );

      await ref.read(sessionProvider.notifier).setSession(
            UserSession(
              phoneNumber: _phoneController.text,
              username: _usernameController.text,
              sessionToken: sessionToken,
            ),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.accountCreatedMessage)),
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign Up Failed: $e')),
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
      appBar: AppBar(title: Text(l10n.loginButton)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              enabled: !_hasCheckedUser, // Lock phone after check
              decoration: InputDecoration(
                labelText: l10n.phoneNumberLabel,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
            
            if (_isNewUser && _hasCheckedUser) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: l10n.usernameLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _telegramController,
                decoration: InputDecoration(
                  labelText: l10n.telegramHandleLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.send), // Telegram-ish icon
                  prefixText: '@',
                ),
              ),
            ],

            const SizedBox(height: 24),
            // Placeholder for Captcha Widget
            if (!_hasCheckedUser)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _isCaptchaVerified,
                      onChanged: (value) {
                        setState(() {
                          _isCaptchaVerified = value ?? false;
                        });
                      },
                    ),
                    Text(l10n.captchaLabel),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: _isLoading 
                  ? null 
                  : (_hasCheckedUser && _isNewUser) 
                      ? _completeSignUp 
                      : (_isCaptchaVerified && _phoneController.text.isNotEmpty) 
                          ? _checkUser 
                          : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading 
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2)
                    )
                  : Text(_hasCheckedUser ? l10n.signUpButton : l10n.submitButton),
            ),
            
            if (!_hasCheckedUser) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () async {
                  if (_phoneController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.enterPhoneFirstError)),
                    );
                    return;
                  }
                  try {
                    final authRepo = ref.read(authRepositoryProvider);
                    await authRepo.signInWithGoogleAndClaimAdmin(_phoneController.text);
                    final userDoc = await ref.read(userRepositoryProvider).getUser(_phoneController.text);
                    final data = userDoc.data();
                    if (data != null) {
                      await ref.read(sessionProvider.notifier).setSession(
                            UserSession(
                              phoneNumber: _phoneController.text,
                              username: data['username'] as String?,
                              sessionToken: data['sessionToken'] as String?,
                            ),
                          );
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.adminAccessGranted)),
                      );
                      context.go('/');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.adminClaimFailed)),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.security),
                label: Text(l10n.adminLoginButton),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
