// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  /// Signup and create profile row
  Future<String?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final res = await supabase.auth.signUp(email: email, password: password);

      // success if user is returned
      if (res.user != null) {
        // create profile row (silent; catch errors separately)
        try {
          await supabase.from('profiles').insert({
            'user_id': res.user!.id,
            'display_name': displayName,
            'email': email,
            'points': 0,
            'badges': <String>[],
          });
        } catch (_) {}
        return null;
      }

      // no user -> generic message (avoid accessing res.error property directly)
      return "Signup failed. Check email/password or confirm via email.";
    } catch (e) {
      return e.toString();
    }
  }

  /// Login
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        return null;
      }

      // fallback generic
      return "Login failed. Check your credentials.";
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}
