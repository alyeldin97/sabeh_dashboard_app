import 'dart:developer' as dev;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../popup_ads_data_source.dart';
import '../../model/popup_ad_model.dart';

class SupabasePopupAdsDataSource implements PopupAdsDataSource {
  final SupabaseClient _client;
  SupabasePopupAdsDataSource(this._client);

  @override
  Future<List<PopupAdModel>> getAll() async {
    dev.log('[PopupAds] getAll → querying popup_ads table', name: 'PopupAds');
    try {
      final rows = await _client.from('popup_ads').select().order('created_at', ascending: false);
      final list = rows.map((r) => PopupAdModel.fromJson(r as Map<String, dynamic>)).toList();
      dev.log('[PopupAds] getAll → loaded ${list.length} ads', name: 'PopupAds');
      return list;
    } catch (e, st) {
      dev.log('[PopupAds] getAll → ERROR: $e', name: 'PopupAds', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<PopupAdModel> create({required Map<String, dynamic> data}) async {
    dev.log('[PopupAds] create → data: $data', name: 'PopupAds');
    try {
      final row = await _client.from('popup_ads').insert(data).select().single();
      final ad = PopupAdModel.fromJson(row);
      dev.log('[PopupAds] create → success id=${ad.id}', name: 'PopupAds');
      return ad;
    } catch (e, st) {
      dev.log('[PopupAds] create → ERROR: $e', name: 'PopupAds', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<PopupAdModel> update({required String id, required Map<String, dynamic> data}) async {
    dev.log('[PopupAds] update → id=$id data=$data', name: 'PopupAds');
    try {
      final row = await _client.from('popup_ads').update(data).eq('id', id).select().single();
      final ad = PopupAdModel.fromJson(row);
      dev.log('[PopupAds] update → success id=${ad.id}', name: 'PopupAds');
      return ad;
    } catch (e, st) {
      dev.log('[PopupAds] update → ERROR: $e', name: 'PopupAds', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> delete({required String id}) async {
    dev.log('[PopupAds] delete → id=$id', name: 'PopupAds');
    try {
      await _client.from('popup_ads').delete().eq('id', id);
      dev.log('[PopupAds] delete → success id=$id', name: 'PopupAds');
    } catch (e, st) {
      dev.log('[PopupAds] delete → ERROR: $e', name: 'PopupAds', error: e, stackTrace: st);
      rethrow;
    }
  }
}
