import '../model/banner_model.dart';

abstract class BannersDataSource {
  Future<List<BannerModel>> getAll();
  Future<BannerModel> create({required Map<String, dynamic> data});
  Future<BannerModel> update({required String id, required Map<String, dynamic> data});
  Future<void> delete({required String id});
}
