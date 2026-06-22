import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/popup_ad_model.dart';
import '../../data/repo/popup_ads_repository.dart';
import 'popup_ads_state.dart';

class PopupAdsCubit extends Cubit<PopupAdsState> {
  final PopupAdsRepository _repo;
  PopupAdsCubit(this._repo) : super(const PopupAdsState());

  Future<void> load() async {
    dev.log('[PopupAdsCubit] load → fetching all ads', name: 'PopupAds');
    emit(state.copyWith(status: PopupAdsStatus.loading));
    try {
      final ads = await _repo.getAll();
      dev.log('[PopupAdsCubit] load → ${ads.length} ads loaded', name: 'PopupAds');
      emit(state.copyWith(status: PopupAdsStatus.loaded, ads: ads));
    } catch (e, st) {
      dev.log('[PopupAdsCubit] load → ERROR: $e', name: 'PopupAds', error: e, stackTrace: st);
      emit(state.copyWith(status: PopupAdsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> create({required Map<String, dynamic> data}) async {
    dev.log('[PopupAdsCubit] create → $data', name: 'PopupAds');
    try {
      final ad = await _repo.create(data: data);
      dev.log('[PopupAdsCubit] create → ok id=${ad.id}', name: 'PopupAds');
      emit(state.copyWith(ads: [ad, ...state.ads]));
    } catch (e, st) {
      dev.log('[PopupAdsCubit] create → ERROR: $e', name: 'PopupAds', error: e, stackTrace: st);
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> update({required String id, required Map<String, dynamic> data}) async {
    dev.log('[PopupAdsCubit] update → id=$id $data', name: 'PopupAds');
    try {
      final updated = await _repo.update(id: id, data: data);
      dev.log('[PopupAdsCubit] update → ok id=${updated.id}', name: 'PopupAds');
      emit(state.copyWith(
        ads: state.ads.map((a) => a.id == id ? updated : a).toList(),
      ));
    } catch (e, st) {
      dev.log('[PopupAdsCubit] update → ERROR: $e', name: 'PopupAds', error: e, stackTrace: st);
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> delete({required String id}) async {
    dev.log('[PopupAdsCubit] delete → id=$id', name: 'PopupAds');
    try {
      await _repo.delete(id: id);
      dev.log('[PopupAdsCubit] delete → ok id=$id', name: 'PopupAds');
      emit(state.copyWith(ads: state.ads.where((a) => a.id != id).toList()));
    } catch (e, st) {
      dev.log('[PopupAdsCubit] delete → ERROR: $e', name: 'PopupAds', error: e, stackTrace: st);
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> toggleActive({required PopupAdModel ad}) async {
    dev.log('[PopupAdsCubit] toggleActive → id=${ad.id} currently=${ad.isActive}', name: 'PopupAds');
    await update(id: ad.id, data: {'is_active': !ad.isActive});
  }
}
