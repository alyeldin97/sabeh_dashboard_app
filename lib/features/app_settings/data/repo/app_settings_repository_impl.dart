import '../model/app_settings_model.dart';
import '../remote/app_settings_data_source.dart';
import 'app_settings_repository.dart';

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  final AppSettingsDataSource _ds;
  AppSettingsRepositoryImpl(this._ds);

  @override
  Future<AppSettingsModel> getSettings() => _ds.getSettings();

  @override
  Future<AppSettingsModel> updateSettings(AppSettingsModel settings) =>
      _ds.updateSettings(settings);
}
