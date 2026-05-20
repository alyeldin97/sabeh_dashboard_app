import 'secrets.dart';

class AppConfigurations {
  AppConfigurations._();

  static const String supabaseUrl            = Secrets.supabaseUrl;
  static const String supabaseAnonKey        = Secrets.supabaseAnonKey;
  // Requires secrets.dart (gitignored). See secrets.example.dart for setup.
  static const String supabaseServiceRoleKey = Secrets.supabaseServiceRoleKey;
}
