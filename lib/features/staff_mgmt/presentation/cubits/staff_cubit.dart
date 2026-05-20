import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/data/model/staff_user.dart';
import '../../data/model/staff_member.dart';
import '../../data/repo/staff_repository.dart';

part 'staff_state.dart';

class StaffCubit extends Cubit<StaffState> {
  static const _tag = 'StaffCubit';
  final StaffRepository _repo;

  StaffCubit(this._repo) : super(const StaffState()) {
    AppLogger.d(_tag, 'init');
  }

  Future<void> load() async {
    AppLogger.i(_tag, 'load');
    emit(state.copyWith(status: StaffStatus.loading));
    try {
      final members = await _repo.getAll();
      emit(state.copyWith(status: StaffStatus.success, members: members));
    } catch (e, st) {
      AppLogger.e(_tag, 'load failed', e, st);
      emit(state.copyWith(status: StaffStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<bool> create({
    required String phone,
    required String password,
    required String name,
    required StaffRole role,
    required List<String> branchIds,
  }) async {
    AppLogger.i(_tag, 'create phone=$phone');
    emit(state.copyWith(mutationStatus: StaffMutationStatus.saving));
    try {
      await _repo.create(
        phone:     phone,
        password:  password,
        name:      name,
        role:      role,
        branchIds: branchIds,
      );
      await load();
      emit(state.copyWith(mutationStatus: StaffMutationStatus.success));
      return true;
    } catch (e, st) {
      AppLogger.e(_tag, 'create failed', e, st);
      emit(state.copyWith(
          mutationStatus: StaffMutationStatus.failure,
          errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> update({
    required String id,
    required String name,
    required StaffRole role,
    required List<String> branchIds,
    required bool isActive,
    String? phone,
  }) async {
    AppLogger.i(_tag, 'update id=$id');
    emit(state.copyWith(mutationStatus: StaffMutationStatus.saving));
    try {
      await _repo.update(
        id:        id,
        name:      name,
        role:      role,
        branchIds: branchIds,
        isActive:  isActive,
        phone:     phone,
      );
      await load();
      emit(state.copyWith(mutationStatus: StaffMutationStatus.success));
      return true;
    } catch (e, st) {
      AppLogger.e(_tag, 'update failed', e, st);
      emit(state.copyWith(
          mutationStatus: StaffMutationStatus.failure,
          errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> delete({required String id}) async {
    AppLogger.i(_tag, 'delete id=$id');
    emit(state.copyWith(mutationStatus: StaffMutationStatus.deleting));
    try {
      await _repo.delete(id: id);
      await load();
      emit(state.copyWith(mutationStatus: StaffMutationStatus.success));
      return true;
    } catch (e, st) {
      AppLogger.e(_tag, 'delete failed', e, st);
      emit(state.copyWith(
          mutationStatus: StaffMutationStatus.failure,
          errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> toggleActive({required StaffMember member}) => update(
        id:        member.id,
        name:      member.name,
        role:      member.role,
        branchIds: member.branchIds,
        isActive:  !member.isActive,
        phone:     member.phone,
      );
}
