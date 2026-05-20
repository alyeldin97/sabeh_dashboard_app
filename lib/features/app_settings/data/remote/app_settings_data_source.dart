import '../model/app_settings_model.dart';

abstract class AppSettingsDataSource {
  Future<AppSettingsModel> getSettings();
  Future<AppSettingsModel> updateSettings(AppSettingsModel settings);
}
