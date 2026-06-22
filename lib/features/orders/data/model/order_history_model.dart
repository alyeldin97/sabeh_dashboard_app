import 'package:equatable/equatable.dart';

class OrderHistoryModel extends Equatable {
  final String id;
  final String orderId;
  final String action;
  final String? actorId;
  final String? actorName;
  final String? actorRole;
  final DateTime createdAt;

  const OrderHistoryModel({
    required this.id,
    required this.orderId,
    required this.action,
    this.actorId,
    this.actorName,
    this.actorRole,
    required this.createdAt,
  });

  factory OrderHistoryModel.fromJson(Map<String, dynamic> j) => OrderHistoryModel(
        id:        j['id'] as String,
        orderId:   j['order_id'] as String,
        action:    j['action'] as String,
        actorId:   j['actor_id'] as String?,
        actorName: j['actor_name'] as String?,
        actorRole: j['actor_role'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  @override
  List<Object?> get props => [id, orderId, action, actorId, createdAt];
}
