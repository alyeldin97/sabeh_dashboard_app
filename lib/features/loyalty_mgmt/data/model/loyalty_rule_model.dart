import 'package:equatable/equatable.dart';

class LoyaltyRuleModel extends Equatable {
  final String id;
  final String name;
  final String ruleType;
  final double pointsPerEgp;
  final double minOrderValue;
  final String? startTime;
  final String? endTime;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final bool isActive;
  final DateTime createdAt;

  const LoyaltyRuleModel({
    required this.id,
    required this.name,
    required this.ruleType,
    required this.pointsPerEgp,
    required this.minOrderValue,
    this.startTime,
    this.endTime,
    this.validFrom,
    this.validUntil,
    required this.isActive,
    required this.createdAt,
  });

  factory LoyaltyRuleModel.fromJson(Map<String, dynamic> j) => LoyaltyRuleModel(
        id: j['id'] as String,
        name: j['name'] as String,
        ruleType: j['rule_type'] as String? ?? 'base_earn',
        pointsPerEgp: (j['points_per_egp'] as num?)?.toDouble() ?? 0,
        minOrderValue: (j['min_order_value'] as num?)?.toDouble() ?? 0,
        startTime: j['start_time'] as String?,
        endTime: j['end_time'] as String?,
        validFrom: j['valid_from'] != null ? DateTime.tryParse(j['valid_from'] as String) : null,
        validUntil: j['valid_until'] != null ? DateTime.tryParse(j['valid_until'] as String) : null,
        isActive: j['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'rule_type': ruleType,
        'points_per_egp': pointsPerEgp,
        'min_order_value': minOrderValue,
        if (startTime != null) 'start_time': startTime,
        if (endTime != null) 'end_time': endTime,
        if (validFrom != null) 'valid_from': validFrom!.toIso8601String().substring(0, 10),
        if (validUntil != null) 'valid_until': validUntil!.toIso8601String().substring(0, 10),
        'is_active': isActive,
      };

  LoyaltyRuleModel copyWith({
    String? id,
    String? name,
    String? ruleType,
    double? pointsPerEgp,
    double? minOrderValue,
    String? startTime,
    String? endTime,
    DateTime? validFrom,
    DateTime? validUntil,
    bool? isActive,
    DateTime? createdAt,
  }) =>
      LoyaltyRuleModel(
        id: id ?? this.id,
        name: name ?? this.name,
        ruleType: ruleType ?? this.ruleType,
        pointsPerEgp: pointsPerEgp ?? this.pointsPerEgp,
        minOrderValue: minOrderValue ?? this.minOrderValue,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        validFrom: validFrom ?? this.validFrom,
        validUntil: validUntil ?? this.validUntil,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        ruleType,
        pointsPerEgp,
        minOrderValue,
        startTime,
        endTime,
        validFrom,
        validUntil,
        isActive,
        createdAt,
      ];
}
