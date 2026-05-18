import '../model/product.dart';
import '../remote/products_data_source.dart';
import 'products_repository.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsDataSource _ds;
  ProductsRepositoryImpl(this._ds);

  @override
  Future<List<Product>> getProducts({String? branchId, String? categoryId}) =>
      _ds.getProducts(branchId: branchId, categoryId: categoryId);

  @override
  Future<Product> createProduct({
    required Map<String, dynamic> fields,
    required List<String> branchIds,
    required List<String> categoryIds,
    required List<Map<String, dynamic>> options,
    required List<Map<String, dynamic>> variants,
    required Map<String, int> productInventory,
  }) =>
      _ds.createProduct(
        fields: fields,
        branchIds: branchIds,
        categoryIds: categoryIds,
        options: options,
        variants: variants,
        productInventory: productInventory,
      );

  @override
  Future<Product> updateProduct({
    required String id,
    required Map<String, dynamic> fields,
    required List<String> branchIds,
    required List<String> categoryIds,
    required List<Map<String, dynamic>> options,
    required List<Map<String, dynamic>> variants,
    required Map<String, int> productInventory,
  }) =>
      _ds.updateProduct(
        id: id,
        fields: fields,
        branchIds: branchIds,
        categoryIds: categoryIds,
        options: options,
        variants: variants,
        productInventory: productInventory,
      );

  @override
  Future<void> deleteProduct({required String id}) => _ds.deleteProduct(id: id);
}
