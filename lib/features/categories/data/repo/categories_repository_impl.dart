import '../model/category.dart';
import '../remote/categories_data_source.dart';
import 'categories_repository.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesDataSource _ds;
  CategoriesRepositoryImpl(this._ds);

  @override
  Future<List<Category>> getCategories({String? branchId}) => _ds.getCategories(branchId: branchId);

  @override
  Future<Category> createCategory(Map<String, dynamic> data, List<String> branchIds) =>
      _ds.createCategory(data, branchIds);

  @override
  Future<Category> updateCategory({required String id, required Map<String, dynamic> data, required List<String> branchIds}) =>
      _ds.updateCategory(id: id, data: data, branchIds: branchIds);

  @override
  Future<void> deleteCategory({required String id}) => _ds.deleteCategory(id: id);

  @override
  Future<void> updateSortOrders(List<({String id, int sortOrder})> updates) =>
      _ds.updateSortOrders(updates);
}
