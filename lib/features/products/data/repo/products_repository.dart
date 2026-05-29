import '../model/product.dart';

abstract class ProductsRepository {
  Future<List<Product>> getProducts({String? branchId, String? categoryId});
  Future<Product> createProduct({
    required Map<String, dynamic> fields,
    required List<String> branchIds,
    required List<String> categoryIds,
    required List<Map<String, dynamic>> options,
    required List<Map<String, dynamic>> variants,
    required Map<String, int> productInventory,
  });
  Future<Product> updateProduct({
    required String id,
    required Map<String, dynamic> fields,
    required List<String> branchIds,
    required List<String> categoryIds,
    required List<Map<String, dynamic>> options,
    required List<Map<String, dynamic>> variants,
    required Map<String, int> productInventory,
  });
  Future<void> updateRelatedProducts({
    required String productId,
    required List<String> relatedIds,
  });
  Future<void> deleteProduct({required String id});
}
