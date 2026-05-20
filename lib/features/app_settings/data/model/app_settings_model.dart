import 'package:equatable/equatable.dart';

class AppSettingsModel extends Equatable {
  final String id;
  final double serviceFeeValue;
  final bool serviceFeeEnabled;
  final int loyaltyMaxPointsPerOrder;
  final int loyaltyReferralBonus;
  final int loyaltyReferralReward;

  const AppSettingsModel({
    required this.id,
    required this.serviceFeeValue,
    required this.serviceFeeEnabled,
    this.loyaltyMaxPointsPerOrder = 0,
    this.loyaltyReferralBonus = 50,
    this.loyaltyReferralReward = 50,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> j) => AppSettingsModel(
        id:                       j['id'] as String,
        serviceFeeValue:          (j['service_fee_value'] as num?)?.toDouble() ?? 0,
        serviceFeeEnabled:        (j['service_fee_enabled'] as bool?) ?? false,
        loyaltyMaxPointsPerOrder: (j['loyalty_max_points_per_order'] as int?) ?? 0,
        loyaltyReferralBonus:     (j['loyalty_referral_bonus'] as int?) ?? 50,
        loyaltyReferralReward:    (j['loyalty_referral_reward'] as int?) ?? 50,
      );

  AppSettingsModel copyWith({
    double? serviceFeeValue,
    bool? serviceFeeEnabled,
    int? loyaltyMaxPointsPerOrder,
    int? loyaltyReferralBonus,
    int? loyaltyReferralReward,
  }) =>
      AppSettingsModel(
        id:                       id,
        serviceFeeValue:          serviceFeeValue ?? this.serviceFeeValue,
        serviceFeeEnabled:        serviceFeeEnabled ?? this.serviceFeeEnabled,
        loyaltyMaxPointsPerOrder: loyaltyMaxPointsPerOrder ?? this.loyaltyMaxPointsPerOrder,
        loyaltyReferralBonus:     loyaltyReferralBonus ?? this.loyaltyReferralBonus,
        loyaltyReferralReward:    loyaltyReferralReward ?? this.loyaltyReferralReward,
      );

  @override
  List<Object?> get props => [id, serviceFeeValue, serviceFeeEnabled, loyaltyMaxPointsPerOrder, loyaltyReferralBonus, loyaltyReferralReward];
}
