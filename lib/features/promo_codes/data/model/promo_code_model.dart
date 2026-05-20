import 'package:equatable/equatable.dart';

enum PromoType {
  percentage,
  fixed,
  bogo,
  freeDelivery;

  static PromoType fromString(String v) {
    switch (v) {
      case 'percentage':    return PromoType.percentage;
      case 'fixed':         return PromoType.fixed;
      case 'bogo':          return PromoType.bogo;
      case 'free_delivery': return PromoType.freeDelivery;
      default:              return PromoType.fixed;
    }
  }

  String get value {
    switch (this) {
      case PromoType.percentage:   return 'percentage';
      case PromoType.fixed:        return 'fixed';
      case PromoType.bogo:         return 'bogo';
      case PromoType.freeDelivery: return 'free_delivery';
    }
  }

  String get label {
    switch (this) {
      case PromoType.percentage:   return '% Discount';
      case PromoType.fixed:        return 'Fixed Discount';
      case PromoType.bogo:         return 'BOGO';
      case PromoType.freeDelivery: return 'Free Delivery';
    }
  }

  bool get hasDiscountValue =>
      this == PromoType.percentage || this == PromoType.fixed;
}

class PromoCodeModel extends Equatable {
  final String id;
  final String code;
  final PromoType type;
  final double discountValue;
  final double minOrder;
  final int? maxUses;
  final int usedCount;
  final DateTime? expiresAt;
  final DateTime? startsAt;
  final bool isActive;
  final String? description;
  final int maxUsesPerUser;

  const PromoCodeModel({
    required this.id,
    required this.code,
    required this.type,
    this.discountValue = 0,
    this.minOrder = 0,
    this.maxUses,
    this.usedCount = 0,
    this.expiresAt,
    this.startsAt,
    this.isActive = true,
    this.description,
    this.maxUsesPerUser = 1,
  });

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  bool get hasStarted =>
      startsAt == null || startsAt!.isBefore(DateTime.now());

  bool get isUsable => isActive && !isExpired && hasStarted &&
      (maxUses == null || usedCount < maxUses!);

  factory PromoCodeModel.fromJson(Map<String, dynamic> j) => PromoCodeModel(
        id:             j['id'] as String,
        code:           j['code'] as String,
        type:           PromoType.fromString(j['discount_type'] as String? ?? 'fixed'),
        discountValue:  (j['discount_value'] as num?)?.toDouble() ?? 0,
        minOrder:       (j['min_order'] as num?)?.toDouble() ?? 0,
        maxUses:        j['max_uses'] as int?,
        usedCount:      j['used_count'] as int? ?? 0,
        expiresAt:      j['expires_at'] != null ? DateTime.tryParse(j['expires_at'] as String) : null,
        startsAt:       j['starts_at'] != null ? DateTime.tryParse(j['starts_at'] as String) : null,
        isActive:       j['is_active'] as bool? ?? true,
        description:    j['description'] as String?,
        maxUsesPerUser: j['max_uses_per_user'] as int? ?? 1,
      );

  Map<String, dynamic> toInsertJson() => {
        'code':              code,
        'discount_type':     type.value,
        'discount_value':    discountValue,
        'min_order':         minOrder,
        'max_uses':          maxUses,
        'expires_at':        expiresAt?.toIso8601String(),
        'starts_at':         startsAt?.toIso8601String(),
        'is_active':         isActive,
        'description':       description,
        'max_uses_per_user': maxUsesPerUser,
      };

  PromoCodeModel copyWith({
    String? code,
    PromoType? type,
    double? discountValue,
    double? minOrder,
    int? maxUses,
    DateTime? expiresAt,
    DateTime? startsAt,
    bool? isActive,
    String? description,
    int? maxUsesPerUser,
  }) =>
      PromoCodeModel(
        id:             id,
        code:           code            ?? this.code,
        type:           type            ?? this.type,
        discountValue:  discountValue   ?? this.discountValue,
        minOrder:       minOrder        ?? this.minOrder,
        maxUses:        maxUses         ?? this.maxUses,
        usedCount:      usedCount,
        expiresAt:      expiresAt       ?? this.expiresAt,
        startsAt:       startsAt        ?? this.startsAt,
        isActive:       isActive        ?? this.isActive,
        description:    description     ?? this.description,
        maxUsesPerUser: maxUsesPerUser  ?? this.maxUsesPerUser,
      );

  @override
  List<Object?> get props =>
      [id, code, type, discountValue, minOrder, maxUses, usedCount, expiresAt, startsAt, isActive, description, maxUsesPerUser];
}
