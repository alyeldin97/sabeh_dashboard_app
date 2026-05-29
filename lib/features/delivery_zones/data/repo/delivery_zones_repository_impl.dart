import '../model/delivery_zone_model.dart';
import '../remote/delivery_zones_data_source.dart';
import 'delivery_zones_repository.dart';

class DeliveryZonesRepositoryImpl implements DeliveryZonesRepository {
  final DeliveryZonesDataSource _ds;
  DeliveryZonesRepositoryImpl(this._ds);

  @override
  Future<List<DeliveryZoneModel>> getZones() => _ds.getZones();

  @override
  Future<DeliveryZoneModel> createZone({
    required String name,
    String? nameAr,
    required double userPaidDeliveryFees,
    double deliveryFeesPaidToDriver = 0,
    required double minOrderValue,
    required int minRiderQuantity,
    String? branchId,
  }) =>
      _ds.createZone(
        name: name,
        nameAr: nameAr,
        userPaidDeliveryFees: userPaidDeliveryFees,
        deliveryFeesPaidToDriver: deliveryFeesPaidToDriver,
        minOrderValue: minOrderValue,
        minRiderQuantity: minRiderQuantity,
        branchId: branchId,
      );

  @override
  Future<DeliveryZoneModel> updateZone({
    required String id,
    required String name,
    String? nameAr,
    required double userPaidDeliveryFees,
    double deliveryFeesPaidToDriver = 0,
    required double minOrderValue,
    required int minRiderQuantity,
    required bool isActive,
    String? branchId,
  }) =>
      _ds.updateZone(
        id: id,
        name: name,
        nameAr: nameAr,
        userPaidDeliveryFees: userPaidDeliveryFees,
        deliveryFeesPaidToDriver: deliveryFeesPaidToDriver,
        minOrderValue: minOrderValue,
        minRiderQuantity: minRiderQuantity,
        isActive: isActive,
        branchId: branchId,
      );

  @override
  Future<void> deleteZone(String id) => _ds.deleteZone(id);

  @override
  Future<void> assignZoneBranch(String zoneId, String? branchId) =>
      _ds.assignZoneBranch(zoneId, branchId);
}
