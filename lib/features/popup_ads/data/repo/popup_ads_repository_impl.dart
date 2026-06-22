import '../model/popup_ad_model.dart';
import '../remote/popup_ads_data_source.dart';
import 'popup_ads_repository.dart';

class PopupAdsRepositoryImpl implements PopupAdsRepository {
  final PopupAdsDataSource _ds;
  PopupAdsRepositoryImpl(this._ds);

  @override
  Future<List<PopupAdModel>> getAll() => _ds.getAll();

  @override
  Future<PopupAdModel> create({required Map<String, dynamic> data}) => _ds.create(data: data);

  @override
  Future<PopupAdModel> update({required String id, required Map<String, dynamic> data}) =>
      _ds.update(id: id, data: data);

  @override
  Future<void> delete({required String id}) => _ds.delete(id: id);
}
