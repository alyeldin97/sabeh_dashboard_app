import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/model/order_model.dart';
import '../../data/repo/orders_repository.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  static const _tag = 'OrdersCubit';
  final OrdersRepository _repo;
  StreamSubscription<void>? _watchSub;
  String? _watchedBranchId;

  OrdersCubit(this._repo) : super(const OrdersState()) {
    AppLogger.d(_tag, 'init');
  }

  /// Loads orders and starts a real-time channel if not already watching
  /// the same branchId. Pass [status] only for filtered one-shot loads.
  Future<void> load({String? branchId, OrderStatus? status}) async {
    AppLogger.i(_tag, 'load branchId=$branchId status=${status?.name}');
    emit(state.copyWith(status: OrdersStatus.loading));
    try {
      final orders = await _repo.getOrders(branchId: branchId, status: status);
      AppLogger.i(_tag, 'load → ${orders.length} orders');
      emit(state.copyWith(status: OrdersStatus.success, orders: orders));
    } catch (e, st) {
      AppLogger.e(_tag, 'load failed', e, st);
      emit(state.copyWith(status: OrdersStatus.failure, errorMessage: e.toString()));
    }

    // Start realtime watch the first time (or when branchId changes)
    if (status == null && _watchedBranchId != branchId) {
      _watchedBranchId = branchId;
      await _watchSub?.cancel();
      _watchSub = _repo.watchOrders(branchId: branchId).listen((_) {
        AppLogger.d(_tag, 'realtime: orders changed, reloading');
        load(branchId: branchId);
      });
    }
  }

  Future<void> loadSingle({required String orderId}) async {
    AppLogger.i(_tag, 'loadSingle orderId=$orderId');
    emit(state.copyWith(detailStatus: OrdersStatus.loading));
    try {
      final order = await _repo.getOrder(orderId: orderId);
      AppLogger.i(_tag, 'loadSingle → status=${order.status.name}');
      emit(state.copyWith(detailStatus: OrdersStatus.success, selectedOrder: order));
    } catch (e, st) {
      AppLogger.e(_tag, 'loadSingle failed', e, st);
      emit(state.copyWith(detailStatus: OrdersStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> updateStatus({
    required String orderId,
    required OrderStatus newStatus,
    String? branchId,
  }) async {
    AppLogger.i(_tag, 'updateStatus orderId=$orderId → ${newStatus.name}');
    try {
      await _repo.updateOrderStatus(orderId: orderId, status: newStatus);
      AppLogger.i(_tag, 'updateStatus success, reloading list');
      await load(branchId: branchId);
    } catch (e, st) {
      AppLogger.e(_tag, 'updateStatus failed', e, st);
      emit(state.copyWith(status: OrdersStatus.failure, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() async {
    AppLogger.d(_tag, 'close — stopping realtime watch');
    await _watchSub?.cancel();
    await _repo.stopWatchingOrders();
    return super.close();
  }
}
