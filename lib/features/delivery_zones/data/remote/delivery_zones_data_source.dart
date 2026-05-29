import '../model/delivery_zone_model.dart';

abstract class DeliveryZonesDataSource {
  Future<List<DeliveryZoneModel>> getZones();
  Future<DeliveryZoneModel> createZone({
    required String name,
    String? nameAr,
    required double userPaidDeliveryFees,
    double deliveryFeesPaidToDriver,
    required double minOrderValue,
    required int minRiderQuantity,
    String? branchId,
  });
  Future<DeliveryZoneModel> updateZone({
    required String id,
    required String name,
    String? nameAr,
    required double userPaidDeliveryFees,
    double deliveryFeesPaidToDriver,
    required double minOrderValue,
    required int minRiderQuantity,
    required bool isActive,
    String? branchId,
  });
  Future<void> deleteZone(String id);
  Future<void> assignZoneBranch(String zoneId, String? branchId);
}
