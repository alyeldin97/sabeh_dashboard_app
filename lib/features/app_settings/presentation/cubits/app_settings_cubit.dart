import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/app_settings_model.dart';
import '../../data/repo/app_settings_repository.dart';

part 'app_settings_state.dart';

class AppSettingsCubit extends Cubit<AppSettingsState> {
  final AppSettingsRepository _repo;

  AppSettingsCubit(this._repo) : super(const AppSettingsState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(status: AppSettingsStatus.loading));
    try {
      final settings = await _repo.getSettings();
      emit(state.copyWith(status: AppSettingsStatus.loaded, settings: settings));
    } catch (e) {
      emit(state.copyWith(status: AppSettingsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> save({
    required double serviceFeeValue,
    required bool serviceFeeEnabled,
    int? loyaltyMaxPointsPerOrder,
    int? loyaltyReferralBonus,
    int? loyaltyReferralReward,
  }) async {
    final current = state.settings;
    if (current == null) return;
    emit(state.copyWith(status: AppSettingsStatus.saving));
    try {
      final updated = await _repo.updateSettings(
        current.copyWith(
          serviceFeeValue:          serviceFeeValue,
          serviceFeeEnabled:        serviceFeeEnabled,
          loyaltyMaxPointsPerOrder: loyaltyMaxPointsPerOrder,
          loyaltyReferralBonus:     loyaltyReferralBonus,
          loyaltyReferralReward:    loyaltyReferralReward,
        ),
      );
      emit(state.copyWith(status: AppSettingsStatus.loaded, settings: updated));
    } catch (e) {
      emit(state.copyWith(status: AppSettingsStatus.failure, errorMessage: e.toString()));
    }
  }
}
