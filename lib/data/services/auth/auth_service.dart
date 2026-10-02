import 'package:fs_sa/data/services/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authService = AuthService();

class AuthService {
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await api.supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
}
