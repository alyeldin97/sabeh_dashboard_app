import '../model/delivery_zone_model.dart';

abstract class DeliveryZonesRepository {
  Future<List<DeliveryZoneModel>> getZones();
  Future<DeliveryZoneModel> createZone({
    required String name,
    String? nameAr,
    required double deliveryFee,
    required double minOrderValue,
    required int minRiderQuantity,
  });
  Future<DeliveryZoneModel> updateZone({
    required String id,
    required String name,
    String? nameAr,
    required double deliveryFee,
    required double minOrderValue,
    required int minRiderQuantity,
    required bool isActive,
  });
  Future<void> deleteZone(String id);
}
