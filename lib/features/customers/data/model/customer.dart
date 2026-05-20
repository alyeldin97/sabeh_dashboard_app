import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final DateTime? createdAt;
  final int orderCount;
  final double totalSpent;
  final int loyaltyPoints;
  final String? referralCode;
  final bool isBlocked;
  final String? internalNotes;

  const Customer({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.createdAt,
    this.orderCount = 0,
    this.totalSpent = 0,
    this.loyaltyPoints = 0,
    this.referralCode,
    this.isBlocked = false,
    this.internalNotes,
  });

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
        id:            j['id'] as String,
        name:          j['name'] as String?,
        email:         j['email'] as String?,
        phone:         j['phone'] as String?,
        createdAt:     j['created_at'] != null
            ? DateTime.tryParse(j['created_at'] as String)
            : null,
        orderCount:    (j['order_count'] as int?) ?? 0,
        totalSpent:    (j['total_spent'] as num?)?.toDouble() ?? 0,
        loyaltyPoints: (j['loyalty_points'] as int?) ?? 0,
        referralCode:  j['referral_code'] as String?,
        isBlocked:     j['is_blocked'] as bool? ?? false,
        internalNotes: j['internal_notes'] as String?,
      );

  Customer copyWith({
    String? name,
    String? email,
    String? phone,
    DateTime? createdAt,
    int? orderCount,
    double? totalSpent,
    int? loyaltyPoints,
    String? referralCode,
    bool? isBlocked,
    String? internalNotes,
  }) =>
      Customer(
        id:            id,
        name:          name          ?? this.name,
        email:         email         ?? this.email,
        phone:         phone         ?? this.phone,
        createdAt:     createdAt     ?? this.createdAt,
        orderCount:    orderCount    ?? this.orderCount,
        totalSpent:    totalSpent    ?? this.totalSpent,
        loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
        referralCode:  referralCode  ?? this.referralCode,
        isBlocked:     isBlocked     ?? this.isBlocked,
        internalNotes: internalNotes ?? this.internalNotes,
      );

  String get displayName => name?.isNotEmpty == true ? name! : (email ?? 'Unknown');
  String get initials {
    if (name != null && name!.isNotEmpty) {
      final parts = name!.trim().split(' ');
      if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      return parts[0][0].toUpperCase();
    }
    return email != null && email!.isNotEmpty ? email![0].toUpperCase() : '?';
  }

  @override
  List<Object?> get props => [
        id, name, email, phone, createdAt, orderCount, totalSpent,
        loyaltyPoints, referralCode, isBlocked, internalNotes,
      ];
}
