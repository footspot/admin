import 'package:flutter/widgets.dart';
import 'package:fs_sa/data/services/supabase_client.dart';
import 'package:fs_sa/presentation/widgets/notification_banner.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final settingsCtrler = SettingsController();

class SettingsController {
  static final SettingsController _singleton =
      SettingsController._privateConstructor();
  factory SettingsController() => _singleton;
  SettingsController._privateConstructor();

  late BuildContext context;
  late Function setState;

  init(initSetState, initContext) {
    setState = initSetState;
    context = initContext;
  }

  logOut() async {
    try {
      await api.supabase.auth.signOut(scope: SignOutScope.local);

      context.go('/');
    } catch (e) {
      context.showErrorNotification(title: 'LOG OUT', '$e');
    }
  }
}
