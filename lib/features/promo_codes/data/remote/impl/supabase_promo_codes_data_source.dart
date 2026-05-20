import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../../core/utils/app_logger.dart';
import '../promo_codes_data_source.dart';
import '../../model/promo_code_model.dart';

class SupabasePromoCodesDataSource implements PromoCodesDataSource {
  static const _tag = 'PromoCodesDataSource';
  final SupabaseClient _client;
  SupabasePromoCodesDataSource(this._client);

  @override
  Future<List<PromoCodeModel>> getAll() async {
    AppLogger.net(_tag, 'getAll');
    try {
      final rows = await _client.from('promo_codes').select().order('created_at', ascending: false);
      final result = (rows as List)
          .map((r) => PromoCodeModel.fromJson(r as Map<String, dynamic>))
          .toList();
      AppLogger.i(_tag, 'getAll → ${result.length} promo codes');
      return result;
    } catch (e, st) {
      AppLogger.e(_tag, 'getAll failed', e, st);
      rethrow;
    }
  }

  @override
  Future<PromoCodeModel> create({required Map<String, dynamic> data}) async {
    AppLogger.net(_tag, 'create', data['code']);
    try {
      final row = await _client.from('promo_codes').insert(data).select().single();
      AppLogger.i(_tag, 'create success');
      return PromoCodeModel.fromJson(row);
    } catch (e, st) {
      AppLogger.e(_tag, 'create failed', e, st);
      rethrow;
    }
  }

  @override
  Future<PromoCodeModel> update({required String id, required Map<String, dynamic> data}) async {
    AppLogger.net(_tag, 'update', 'id=$id');
    try {
      final row = await _client.from('promo_codes').update(data).eq('id', id).select().single();
      AppLogger.i(_tag, 'update success');
      return PromoCodeModel.fromJson(row);
    } catch (e, st) {
      AppLogger.e(_tag, 'update failed', e, st);
      rethrow;
    }
  }

  @override
  Future<void> delete({required String id}) async {
    AppLogger.net(_tag, 'delete', 'id=$id');
    try {
      await _client.from('promo_codes').delete().eq('id', id);
      AppLogger.i(_tag, 'delete success');
    } catch (e, st) {
      AppLogger.e(_tag, 'delete failed', e, st);
      rethrow;
    }
  }
}
