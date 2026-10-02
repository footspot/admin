import 'package:flutter/material.dart';
import 'package:fs_sa/data/services/supabase_client.dart';
import 'package:fs_sa/presentation/utils/local_authentication.dart';
import 'package:fs_sa/presentation/widgets/notification_banner.dart';
import 'package:go_router/go_router.dart';

final authCtrler = AuthController();

class AuthController with LocalAuth {
  static final AuthController _singleton = AuthController._privateConstructor();
  factory AuthController() => _singleton;
  AuthController._privateConstructor();

  late BuildContext context;
  late Function setState;

  init(initSetState, initContext) {
    setState = initSetState;
    context = initContext;
  }

  signIn(String email, String pwd) async {
    if (email.isEmpty || pwd.isEmpty) return;

    try {
      if (await authenticate() == false ||
          email != 'kalilou.conte@footspot.co') {
        context.showErrorNotification('Authentication Failed');

        return;
      }

      final res = await api.supabase.auth.signInWithPassword(
        email: email,
        password: pwd,
      );

      if (res.user != null) {
        context.go('/home');
      } else {
        context.showErrorNotification('Login error');
      }
    } catch (e) {
      context.showErrorNotification(e.toString());

      return;
    }
  }

  is2faSettedUp() {}
}
