// Copy this file to secrets.dart and fill in your Supabase project values.
// secrets.dart is gitignored and must never be committed.
//
// Values are in: Supabase Dashboard → Project Settings → API
class Secrets {
  Secrets._();

  static const String supabaseUrl            = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey        = 'YOUR_ANON_KEY';
  // Required for staff account creation via Admin API — never commit this.
  static const String supabaseServiceRoleKey = '';
}
