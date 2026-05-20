import 'package:equatable/equatable.dart';

class LoyaltyGoalModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final double spendRequired;
  final int pointsRequired;
  final String rewardType;
  final String? rewardProductId;
  final String icon;
  final bool isActive;
  final int sortOrder;

  const LoyaltyGoalModel({
    required this.id,
    required this.title,
    this.description,
    required this.spendRequired,
    required this.pointsRequired,
    required this.rewardType,
    this.rewardProductId,
    required this.icon,
    required this.isActive,
    required this.sortOrder,
  });

  factory LoyaltyGoalModel.fromJson(Map<String, dynamic> j) => LoyaltyGoalModel(
        id: j['id'] as String,
        title: j['title'] as String,
        description: j['description'] as String?,
        spendRequired: (j['spend_required'] as num?)?.toDouble() ?? 0,
        pointsRequired: (j['points_required'] as num?)?.toInt() ?? 0,
        rewardType: j['reward_type'] as String? ?? 'free_delivery',
        rewardProductId: j['reward_product_id'] as String?,
        icon: j['icon'] as String? ?? '🎁',
        isActive: j['is_active'] as bool? ?? true,
        sortOrder: (j['sort_order'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'title':          title,
        if (description != null && description!.isNotEmpty) 'description': description,
        'points_required': pointsRequired,
        'reward_type':    rewardType,
        if (rewardProductId != null) 'reward_product_id': rewardProductId,
        'icon':           icon,
        'is_active':      isActive,
        'sort_order':     sortOrder,
      };

  LoyaltyGoalModel copyWith({
    String? id,
    String? title,
    String? description,
    double? spendRequired,
    int? pointsRequired,
    String? rewardType,
    String? rewardProductId,
    String? icon,
    bool? isActive,
    int? sortOrder,
  }) =>
      LoyaltyGoalModel(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        spendRequired: spendRequired ?? this.spendRequired,
        pointsRequired: pointsRequired ?? this.pointsRequired,
        rewardType: rewardType ?? this.rewardType,
        rewardProductId: rewardProductId ?? this.rewardProductId,
        icon: icon ?? this.icon,
        isActive: isActive ?? this.isActive,
        sortOrder: sortOrder ?? this.sortOrder,
      );

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        spendRequired,
        pointsRequired,
        rewardType,
        rewardProductId,
        icon,
        isActive,
        sortOrder,
      ];
}
