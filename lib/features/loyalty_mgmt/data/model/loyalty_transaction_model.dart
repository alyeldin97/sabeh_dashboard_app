import 'package:equatable/equatable.dart';

class LoyaltyTransactionModel extends Equatable {
  final String id;
  final String customerId;
  final String? customerName;
  final String? orderId;
  final int points;
  final String type;
  final String? note;
  final String? description;
  final DateTime? expiresAt;
  final bool isPermanent;
  final DateTime createdAt;

  const LoyaltyTransactionModel({
    required this.id,
    required this.customerId,
    this.customerName,
    this.orderId,
    required this.points,
    required this.type,
    this.note,
    this.description,
    this.expiresAt,
    required this.isPermanent,
    required this.createdAt,
  });

  factory LoyaltyTransactionModel.fromJson(Map<String, dynamic> j) {
    String? customerName;
    final profileData = j['customer_profiles'];
    if (profileData is Map<String, dynamic>) {
      customerName = profileData['name'] as String?;
    }

    return LoyaltyTransactionModel(
      id: j['id'] as String,
      customerId: j['customer_id'] as String,
      customerName: customerName,
      orderId: j['order_id'] as String?,
      points: (j['points'] as num?)?.toInt() ?? 0,
      type: j['type'] as String? ?? 'manual',
      note: j['note'] as String?,
      description: j['description'] as String?,
      expiresAt: j['expires_at'] != null ? DateTime.tryParse(j['expires_at'] as String) : null,
      isPermanent: j['is_permanent'] as bool? ?? false,
      createdAt: DateTime.parse(j['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        orderId,
        points,
        type,
        note,
        description,
        expiresAt,
        isPermanent,
        createdAt,
      ];
}
