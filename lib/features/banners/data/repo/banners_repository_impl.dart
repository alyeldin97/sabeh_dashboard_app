import '../model/banner_model.dart';
import '../remote/banners_data_source.dart';
import 'banners_repository.dart';

class BannersRepositoryImpl implements BannersRepository {
  final BannersDataSource _dataSource;
  BannersRepositoryImpl(this._dataSource);

  @override
  Future<List<BannerModel>> getAll() => _dataSource.getAll();

  @override
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
  }) =>
      _dataSource.create(data: {
        'image_url':             imageUrl,
        'title':                 title,
        'is_active':             isActive,
        'sort_order':            sortOrder,
        'action_type':           actionType.value,
        'link':                  actionType == BannerActionType.url ? actionUrl : null,
        'action_product_id':     actionType == BannerActionType.product ? actionProductId : null,
        'action_collection_id':  actionType == BannerActionType.collection ? actionCollectionId : null,
        'start_date':            startDate?.toIso8601String(),
        'end_date':              endDate?.toIso8601String(),
      });

  @override
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
  }) =>
      _dataSource.update(id: id, data: {
        'image_url':             imageUrl,
        'title':                 title,
        'is_active':             isActive,
        'sort_order':            sortOrder,
        'action_type':           actionType.value,
        'link':                  actionType == BannerActionType.url ? actionUrl : null,
        'action_product_id':     actionType == BannerActionType.product ? actionProductId : null,
        'action_collection_id':  actionType == BannerActionType.collection ? actionCollectionId : null,
        'start_date':            startDate?.toIso8601String(),
        'end_date':              endDate?.toIso8601String(),
      });

  @override
  Future<void> delete({required String id}) => _dataSource.delete(id: id);
}
