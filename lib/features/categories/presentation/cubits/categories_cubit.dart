import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/model/category.dart';
import '../../data/repo/categories_repository.dart';

part 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  static const _tag = 'CategoriesCubit';
  final CategoriesRepository _repo;

  CategoriesCubit(this._repo) : super(const CategoriesState()) {
    AppLogger.d(_tag, 'init');
  }

  Future<void> load({String? branchId}) async {
    AppLogger.i(_tag, 'load branchId=$branchId');
    emit(state.copyWith(status: CategoriesStatus.loading));
    try {
      final categories = await _repo.getCategories(branchId: branchId);
      AppLogger.i(_tag, 'load → ${categories.length} categories');
      emit(state.copyWith(status: CategoriesStatus.success, categories: categories));
    } catch (e, st) {
      AppLogger.e(_tag, 'load failed', e, st);
      emit(state.copyWith(status: CategoriesStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<bool> create(Map<String, dynamic> data, {required List<String> branchIds, String? branchId}) async {
    AppLogger.i(_tag, 'create name=${data['name']} branches=${branchIds.length}');
    try {
      await _repo.createCategory(data, branchIds);
      AppLogger.i(_tag, 'create success');
      await load(branchId: branchId);
      return true;
    } catch (e, st) {
      AppLogger.e(_tag, 'create failed', e, st);
      emit(state.copyWith(status: CategoriesStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> update({
    required String id,
    required Map<String, dynamic> data,
    required List<String> branchIds,
    String? branchId,
  }) async {
    AppLogger.i(_tag, 'update id=$id branches=${branchIds.length}');
    try {
      await _repo.updateCategory(id: id, data: data, branchIds: branchIds);
      AppLogger.i(_tag, 'update success');
      await load(branchId: branchId);
      return true;
    } catch (e, st) {
      AppLogger.e(_tag, 'update failed', e, st);
      emit(state.copyWith(status: CategoriesStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> delete({required String id, String? branchId}) async {
    AppLogger.i(_tag, 'delete id=$id');
    try {
      await _repo.deleteCategory(id: id);
      AppLogger.i(_tag, 'delete success');
      await load(branchId: branchId);
      return true;
    } catch (e, st) {
      AppLogger.e(_tag, 'delete failed', e, st);
      emit(state.copyWith(status: CategoriesStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  Future<void> reorder(int oldIndex, int newIndex, {String? branchId}) async {
    AppLogger.i(_tag, 'reorder $oldIndex → $newIndex');
    if (newIndex > oldIndex) newIndex--;
    final cats = List.of(state.categories);
    final moved = cats.removeAt(oldIndex);
    cats.insert(newIndex, moved);
    emit(state.copyWith(categories: cats));
    try {
      final updates = [
        for (var i = 0; i < cats.length; i++) (id: cats[i].id, sortOrder: i),
      ];
      await _repo.updateSortOrders(updates);
      AppLogger.i(_tag, 'reorder persisted');
    } catch (e, st) {
      AppLogger.e(_tag, 'reorder persist failed', e, st);
      await load(branchId: branchId);
    }
  }
}
