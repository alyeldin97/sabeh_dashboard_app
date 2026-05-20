part of 'app_settings_cubit.dart';

enum AppSettingsStatus { initial, loading, loaded, saving, failure }

class AppSettingsState extends Equatable {
  final AppSettingsStatus status;
  final AppSettingsModel? settings;
  final String? errorMessage;

  const AppSettingsState({
    this.status = AppSettingsStatus.initial,
    this.settings,
    this.errorMessage,
  });

  AppSettingsState copyWith({
    AppSettingsStatus? status,
    AppSettingsModel? settings,
    String? errorMessage,
  }) =>
      AppSettingsState(
        status: status ?? this.status,
        settings: settings ?? this.settings,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, settings, errorMessage];
}
