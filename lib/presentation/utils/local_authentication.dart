import 'package:fs_sa/data/models/objectbox/log.dart';
import 'package:fs_sa/data/services/local/log_local.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

mixin LocalAuth {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      // Check if authentication is available
      final bool canAuthenticate =
          await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) {
        logLocal.addLog(
          LogEntity(
            message: 'Authentication not available',
            source: 'LOCAL AUTH',
          ),
        );
        return false;
      }

      // Perform authentication
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Authenticate to perform sensitive action',
        options: const AuthenticationOptions(
          biometricOnly: false, // Force credentials (not PIN fallback)
          useErrorDialogs: true, // Show system error dialogs
          stickyAuth: true, // Keep auth active when app in background
        ),
      );

      if (didAuthenticate) return true;

      logLocal.addLog(
        LogEntity(message: 'Authentication failed', source: 'LOCAL AUTH'),
      );

      return false;
    } on PlatformException catch (e) {
      logLocal.addLog(
        LogEntity(
          message: 'Error: ${e.message}',
          source: 'local auth PlatformException',
        ),
      );
      return false;
    }
  }
}
