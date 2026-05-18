import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  outForDelivery,
  delivered,
  cancelled;

  static OrderStatus fromString(String v) {
    switch (v) {
      case 'confirmed':        return OrderStatus.confirmed;
      case 'preparing':        return OrderStatus.preparing;
      case 'out_for_delivery': return OrderStatus.outForDelivery;
      case 'delivered':        return OrderStatus.delivered;
      case 'cancelled':        return OrderStatus.cancelled;
      default:                 return OrderStatus.pending;
    }
  }

  String get value {
    switch (this) {
      case OrderStatus.pending:        return 'pending';
      case OrderStatus.confirmed:      return 'confirmed';
      case OrderStatus.preparing:      return 'preparing';
      case OrderStatus.outForDelivery: return 'out_for_delivery';
      case OrderStatus.delivered:      return 'delivered';
      case OrderStatus.cancelled:      return 'cancelled';
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.pending:        return 'Pending';
      case OrderStatus.confirmed:      return 'Confirmed';
      case OrderStatus.preparing:      return 'Preparing';
      case OrderStatus.outForDelivery: return 'Out for Delivery';
      case OrderStatus.delivered:      return 'Delivered';
      case OrderStatus.cancelled:      return 'Cancelled';
    }
  }
}

class OrderItem extends Equatable {
  final String id;
  final String orderId;
  final String? productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const OrderItem({
    required this.id,
    required this.orderId,
    this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        id:          j['id'] as String,
        orderId:     j['order_id'] as String,
        productId:   j['product_id'] as String?,
        productName: j['product_name'] as String? ?? '',
        quantity:    j['quantity'] as int,
        unitPrice:   (j['unit_price'] as num).toDouble(),
        subtotal:    (j['subtotal'] as num).toDouble(),
      );

  @override
  List<Object?> get props => [id, orderId, productId, productName, quantity, unitPrice, subtotal];
}

class OrderModel extends Equatable {
  final String id;
  final String branchId;
  final String? customerId;
  final OrderStatus status;
  final double totalPrice;
  final String paymentMethod;
  final String? notes;
  final List<OrderItem> items;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.branchId,
    this.customerId,
    required this.status,
    required this.totalPrice,
    this.paymentMethod = 'cash',
    this.notes,
    this.items = const [],
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
        id:            j['id'] as String,
        branchId:      j['branch_id'] as String,
        customerId:    j['customer_id'] as String?,
        status:        OrderStatus.fromString(j['status'] as String? ?? 'pending'),
        totalPrice:    (j['total_price'] as num).toDouble(),
        paymentMethod: j['payment_method'] as String? ?? 'cash',
        notes:         j['notes'] as String?,
        items: (j['order_items'] as List<dynamic>? ?? [])
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  OrderModel copyWith({OrderStatus? status}) => OrderModel(
        id:            id,
        branchId:      branchId,
        customerId:    customerId,
        status:        status ?? this.status,
        totalPrice:    totalPrice,
        paymentMethod: paymentMethod,
        notes:         notes,
        items:         items,
        createdAt:     createdAt,
      );

  @override
  List<Object?> get props => [id, branchId, customerId, status, totalPrice, notes, items, createdAt];
}
