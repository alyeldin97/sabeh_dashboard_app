import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/model/promo_code_model.dart';
import '../../data/repo/promo_codes_repository.dart';

part 'promo_codes_state.dart';

class PromoCodesCubit extends Cubit<PromoCodesState> {
  static const _tag = 'PromoCodesCubit';
  final PromoCodesRepository _repo;

  PromoCodesCubit(this._repo) : super(const PromoCodesState()) {
    AppLogger.d(_tag, 'init');
  }

  Future<void> load() async {
    AppLogger.i(_tag, 'load');
    emit(state.copyWith(status: PromoCodesStatus.loading));
    try {
      final codes = await _repo.getAll();
      emit(state.copyWith(status: PromoCodesStatus.success, codes: codes));
    } catch (e, st) {
      AppLogger.e(_tag, 'load failed', e, st);
      emit(state.copyWith(status: PromoCodesStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<bool> create({
    required String code,
    required PromoType type,
    required double discountValue,
    required double minOrder,
    int? maxUses,
    DateTime? expiresAt,
    DateTime? startsAt,
    String? description,
    int maxUsesPerUser = 1,
    int? cashbackExpiryDays,
  }) async {
    AppLogger.i(_tag, 'create code=$code cashbackExpiryDays=$cashbackExpiryDays');
    emit(state.copyWith(mutationStatus: PromoMutationStatus.saving));
    try {
      await _repo.create(
        code:               code,
        type:               type,
        discountValue:      discountValue,
        minOrder:           minOrder,
        maxUses:            maxUses,
        expiresAt:          expiresAt,
        startsAt:           startsAt,
        description:        description,
        maxUsesPerUser:     maxUsesPerUser,
        cashbackExpiryDays: cashbackExpiryDays,
      );
      await load();
      emit(state.copyWith(mutationStatus: PromoMutationStatus.success));
      return true;
    } catch (e, st) {
      AppLogger.e(_tag, 'create failed', e, st);
      emit(state.copyWith(
          mutationStatus: PromoMutationStatus.failure,
          errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> update({
    required String id,
    required String code,
    required PromoType type,
    required double discountValue,
    required double minOrder,
    int? maxUses,
    DateTime? expiresAt,
    DateTime? startsAt,
    required bool isActive,
    String? description,
    int maxUsesPerUser = 1,
    int? cashbackExpiryDays,
  }) async {
    AppLogger.i(_tag, 'update id=$id cashbackExpiryDays=$cashbackExpiryDays');
    emit(state.copyWith(mutationStatus: PromoMutationStatus.saving));
    try {
      await _repo.update(
        id:                 id,
        code:               code,
        type:               type,
        discountValue:      discountValue,
        minOrder:           minOrder,
        maxUses:            maxUses,
        expiresAt:          expiresAt,
        startsAt:           startsAt,
        isActive:           isActive,
        description:        description,
        maxUsesPerUser:     maxUsesPerUser,
        cashbackExpiryDays: cashbackExpiryDays,
      );
      await load();
      emit(state.copyWith(mutationStatus: PromoMutationStatus.success));
      return true;
    } catch (e, st) {
      AppLogger.e(_tag, 'update failed', e, st);
      emit(state.copyWith(
          mutationStatus: PromoMutationStatus.failure,
          errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> delete({required String id}) async {
    AppLogger.i(_tag, 'delete id=$id');
    emit(state.copyWith(mutationStatus: PromoMutationStatus.deleting));
    try {
      await _repo.delete(id: id);
      await load();
      emit(state.copyWith(mutationStatus: PromoMutationStatus.success));
      return true;
    } catch (e, st) {
      AppLogger.e(_tag, 'delete failed', e, st);
      emit(state.copyWith(
          mutationStatus: PromoMutationStatus.failure,
          errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> toggleActive({required PromoCodeModel code}) => update(
        id:                 code.id,
        code:               code.code,
        type:               code.type,
        discountValue:      code.discountValue,
        minOrder:           code.minOrder,
        maxUses:            code.maxUses,
        expiresAt:          code.expiresAt,
        startsAt:           code.startsAt,
        isActive:           !code.isActive,
        description:        code.description,
        maxUsesPerUser:     code.maxUsesPerUser,
        cashbackExpiryDays: code.cashbackExpiryDays,
      );
}
