import '../model/banner_model.dart';

abstract class BannersRepository {
  Future<List<BannerModel>> getAll();
  Future<BannerModel> create({
    required String imageUrl,
    String? title,
    required bool isActive,
    required int sortOrder,
    required BannerActionType actionType,
    String? actionUrl,
    String? actionProductId,
    String? actionCollectionId,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<BannerModel> update({
    required String id,
    required String imageUrl,
    String? title,
    required bool isActive,
    required int sortOrder,
    required BannerActionType actionType,
    String? actionUrl,
    String? actionProductId,
    String? actionCollectionId,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<void> delete({required String id});
}
