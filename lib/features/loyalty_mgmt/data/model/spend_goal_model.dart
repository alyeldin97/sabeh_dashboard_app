import 'package:equatable/equatable.dart';

class SpendGoalModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final double spendRequired;
  final String rewardType;
  final String? rewardProductId;
  final double rewardDiscountAmount;
  final String icon;
  final bool isActive;
  final int sortOrder;

  const SpendGoalModel({
    required this.id,
    required this.title,
    this.description,
    required this.spendRequired,
    required this.rewardType,
    this.rewardProductId,
    this.rewardDiscountAmount = 0,
    required this.icon,
    required this.isActive,
    required this.sortOrder,
  });

  factory SpendGoalModel.fromJson(Map<String, dynamic> j) => SpendGoalModel(
        id:                   j['id'] as String,
        title:                j['title'] as String,
        description:          j['description'] as String?,
        spendRequired:        (j['spend_required'] as num?)?.toDouble() ?? 0,
        rewardType:           j['reward_type'] as String? ?? 'free_delivery',
        rewardProductId:      j['reward_product_id'] as String?,
        rewardDiscountAmount: (j['reward_discount_amount'] as num?)?.toDouble() ?? 0,
        icon:                 j['icon'] as String? ?? '🎁',
        isActive:             j['is_active'] as bool? ?? true,
        sortOrder:            (j['sort_order'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'title':                 title,
        if (description != null && description!.isNotEmpty) 'description': description,
        'spend_required':        spendRequired,
        'reward_type':           rewardType,
        if (rewardProductId != null) 'reward_product_id': rewardProductId,
        'reward_discount_amount': rewardDiscountAmount,
        'icon':                  icon,
        'is_active':             isActive,
        'sort_order':            sortOrder,
      };

  SpendGoalModel copyWith({
    String? id,
    String? title,
    String? description,
    double? spendRequired,
    String? rewardType,
    String? rewardProductId,
    double? rewardDiscountAmount,
    String? icon,
    bool? isActive,
    int? sortOrder,
  }) =>
      SpendGoalModel(
        id:                   id ?? this.id,
        title:                title ?? this.title,
        description:          description ?? this.description,
        spendRequired:        spendRequired ?? this.spendRequired,
        rewardType:           rewardType ?? this.rewardType,
        rewardProductId:      rewardProductId ?? this.rewardProductId,
        rewardDiscountAmount: rewardDiscountAmount ?? this.rewardDiscountAmount,
        icon:                 icon ?? this.icon,
        isActive:             isActive ?? this.isActive,
        sortOrder:            sortOrder ?? this.sortOrder,
      );

  @override
  List<Object?> get props => [
        id, title, description, spendRequired, rewardType,
        rewardProductId, rewardDiscountAmount, icon, isActive, sortOrder,
      ];
}
