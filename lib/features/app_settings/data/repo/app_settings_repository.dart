import '../model/app_settings_model.dart';

abstract class AppSettingsRepository {
  Future<AppSettingsModel> getSettings();
  Future<AppSettingsModel> updateSettings(AppSettingsModel settings);
}
