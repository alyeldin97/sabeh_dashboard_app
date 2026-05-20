import 'package:supabase_flutter/supabase_flutter.dart';
import '../delivery_zones_data_source.dart';
import '../../model/delivery_zone_model.dart';

class SupabaseDeliveryZonesDataSource implements DeliveryZonesDataSource {
  final SupabaseClient _client;
  SupabaseDeliveryZonesDataSource(this._client);

  @override
  Future<List<DeliveryZoneModel>> getZones() async {
    final rows = await _client
        .from('delivery_zones')
        .select()
        .order('name');
    return (rows as List).map((r) => DeliveryZoneModel.fromJson(r as Map<String, dynamic>)).toList();
  }

  @override
  Future<DeliveryZoneModel> createZone({
    required String name,
    String? nameAr,
    required double deliveryFee,
    required double minOrderValue,
    required int minRiderQuantity,
  }) async {
    final row = await _client.from('delivery_zones').insert({
      'name': name,
      if (nameAr != null && nameAr.isNotEmpty) 'name_ar': nameAr,
      'delivery_fee': deliveryFee,
      'min_order_value': minOrderValue,
      'min_rider_quantity': minRiderQuantity,
      'is_active': true,
    }).select().single();
    return DeliveryZoneModel.fromJson(row);
  }

  @override
  Future<DeliveryZoneModel> updateZone({
    required String id,
    required String name,
    String? nameAr,
    required double deliveryFee,
    required double minOrderValue,
    required int minRiderQuantity,
    required bool isActive,
  }) async {
    final row = await _client.from('delivery_zones').update({
      'name': name,
      'name_ar': nameAr?.isNotEmpty == true ? nameAr : null,
      'delivery_fee': deliveryFee,
      'min_order_value': minOrderValue,
      'min_rider_quantity': minRiderQuantity,
      'is_active': isActive,
    }).eq('id', id).select().single();
    return DeliveryZoneModel.fromJson(row);
  }

  @override
  Future<void> deleteZone(String id) async {
    await _client.from('delivery_zones').delete().eq('id', id);
  }
}
