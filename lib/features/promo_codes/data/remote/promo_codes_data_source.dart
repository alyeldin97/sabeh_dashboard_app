import '../model/promo_code_model.dart';

abstract class PromoCodesDataSource {
  Future<List<PromoCodeModel>> getAll();
  Future<PromoCodeModel> create({required Map<String, dynamic> data});
  Future<PromoCodeModel> update({required String id, required Map<String, dynamic> data});
  Future<void> delete({required String id});
}
