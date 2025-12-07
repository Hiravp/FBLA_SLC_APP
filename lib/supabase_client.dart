// lib/supabase_client.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class Supa {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> init({required String url, required String anonKey}) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  // profile helper (get by auth user id)
  static Future<Map<String, dynamic>?> getProfileByUserId(String userId) async {
    final res = await client
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .limit(1)
        .maybeSingle();
    return res as Map<String,dynamic>?;
  }
}
