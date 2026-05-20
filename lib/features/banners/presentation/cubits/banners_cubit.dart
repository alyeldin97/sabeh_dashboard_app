import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/model/banner_model.dart';
import '../../data/repo/banners_repository.dart';

part 'banners_state.dart';

class BannersCubit extends Cubit<BannersState> {
  static const _tag = 'BannersCubit';
  final BannersRepository _repo;

  BannersCubit(this._repo) : super(const BannersState()) {
    AppLogger.d(_tag, 'init');
  }

  Future<void> load() async {
    AppLogger.i(_tag, 'load');
    emit(state.copyWith(status: BannersStatus.loading));
    try {
      final banners = await _repo.getAll();
      emit(state.copyWith(status: BannersStatus.success, banners: banners));
    } catch (e, st) {
      AppLogger.e(_tag, 'load failed', e, st);
      emit(state.copyWith(status: BannersStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<bool> create({
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
  }) async {
    AppLogger.i(_tag, 'create');
    emit(state.copyWith(mutationStatus: BannerMutationStatus.saving));
    try {
      await _repo.create(
        imageUrl:           imageUrl,
        title:              title,
        isActive:           isActive,
        sortOrder:          sortOrder,
        actionType:         actionType,
        actionUrl:          actionUrl,
        actionProductId:    actionProductId,
        actionCollectionId: actionCollectionId,
        startDate:          startDate,
        endDate:            endDate,
      );
      await load();
      emit(state.copyWith(mutationStatus: BannerMutationStatus.success));
      return true;
    } catch (e, st) {
      AppLogger.e(_tag, 'create failed', e, st);
      emit(state.copyWith(
          mutationStatus: BannerMutationStatus.failure,
          errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> update({
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
  }) async {
    AppLogger.i(_tag, 'update id=$id');
    emit(state.copyWith(mutationStatus: BannerMutationStatus.saving));
    try {
      await _repo.update(
        id:                 id,
        imageUrl:           imageUrl,
        title:              title,
        isActive:           isActive,
        sortOrder:          sortOrder,
        actionType:         actionType,
        actionUrl:          actionUrl,
        actionProductId:    actionProductId,
        actionCollectionId: actionCollectionId,
        startDate:          startDate,
        endDate:            endDate,
      );
      await load();
      emit(state.copyWith(mutationStatus: BannerMutationStatus.success));
      return true;
    } catch (e, st) {
      AppLogger.e(_tag, 'update failed', e, st);
      emit(state.copyWith(
          mutationStatus: BannerMutationStatus.failure,
          errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> delete({required String id}) async {
    AppLogger.i(_tag, 'delete id=$id');
    emit(state.copyWith(mutationStatus: BannerMutationStatus.deleting));
    try {
      await _repo.delete(id: id);
      await load();
      emit(state.copyWith(mutationStatus: BannerMutationStatus.success));
      return true;
    } catch (e, st) {
      AppLogger.e(_tag, 'delete failed', e, st);
      emit(state.copyWith(
          mutationStatus: BannerMutationStatus.failure,
          errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> toggleActive({required BannerModel banner}) => update(
        id:                 banner.id,
        imageUrl:           banner.imageUrl,
        title:              banner.title,
        isActive:           !banner.isActive,
        sortOrder:          banner.sortOrder,
        actionType:         banner.actionType,
        actionUrl:          banner.actionUrl,
        actionProductId:    banner.actionProductId,
        actionCollectionId: banner.actionCollectionId,
        startDate:          banner.startDate,
        endDate:            banner.endDate,
      );

  Future<bool> moveUp({required BannerModel banner}) {
    final idx = state.banners.indexOf(banner);
    if (idx <= 0) return Future.value(false);
    final prev = state.banners[idx - 1];
    return _swap(banner, prev);
  }

  Future<bool> moveDown({required BannerModel banner}) {
    final idx = state.banners.indexOf(banner);
    if (idx < 0 || idx >= state.banners.length - 1) return Future.value(false);
    final next = state.banners[idx + 1];
    return _swap(banner, next);
  }

  Future<bool> _swap(BannerModel a, BannerModel b) async {
    emit(state.copyWith(mutationStatus: BannerMutationStatus.saving));
    try {
      await _repo.update(
        id: a.id, imageUrl: a.imageUrl, title: a.title,
        isActive: a.isActive, sortOrder: b.sortOrder,
        actionType: a.actionType, actionUrl: a.actionUrl,
        actionProductId: a.actionProductId, actionCollectionId: a.actionCollectionId,
      );
      await _repo.update(
        id: b.id, imageUrl: b.imageUrl, title: b.title,
        isActive: b.isActive, sortOrder: a.sortOrder,
        actionType: b.actionType, actionUrl: b.actionUrl,
        actionProductId: b.actionProductId, actionCollectionId: b.actionCollectionId,
      );
      await load();
      emit(state.copyWith(mutationStatus: BannerMutationStatus.success));
      return true;
    } catch (e, st) {
      AppLogger.e(_tag, 'swap failed', e, st);
      emit(state.copyWith(
          mutationStatus: BannerMutationStatus.failure,
          errorMessage: e.toString()));
      return false;
    }
  }
}
