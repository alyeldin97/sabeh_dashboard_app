import 'package:equatable/equatable.dart';

class DeliveryZoneModel extends Equatable {
  final String id;
  final String name;
  final String? nameAr;
  final double userPaidDeliveryFees;
  final double deliveryFeesPaidToDriver;
  final double minOrderValue;
  final int minRiderQuantity;
  final bool isActive;
  final String? branchId;

  const DeliveryZoneModel({
    required this.id,
    required this.name,
    this.nameAr,
    required this.userPaidDeliveryFees,
    this.deliveryFeesPaidToDriver = 0,
    required this.minOrderValue,
    required this.minRiderQuantity,
    required this.isActive,
    this.branchId,
  });

  factory DeliveryZoneModel.fromJson(Map<String, dynamic> j) => DeliveryZoneModel(
        id: j['id'] as String,
        name: j['name'] as String,
        nameAr: j['name_ar'] as String?,
        userPaidDeliveryFees: (j['user_paid_delivery_fees'] as num?)?.toDouble() ?? 0,
        deliveryFeesPaidToDriver: (j['delivery_fees_paid_to_driver'] as num?)?.toDouble() ?? 0,
        minOrderValue: (j['min_order_value'] as num?)?.toDouble() ?? 0,
        minRiderQuantity: (j['min_rider_quantity'] as num?)?.toInt() ?? 0,
        isActive: j['is_active'] as bool? ?? true,
        branchId: j['branch_id'] as String?,
      );

  DeliveryZoneModel copyWith({
    String? id,
    String? name,
    String? nameAr,
    double? userPaidDeliveryFees,
    double? deliveryFeesPaidToDriver,
    double? minOrderValue,
    int? minRiderQuantity,
    bool? isActive,
    Object? branchId = _sentinel,
  }) => DeliveryZoneModel(
    id:                       id ?? this.id,
    name:                     name ?? this.name,
    nameAr:                   nameAr ?? this.nameAr,
    userPaidDeliveryFees:     userPaidDeliveryFees ?? this.userPaidDeliveryFees,
    deliveryFeesPaidToDriver: deliveryFeesPaidToDriver ?? this.deliveryFeesPaidToDriver,
    minOrderValue:            minOrderValue ?? this.minOrderValue,
    minRiderQuantity:         minRiderQuantity ?? this.minRiderQuantity,
    isActive:                 isActive ?? this.isActive,
    branchId:                 branchId == _sentinel ? this.branchId : branchId as String?,
  );

  @override
  List<Object?> get props => [id, name, nameAr, userPaidDeliveryFees, deliveryFeesPaidToDriver, minOrderValue, minRiderQuantity, isActive, branchId];
}

const _sentinel = Object();
