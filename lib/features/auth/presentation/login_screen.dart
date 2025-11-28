import 'package:flutter/material.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/auth_repository.dart';
import 'package:helpride/features/home/repository/user_repository.dart';
import 'package:helpride/core/providers/session_provider.dart';

import 'package:helpride/core/presentation/widgets/phone_input_widget.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // final _phoneController = TextEditingController(); // Removed in favor of _fullPhoneNumber
  String _fullPhoneNumber = '';
  final _usernameController = TextEditingController();
  final _telegramController = TextEditingController();
  
  bool _isCaptchaVerified = false;
  bool _isLoading = false;
  bool _isNewUser = false;
  bool _hasCheckedUser = false;

  @override
  void dispose() {
    // _phoneController.dispose();
    _usernameController.dispose();
    _telegramController.dispose();
    super.dispose();
  }

  Future<void> _checkUser() async {
    if (_fullPhoneNumber.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final exists = await authRepo.checkUserExists(_fullPhoneNumber);
      
      setState(() {
        _hasCheckedUser = true;
        _isNewUser = !exists;
      });
      
      if (exists) {
        // If user exists, just log them in (MVP flow)
        final result = await authRepo.login(_fullPhoneNumber);
        final uid = result['uid']!;
        final sessionToken = result['sessionToken'];

        // Use data returned from login, including role
        await ref.read(sessionProvider.notifier).setSession(
            UserSession(
              uid: result['uid']!,
              phoneNumber: _fullPhoneNumber,
              username: result['username'],
              sessionToken: result['sessionToken'],
              role: result['role'] ?? 'rider',
            ),
          );
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

  bool _validateUsername(String username) {
    if (username.isEmpty) return false;
    if (username.length > 20) return false;
    // Allow letters, numbers, Chinese characters, and single spaces
    final regex = RegExp(r'^[a-zA-Z0-9\u4e00-\u9fa5]+( [a-zA-Z0-9\u4e00-\u9fa5]+)*$');
    return regex.hasMatch(username);
  }

  Future<void> _completeSignUp() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (!_validateUsername(_usernameController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.usernameValidationError)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final result = await authRepo.signUp(
        phoneNumber: _fullPhoneNumber,
        username: _usernameController.text,
        telegramHandle: _telegramController.text.isNotEmpty 
            ? _telegramController.text 
            : null,
      );

      final session = UserSession(
        uid: result['uid']!,
        phoneNumber: _fullPhoneNumber,
        sessionToken: result['sessionToken'],
        role: result['role'] ?? 'rider',
        username: result['username'],
      );
      await ref.read(sessionProvider.notifier).setSession(session);

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PhoneInputWidget(
                        enabled: !_hasCheckedUser,
                        onChanged: (phone) {
                          _fullPhoneNumber = phone;
                        },
                      ),
                      if (!_hasCheckedUser)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            l10n.phoneInfoText,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      
                      if (_isNewUser && _hasCheckedUser) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: l10n.usernameLabel,
                            prefixIcon: const Icon(Icons.person),
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
                        TextField(
                          controller: _telegramController,
                          decoration: InputDecoration(
                            labelText: l10n.telegramHandleLabel,
                            prefixIcon: const Icon(Icons.send), // Telegram-ish icon
                            prefixText: '@',
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
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              
              if (!_hasCheckedUser)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                ),
              const SizedBox(height: 24),
              
              if (_hasCheckedUser && _isNewUser)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: OutlinedButton(
                    onPressed: _isLoading 
                        ? null 
                        : () {
                            setState(() {
                              _hasCheckedUser = false;
                              _isNewUser = false;
                            });
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(l10n.backButton),
                  ),
                ),

              ElevatedButton(
                onPressed: _isLoading 
                    ? null 
                    : (_hasCheckedUser && _isNewUser) 
                        ? _completeSignUp 
                        : (_isCaptchaVerified && _fullPhoneNumber.isNotEmpty) 
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
              
              if (_hasCheckedUser && _isNewUser) ...[
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

              if (!_hasCheckedUser) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () async {
                    if (_fullPhoneNumber.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.enterPhoneFirstError)),
                      );
                      return;
                    }
                    try {
                      final authRepo = ref.read(authRepositoryProvider);
                      await authRepo.signInWithGoogleAndClaimAdmin(_fullPhoneNumber);
                      
                      // After claiming admin, we need to fetch the user to get the UID
                      // Since signInWithGoogleAndClaimAdmin doesn't return it, we use login or getUserByPhone
                      final result = await authRepo.login(_fullPhoneNumber);
                      final uid = result['uid']!;
                      final sessionToken = result['sessionToken'];

                      // Use data returned from login, including role
                      await ref.read(sessionProvider.notifier).setSession(
                            UserSession(
                              uid: uid,
                              phoneNumber: _fullPhoneNumber,
                              username: result['username'],
                              sessionToken: sessionToken,
                              role: result['role'] ?? 'rider',
                            ),
                          );
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
      ),
    );
  }
}
