import 'package:equatable/equatable.dart';

enum OrderType {
  normal,
  compensation;

  static OrderType fromString(String v) {
    switch (v) {
      case 'compensation': return OrderType.compensation;
      default:             return OrderType.normal;
    }
  }

  String get value => name;

  String get label {
    switch (this) {
      case OrderType.normal:       return 'Normal';
      case OrderType.compensation: return 'Compensation';
    }
  }
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  prepared,
  outForDelivery,
  delivered,
  cancelled,
  rejected;

  static OrderStatus fromString(String v) {
    switch (v) {
      case 'confirmed':        return OrderStatus.confirmed;
      case 'preparing':        return OrderStatus.preparing;
      case 'prepared':         return OrderStatus.prepared;
      case 'out_for_delivery': return OrderStatus.outForDelivery;
      case 'delivered':        return OrderStatus.delivered;
      case 'cancelled':        return OrderStatus.cancelled;
      case 'rejected':         return OrderStatus.rejected;
      default:                 return OrderStatus.pending;
    }
  }

  String get value {
    switch (this) {
      case OrderStatus.pending:        return 'pending';
      case OrderStatus.confirmed:      return 'confirmed';
      case OrderStatus.preparing:      return 'preparing';
      case OrderStatus.prepared:       return 'prepared';
      case OrderStatus.outForDelivery: return 'out_for_delivery';
      case OrderStatus.delivered:      return 'delivered';
      case OrderStatus.cancelled:      return 'cancelled';
      case OrderStatus.rejected:       return 'rejected';
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.pending:        return 'Pending';
      case OrderStatus.confirmed:      return 'Confirmed';
      case OrderStatus.preparing:      return 'Preparing';
      case OrderStatus.prepared:       return 'Prepared';
      case OrderStatus.outForDelivery: return 'Out for Delivery';
      case OrderStatus.delivered:      return 'Delivered';
      case OrderStatus.cancelled:      return 'Cancelled';
      case OrderStatus.rejected:       return 'Rejected';
    }
  }

  bool get isTerminal =>
      this == OrderStatus.delivered ||
      this == OrderStatus.cancelled ||
      this == OrderStatus.rejected;
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
  final int orderNumber;
  final String? branchId;
  final String? customerId;
  final OrderStatus status;
  final double totalPrice;
  final double userPaidDeliveryFees;
  final double zoneDeliveryFee;
  final double serviceFee;
  final double loyaltyDiscount;
  final double promoDiscount;
  final int pointsRedeemed;
  final int pointsEarned;
  final String paymentMethod;
  final String? deliveryAddress;
  final double? deliveryLat;
  final double? deliveryLng;
  final String? notes;
  final List<OrderItem> items;
  final DateTime createdAt;
  final String? loyaltyCatalogReward;
  final String? spendGoalReward;
  final String? promoCodeUsed;
  final String? driverId;
  final String? driverName;
  final bool isPaid;
  final String? customerPhone;
  final double deposit;
  final String? zoneName;
  final String? zoneId;
  final double maradia;
  final String? staffNote;
  final String? transactionInvoiceImage;
  final OrderType orderType;
  final DateTime statusChangedAt;

  const OrderModel({
    required this.id,
    this.orderNumber = 0,
    this.branchId,
    this.customerId,
    required this.status,
    this.orderType = OrderType.normal,
    required this.totalPrice,
    this.userPaidDeliveryFees = 0,
    this.zoneDeliveryFee = 0,
    this.serviceFee = 0,
    this.loyaltyDiscount = 0,
    this.promoDiscount = 0,
    this.pointsRedeemed = 0,
    this.pointsEarned = 0,
    this.paymentMethod = 'cash',
    this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLng,
    this.notes,
    this.items = const [],
    required this.createdAt,
    this.loyaltyCatalogReward,
    this.spendGoalReward,
    this.promoCodeUsed,
    this.driverId,
    this.driverName,
    this.isPaid = false,
    this.customerPhone,
    this.deposit = 0,
    this.zoneName,
    this.zoneId,
    this.maradia = 0,
    this.staffNote,
    this.transactionInvoiceImage,
    DateTime? statusChangedAt,
  }) : statusChangedAt = statusChangedAt ?? createdAt;

  factory OrderModel.fromJson(Map<String, dynamic> j) {
    // customer phone: may come from a join on customer_profiles
    final cpJoin = j['customer_profiles'] as Map<String, dynamic>?;
    final phone  = j['customer_phone'] as String? ?? cpJoin?['phone'] as String?;

    return OrderModel(
      id:              j['id'] as String,
      orderNumber:     (j['order_number'] as int?) ?? 0,
      branchId:        j['branch_id'] as String?,
      customerId:      j['customer_id'] as String?,
      status:          OrderStatus.fromString(j['status'] as String? ?? 'pending'),
      totalPrice:      (j['total_price'] as num).toDouble(),
      userPaidDeliveryFees: (j['user_paid_delivery_fees'] as num?)?.toDouble() ?? 0,
      zoneDeliveryFee: (j['driver_delivery_cost'] as num?)?.toDouble() ?? 0,
      serviceFee:      (j['service_fee'] as num?)?.toDouble() ?? 0,
      loyaltyDiscount: (j['loyalty_discount'] as num?)?.toDouble() ?? 0,
      promoDiscount:   (j['promo_discount'] as num?)?.toDouble() ?? 0,
      pointsRedeemed:  (j['points_redeemed'] as int?) ?? 0,
      pointsEarned:    (j['points_earned'] as int?) ?? 0,
      paymentMethod:   j['payment_method'] as String? ?? 'cash',
      deliveryAddress: j['delivery_address'] as String?,
      deliveryLat:     (j['delivery_lat'] as num?)?.toDouble(),
      deliveryLng:     (j['delivery_lng'] as num?)?.toDouble(),
      notes:                j['notes'] as String?,
      loyaltyCatalogReward: j['loyalty_catalog_reward'] as String?,
      spendGoalReward:      j['spend_goal_reward'] as String?,
      promoCodeUsed:        j['promo_code_used'] as String?,
      items: (j['order_items'] as List<dynamic>? ?? [])
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt:     DateTime.parse(j['created_at'] as String),
      driverId:      j['driver_id'] as String?,
      driverName:    j['driver_name'] as String?,
      isPaid:        j['is_paid'] as bool? ?? false,
      customerPhone: phone,
      deposit:       (j['deposit'] as num?)?.toDouble() ?? 0,
      zoneName:      j['zone_name'] as String?,
      zoneId:        j['zone_id'] as String?,
      maradia:                   (j['maradia'] as num?)?.toDouble() ?? 0,
      staffNote:                 j['staff_note'] as String?,
      transactionInvoiceImage:   j['transaction_invoice_image'] as String?,
      orderType:                 OrderType.fromString(j['order_type'] as String? ?? 'normal'),
      statusChangedAt:           j['status_changed_at'] != null
          ? DateTime.parse(j['status_changed_at'] as String)
          : null,
    );
  }

  double get amountDue => totalPrice - deposit;

  OrderModel copyWith({
    OrderStatus? status,
    OrderType? orderType,
    String? driverId,
    String? driverName,
    bool clearDriver = false,
    bool? isPaid,
    String? paymentMethod,
    double? deposit,
    String? zoneName,
    String? zoneId,
    double? maradia,
    double? zoneDeliveryFee,
    String? staffNote,
    bool clearStaffNote = false,
    String? transactionInvoiceImage,
    bool clearTransactionInvoiceImage = false,
    DateTime? statusChangedAt,
  }) => OrderModel(
        id:                   id,
        orderNumber:          orderNumber,
        branchId:             branchId,
        customerId:           customerId,
        status:               status ?? this.status,
        orderType:            orderType ?? this.orderType,
        totalPrice:           totalPrice,
        userPaidDeliveryFees: userPaidDeliveryFees,
        zoneDeliveryFee:      zoneDeliveryFee ?? this.zoneDeliveryFee,
        serviceFee:           serviceFee,
        loyaltyDiscount:      loyaltyDiscount,
        promoDiscount:        promoDiscount,
        pointsRedeemed:       pointsRedeemed,
        pointsEarned:         pointsEarned,
        paymentMethod:        paymentMethod ?? this.paymentMethod,
        deliveryAddress:      deliveryAddress,
        deliveryLat:          deliveryLat,
        deliveryLng:          deliveryLng,
        notes:                notes,
        items:                items,
        createdAt:            createdAt,
        loyaltyCatalogReward: loyaltyCatalogReward,
        spendGoalReward:      spendGoalReward,
        promoCodeUsed:        promoCodeUsed,
        driverId:             clearDriver ? null : driverId ?? this.driverId,
        driverName:           clearDriver ? null : driverName ?? this.driverName,
        isPaid:               isPaid ?? this.isPaid,
        customerPhone:        customerPhone,
        deposit:              deposit ?? this.deposit,
        zoneName:             zoneName ?? this.zoneName,
        zoneId:               zoneId ?? this.zoneId,
        maradia:              maradia ?? this.maradia,
        staffNote:            clearStaffNote ? null : staffNote ?? this.staffNote,
        transactionInvoiceImage: clearTransactionInvoiceImage
            ? null
            : transactionInvoiceImage ?? this.transactionInvoiceImage,
        statusChangedAt:      statusChangedAt ?? this.statusChangedAt,
      );

  bool get isCompensation => orderType == OrderType.compensation;

  bool get isCash => paymentMethod == 'cash';
  bool get hasLocation => deliveryLat != null && deliveryLng != null;

  String get paymentLabel {
    switch (paymentMethod) {
      case 'instapay': return 'Instapay / Wallet';
      default:         return 'Cash on Delivery';
    }
  }

  @override
  List<Object?> get props => [
        id, orderNumber, branchId, customerId, status, orderType, totalPrice, loyaltyDiscount,
        promoDiscount, pointsRedeemed, pointsEarned, notes, items, createdAt,
        driverId, driverName, isPaid, customerPhone, deposit, zoneName, staffNote,
        transactionInvoiceImage, statusChangedAt,
      ];
}
