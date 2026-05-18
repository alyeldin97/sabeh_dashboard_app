import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final DateTime? createdAt;
  final int orderCount;
  final double totalSpent;

  const Customer({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.createdAt,
    this.orderCount = 0,
    this.totalSpent = 0,
  });

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
        id:         j['id'] as String,
        name:       j['full_name'] as String?,
        email:      j['email'] as String?,
        phone:      j['phone'] as String?,
        createdAt:  j['created_at'] != null
            ? DateTime.tryParse(j['created_at'] as String)
            : null,
        orderCount: (j['order_count'] as int?) ?? 0,
        totalSpent: (j['total_spent'] as num?)?.toDouble() ?? 0,
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
  List<Object?> get props => [id, name, email, phone];
}
