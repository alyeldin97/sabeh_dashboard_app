import 'package:equatable/equatable.dart';

class DeliveryZoneModel extends Equatable {
  final String id;
  final String name;
  final String? nameAr;
  final double deliveryFee;
  final double minOrderValue;
  final int minRiderQuantity;
  final bool isActive;

  const DeliveryZoneModel({
    required this.id,
    required this.name,
    this.nameAr,
    required this.deliveryFee,
    required this.minOrderValue,
    required this.minRiderQuantity,
    required this.isActive,
  });

  factory DeliveryZoneModel.fromJson(Map<String, dynamic> j) => DeliveryZoneModel(
        id: j['id'] as String,
        name: j['name'] as String,
        nameAr: j['name_ar'] as String?,
        deliveryFee: (j['delivery_fee'] as num?)?.toDouble() ?? 0,
        minOrderValue: (j['min_order_value'] as num?)?.toDouble() ?? 0,
        minRiderQuantity: (j['min_rider_quantity'] as num?)?.toInt() ?? 0,
        isActive: j['is_active'] as bool? ?? true,
      );

  @override
  List<Object?> get props => [id, name, nameAr, deliveryFee, minOrderValue, minRiderQuantity, isActive];
}
