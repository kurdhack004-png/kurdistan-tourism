import 'package:supabase_flutter/supabase_flutter.dart';

/// Optional Supabase bootstrap.
///
/// The app stays usable without Supabase credentials. In production, provide:
/// --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co
/// --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
class SupabaseService {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get configured => url.isNotEmpty && anonKey.isNotEmpty;

  static Future<void> initialize() async {
    if (!configured) return;
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static SupabaseClient? get client => configured ? Supabase.instance.client : null;
}
