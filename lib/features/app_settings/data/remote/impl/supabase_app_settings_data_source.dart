import 'package:supabase_flutter/supabase_flutter.dart';
import '../../model/app_settings_model.dart';
import '../app_settings_data_source.dart';

class SupabaseAppSettingsDataSource implements AppSettingsDataSource {
  final SupabaseClient _client;
  SupabaseAppSettingsDataSource(this._client);

  @override
  Future<AppSettingsModel> getSettings() async {
    final row = await _client
        .from('app_settings')
        .select()
        .limit(1)
        .single();
    return AppSettingsModel.fromJson(row);
  }

  @override
  Future<AppSettingsModel> updateSettings(AppSettingsModel settings) async {
    final row = await _client
        .from('app_settings')
        .update({
          'service_fee_value':             settings.serviceFeeValue,
          'service_fee_enabled':           settings.serviceFeeEnabled,
          'loyalty_max_points_per_order':  settings.loyaltyMaxPointsPerOrder,
          'loyalty_referral_bonus':        settings.loyaltyReferralBonus,
          'loyalty_referral_reward':       settings.loyaltyReferralReward,
          'updated_at':                    DateTime.now().toIso8601String(),
        })
        .eq('id', settings.id)
        .select()
        .single();
    return AppSettingsModel.fromJson(row);
  }
}
