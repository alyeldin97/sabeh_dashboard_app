import '../model/popup_ad_model.dart';

abstract class PopupAdsDataSource {
  Future<List<PopupAdModel>> getAll();
  Future<PopupAdModel> create({required Map<String, dynamic> data});
  Future<PopupAdModel> update({required String id, required Map<String, dynamic> data});
  Future<void> delete({required String id});
}
