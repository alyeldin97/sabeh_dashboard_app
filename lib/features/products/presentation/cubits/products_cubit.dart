import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/model/product.dart';
import '../../data/repo/products_repository.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  static const _tag = 'ProductsCubit';
  final ProductsRepository _repo;

  ProductsCubit(this._repo) : super(const ProductsState()) {
    AppLogger.d(_tag, 'init');
  }

  Future<void> load({String? branchId, String? categoryId}) async {
    AppLogger.i(_tag, 'load branchId=$branchId categoryId=$categoryId');
    emit(state.copyWith(status: ProductsStatus.loading));
    try {
      final products = await _repo.getProducts(branchId: branchId, categoryId: categoryId);
      AppLogger.i(_tag, 'load → ${products.length} products');
      emit(state.copyWith(status: ProductsStatus.success, products: products));
    } catch (e, st) {
      AppLogger.e(_tag, 'load failed', e, st);
      emit(state.copyWith(status: ProductsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<bool> create({
    required Map<String, dynamic> fields,
    required List<String> branchIds,
    required List<String> categoryIds,
    required List<Map<String, dynamic>> options,
    required List<Map<String, dynamic>> variants,
    required Map<String, int> productInventory,
    List<String> relatedIds = const [],
    String? branchId,
  }) async {
    AppLogger.i(_tag, 'create name=${fields['name']} branches=${branchIds.length}');
    try {
      final product = await _repo.createProduct(
        fields: fields,
        branchIds: branchIds,
        categoryIds: categoryIds,
        options: options,
        variants: variants,
        productInventory: productInventory,
      );
      if (relatedIds.isNotEmpty) {
        await _repo.updateRelatedProducts(productId: product.id, relatedIds: relatedIds);
      }
      AppLogger.i(_tag, 'create success');
      await load(branchId: branchId);
      return true;
    } catch (e, st) {
      AppLogger.e(_tag, 'create failed', e, st);
      emit(state.copyWith(status: ProductsStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> update({
    required String id,
    required Map<String, dynamic> fields,
    required List<String> branchIds,
    required List<String> categoryIds,
    required List<Map<String, dynamic>> options,
    required List<Map<String, dynamic>> variants,
    required Map<String, int> productInventory,
    List<String> relatedIds = const [],
    String? branchId,
  }) async {
    AppLogger.i(_tag, 'update id=$id branches=${branchIds.length}');
    try {
      await Future.wait([
        _repo.updateProduct(
          id: id,
          fields: fields,
          branchIds: branchIds,
          categoryIds: categoryIds,
          options: options,
          variants: variants,
          productInventory: productInventory,
        ),
        _repo.updateRelatedProducts(productId: id, relatedIds: relatedIds),
      ]);
      AppLogger.i(_tag, 'update success');
      await load(branchId: branchId);
      return true;
    } catch (e, st) {
      AppLogger.e(_tag, 'update failed', e, st);
      emit(state.copyWith(status: ProductsStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> delete({required String id, String? branchId}) async {
    AppLogger.i(_tag, 'delete id=$id');
    try {
      await _repo.deleteProduct(id: id);
      AppLogger.i(_tag, 'delete success');
      await load(branchId: branchId);
      return true;
    } catch (e, st) {
      AppLogger.e(_tag, 'delete failed', e, st);
      emit(state.copyWith(status: ProductsStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }
}
