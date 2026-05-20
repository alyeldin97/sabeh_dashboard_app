import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/delivery_zone_model.dart';
import '../../data/repo/delivery_zones_repository.dart';

part 'delivery_zones_state.dart';

class DeliveryZonesCubit extends Cubit<DeliveryZonesState> {
  final DeliveryZonesRepository _repo;
  DeliveryZonesCubit(this._repo) : super(const DeliveryZonesState());

  Future<void> load() async {
    emit(state.copyWith(status: ZonesStatus.loading));
    try {
      final zones = await _repo.getZones();
      emit(state.copyWith(zones: zones, status: ZonesStatus.loaded));
    } catch (e) {
      emit(state.copyWith(status: ZonesStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<bool> create({
    required String name,
    String? nameAr,
    required double deliveryFee,
    required double minOrderValue,
    required int minRiderQuantity,
  }) async {
    emit(state.copyWith(mutationStatus: ZoneMutationStatus.saving));
    try {
      final zone = await _repo.createZone(
        name: name,
        nameAr: nameAr,
        deliveryFee: deliveryFee,
        minOrderValue: minOrderValue,
        minRiderQuantity: minRiderQuantity,
      );
      emit(state.copyWith(
        zones: [zone, ...state.zones],
        mutationStatus: ZoneMutationStatus.idle,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        mutationStatus: ZoneMutationStatus.failure,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  Future<bool> update({
    required String id,
    required String name,
    String? nameAr,
    required double deliveryFee,
    required double minOrderValue,
    required int minRiderQuantity,
    required bool isActive,
  }) async {
    emit(state.copyWith(mutationStatus: ZoneMutationStatus.saving));
    try {
      final updated = await _repo.updateZone(
        id: id,
        name: name,
        nameAr: nameAr,
        deliveryFee: deliveryFee,
        minOrderValue: minOrderValue,
        minRiderQuantity: minRiderQuantity,
        isActive: isActive,
      );
      final zones = state.zones.map((z) => z.id == id ? updated : z).toList();
      emit(state.copyWith(zones: zones, mutationStatus: ZoneMutationStatus.idle));
      return true;
    } catch (e) {
      emit(state.copyWith(
        mutationStatus: ZoneMutationStatus.failure,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  Future<bool> delete(String id) async {
    emit(state.copyWith(mutationStatus: ZoneMutationStatus.saving));
    try {
      await _repo.deleteZone(id);
      final zones = state.zones.where((z) => z.id != id).toList();
      emit(state.copyWith(zones: zones, mutationStatus: ZoneMutationStatus.idle));
      return true;
    } catch (e) {
      emit(state.copyWith(
        mutationStatus: ZoneMutationStatus.failure,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }
}
