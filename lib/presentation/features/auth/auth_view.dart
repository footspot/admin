import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fs_sa/data/services/auth/auth_service.dart';
import 'package:fs_sa/data/services/supabase_client.dart';
import 'package:fs_sa/presentation/core/themes.dart';
import 'package:fs_sa/presentation/features/auth/auth_controller.dart';
import 'package:fs_sa/presentation/features/auth/widgets/sign_in_button.dart';
import 'package:fs_sa/presentation/widgets/notification_banner.dart';
import 'package:go_router/go_router.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final TextEditingController _emailCtrler = TextEditingController();
  final TextEditingController _pwdCtrler = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    authCtrler.init(setState, context);

    final session = api.supabase.auth.currentSession;

    if (session != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Timer(const Duration(milliseconds: 300), () => context.go('/home'));
        }
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    _emailCtrler.dispose();
    _pwdCtrler.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    try {
      // Step 1: Regular email/password auth
      final response = await authService.signInWithEmailPassword(
        _emailCtrler.text,
        _pwdCtrler.text,
      );

      if (response.user != null) context.go('/home');

      // if (response.user != null) {
      //   // Step 2: Check if 2FA is required
      //   final requires2FA = await authService.requiresTwoFactor();

      //   if (requires2FA) {
      //     // Show 2FA verification dialog
      //     _show2FADialog();
      //   } else {
      //     // Proceed to main app
      //     context.go('/');
      //   }
      // }
    } catch (e) {
      context.showErrorNotification('Login failed: $e');
    }
  }

  // ignore: unused_element
  void _show2FADialog() {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text('Enter 2FA Code'),
            content: TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: '123456',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  // * Placeholder validation until 2FA verification is wired up.
                  final isValid = codeController.text.length == 6;

                  if (isValid) {
                    Navigator.pop(context);
                    context.go('/');
                  } else {
                    context.showErrorNotification('Invalid 2FA code');
                  }
                },
                child: Text('Verify'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background-icons.png'),
                fit: BoxFit.cover,
                opacity: 0.5,
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                  child: Container(
                    margin: EdgeInsets.all(12.0),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 22.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 3.0),
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Mr.CEO is back !',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        TextField(
                          controller: _emailCtrler,
                          decoration: InputDecoration(
                            labelText: 'Login',
                            hintText: 'Enter your login',
                            prefixIcon: Icon(Icons.person),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.orange,
                                width: 2.0,
                              ),
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _pwdCtrler,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.orange,
                                width: 2.0,
                              ),
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        SignInButton(onPressed: () => _signIn()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
