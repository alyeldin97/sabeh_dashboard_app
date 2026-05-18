import '../model/category.dart';

abstract class CategoriesRepository {
  Future<List<Category>> getCategories({String? branchId});
  Future<Category> createCategory(Map<String, dynamic> data, List<String> branchIds);
  Future<Category> updateCategory({required String id, required Map<String, dynamic> data, required List<String> branchIds});
  Future<void> deleteCategory({required String id});
  Future<void> updateSortOrders(List<({String id, int sortOrder})> updates);
}
