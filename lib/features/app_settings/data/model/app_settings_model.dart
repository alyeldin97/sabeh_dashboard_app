import 'package:equatable/equatable.dart';

class AppSettingsModel extends Equatable {
  final String id;
  final double serviceFeeValue;
  final bool serviceFeeEnabled;
  final int loyaltyMaxPointsPerOrder;
  final int loyaltyReferralBonus;
  final int loyaltyReferralReward;
  final int onlineWindowMinutes;

  // Late-flag thresholds (minutes) for each status stage
  final int latePendingMinutes;
  final int lateConfirmedMinutes;
  final int latePreparingMinutes;
  final int latePreparedMinutes;
  final int lateOutForDeliveryMinutes;
  final String? whatsappNumber;

  const AppSettingsModel({
    required this.id,
    required this.serviceFeeValue,
    required this.serviceFeeEnabled,
    this.loyaltyMaxPointsPerOrder = 0,
    this.loyaltyReferralBonus = 50,
    this.loyaltyReferralReward = 50,
    this.onlineWindowMinutes = 3,
    this.latePendingMinutes = 30,
    this.lateConfirmedMinutes = 30,
    this.latePreparingMinutes = 30,
    this.latePreparedMinutes = 30,
    this.lateOutForDeliveryMinutes = 60,
    this.whatsappNumber,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> j) => AppSettingsModel(
        id:                          j['id'] as String,
        serviceFeeValue:             (j['service_fee_value'] as num?)?.toDouble() ?? 0,
        serviceFeeEnabled:           (j['service_fee_enabled'] as bool?) ?? false,
        loyaltyMaxPointsPerOrder:    (j['loyalty_max_points_per_order'] as int?) ?? 0,
        loyaltyReferralBonus:        (j['loyalty_referral_bonus'] as int?) ?? 50,
        loyaltyReferralReward:       (j['loyalty_referral_reward'] as int?) ?? 50,
        onlineWindowMinutes:         (j['online_window_minutes'] as int?) ?? 3,
        latePendingMinutes:          (j['late_pending_minutes'] as int?) ?? 30,
        lateConfirmedMinutes:        (j['late_confirmed_minutes'] as int?) ?? 30,
        latePreparingMinutes:        (j['late_preparing_minutes'] as int?) ?? 30,
        latePreparedMinutes:         (j['late_prepared_minutes'] as int?) ?? 30,
        lateOutForDeliveryMinutes:   (j['late_out_for_delivery_minutes'] as int?) ?? 60,
        whatsappNumber:              j['whatsapp_number'] as String?,
      );

  AppSettingsModel copyWith({
    double? serviceFeeValue,
    bool? serviceFeeEnabled,
    int? loyaltyMaxPointsPerOrder,
    int? loyaltyReferralBonus,
    int? loyaltyReferralReward,
    int? onlineWindowMinutes,
    int? latePendingMinutes,
    int? lateConfirmedMinutes,
    int? latePreparingMinutes,
    int? latePreparedMinutes,
    int? lateOutForDeliveryMinutes,
    String? whatsappNumber,
    bool clearWhatsapp = false,
  }) =>
      AppSettingsModel(
        id:                        id,
        serviceFeeValue:           serviceFeeValue ?? this.serviceFeeValue,
        serviceFeeEnabled:         serviceFeeEnabled ?? this.serviceFeeEnabled,
        loyaltyMaxPointsPerOrder:  loyaltyMaxPointsPerOrder ?? this.loyaltyMaxPointsPerOrder,
        loyaltyReferralBonus:      loyaltyReferralBonus ?? this.loyaltyReferralBonus,
        loyaltyReferralReward:     loyaltyReferralReward ?? this.loyaltyReferralReward,
        onlineWindowMinutes:       onlineWindowMinutes ?? this.onlineWindowMinutes,
        latePendingMinutes:        latePendingMinutes ?? this.latePendingMinutes,
        lateConfirmedMinutes:      lateConfirmedMinutes ?? this.lateConfirmedMinutes,
        latePreparingMinutes:      latePreparingMinutes ?? this.latePreparingMinutes,
        latePreparedMinutes:       latePreparedMinutes ?? this.latePreparedMinutes,
        lateOutForDeliveryMinutes: lateOutForDeliveryMinutes ?? this.lateOutForDeliveryMinutes,
        whatsappNumber:            clearWhatsapp ? null : (whatsappNumber ?? this.whatsappNumber),
      );

  @override
  List<Object?> get props => [
        id, serviceFeeValue, serviceFeeEnabled, loyaltyMaxPointsPerOrder,
        loyaltyReferralBonus, loyaltyReferralReward, onlineWindowMinutes,
        latePendingMinutes, lateConfirmedMinutes, latePreparingMinutes,
        latePreparedMinutes, lateOutForDeliveryMinutes, whatsappNumber,
      ];
}
