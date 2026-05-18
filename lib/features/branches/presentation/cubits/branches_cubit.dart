import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/model/branch_model.dart';
import '../../data/repo/branches_repository.dart';

part 'branches_state.dart';

class BranchesCubit extends Cubit<BranchesState> {
  static const _tag = 'BranchesCubit';
  final BranchesRepository _repo;

  BranchesCubit(this._repo) : super(const BranchesState()) {
    AppLogger.d(_tag, 'init');
  }

  Future<void> load() async {
    AppLogger.i(_tag, 'load');
    emit(state.copyWith(status: BranchesStatus.loading));
    try {
      final branches = await _repo.getBranches();
      AppLogger.i(_tag, 'load → ${branches.length} branches');
      emit(state.copyWith(status: BranchesStatus.success, branches: branches));
    } catch (e, st) {
      AppLogger.e(_tag, 'load failed', e, st);
      emit(state.copyWith(status: BranchesStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<bool> create({
    required String name,
    required double lat,
    required double lng,
    required double coverageKm,
  }) async {
    AppLogger.i(_tag, 'create name=$name');
    emit(state.copyWith(mutationStatus: BranchMutationStatus.saving));
    try {
      await _repo.createBranch(data: {
        'name':            name,
        'lat':             lat,
        'lng':             lng,
        'coverage_radius': coverageKm,
        'is_active':       true,
      });
      AppLogger.i(_tag, 'create success');
      await load();
      emit(state.copyWith(mutationStatus: BranchMutationStatus.success));
      return true;
    } catch (e, st) {
      AppLogger.e(_tag, 'create failed', e, st);
      emit(state.copyWith(
          mutationStatus: BranchMutationStatus.failure,
          errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> update({
    required String id,
    required String name,
    required double lat,
    required double lng,
    required double coverageKm,
    required bool isActive,
  }) async {
    AppLogger.i(_tag, 'update id=$id');
    emit(state.copyWith(mutationStatus: BranchMutationStatus.saving));
    try {
      await _repo.updateBranch(id: id, data: {
        'name':            name,
        'lat':             lat,
        'lng':             lng,
        'coverage_radius': coverageKm,
        'is_active':       isActive,
      });
      AppLogger.i(_tag, 'update success');
      await load();
      emit(state.copyWith(mutationStatus: BranchMutationStatus.success));
      return true;
    } catch (e, st) {
      AppLogger.e(_tag, 'update failed', e, st);
      emit(state.copyWith(
          mutationStatus: BranchMutationStatus.failure,
          errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> delete({required String id}) async {
    AppLogger.i(_tag, 'delete id=$id');
    emit(state.copyWith(mutationStatus: BranchMutationStatus.deleting));
    try {
      await _repo.deleteBranch(id: id);
      AppLogger.i(_tag, 'delete success');
      await load();
      emit(state.copyWith(mutationStatus: BranchMutationStatus.success));
      return true;
    } catch (e, st) {
      AppLogger.e(_tag, 'delete failed', e, st);
      emit(state.copyWith(
          mutationStatus: BranchMutationStatus.failure,
          errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> toggleActive({required BranchModel branch}) =>
      update(
        id:          branch.id,
        name:        branch.name,
        lat:         branch.lat,
        lng:         branch.lng,
        coverageKm:  branch.coverageRadius,
        isActive:    !branch.isActive,
      );
}
