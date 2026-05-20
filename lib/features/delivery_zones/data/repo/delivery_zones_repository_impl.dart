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
    required double deliveryFee,
    required double minOrderValue,
    required int minRiderQuantity,
  }) =>
      _ds.createZone(
        name: name,
        nameAr: nameAr,
        deliveryFee: deliveryFee,
        minOrderValue: minOrderValue,
        minRiderQuantity: minRiderQuantity,
      );

  @override
  Future<DeliveryZoneModel> updateZone({
    required String id,
    required String name,
    String? nameAr,
    required double deliveryFee,
    required double minOrderValue,
    required int minRiderQuantity,
    required bool isActive,
  }) =>
      _ds.updateZone(
        id: id,
        name: name,
        nameAr: nameAr,
        deliveryFee: deliveryFee,
        minOrderValue: minOrderValue,
        minRiderQuantity: minRiderQuantity,
        isActive: isActive,
      );

  @override
  Future<void> deleteZone(String id) => _ds.deleteZone(id);
}
