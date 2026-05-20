import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../../core/utils/app_logger.dart';
import '../banners_data_source.dart';
import '../../model/banner_model.dart';

class SupabaseBannersDataSource implements BannersDataSource {
  static const _tag = 'BannersDataSource';
  final SupabaseClient _client;
  SupabaseBannersDataSource(this._client);

  @override
  Future<List<BannerModel>> getAll() async {
    AppLogger.net(_tag, 'getAll');
    try {
      final rows = await _client.from('banners').select().order('sort_order');
      final result = (rows as List)
          .map((r) => BannerModel.fromJson(r as Map<String, dynamic>))
          .toList();
      AppLogger.i(_tag, 'getAll → ${result.length} banners');
      return result;
    } catch (e, st) {
      AppLogger.e(_tag, 'getAll failed', e, st);
      rethrow;
    }
  }

  @override
  Future<BannerModel> create({required Map<String, dynamic> data}) async {
    AppLogger.net(_tag, 'create');
    try {
      final row = await _client.from('banners').insert(data).select().single();
      AppLogger.i(_tag, 'create success');
      return BannerModel.fromJson(row);
    } catch (e, st) {
      AppLogger.e(_tag, 'create failed', e, st);
      rethrow;
    }
  }

  @override
  Future<BannerModel> update({required String id, required Map<String, dynamic> data}) async {
    AppLogger.net(_tag, 'update', 'id=$id');
    try {
      final row = await _client.from('banners').update(data).eq('id', id).select().single();
      AppLogger.i(_tag, 'update success');
      return BannerModel.fromJson(row);
    } catch (e, st) {
      AppLogger.e(_tag, 'update failed', e, st);
      rethrow;
    }
  }

  @override
  Future<void> delete({required String id}) async {
    AppLogger.net(_tag, 'delete', 'id=$id');
    try {
      await _client.from('banners').delete().eq('id', id);
      AppLogger.i(_tag, 'delete success');
    } catch (e, st) {
      AppLogger.e(_tag, 'delete failed', e, st);
      rethrow;
    }
  }
}
