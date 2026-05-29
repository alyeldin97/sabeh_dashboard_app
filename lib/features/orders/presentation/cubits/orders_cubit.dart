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

  Future<void> createOrder({
    required Map<String, dynamic> orderData,
    required List<Map<String, dynamic>> items,
    String? branchId,
  }) async {
    AppLogger.i(_tag, 'createOrder items=${items.length}');
    emit(state.copyWith(
      createStatus: OrdersCreateStatus.loading,
      createError: null,
      createdOrderId: null,
    ));
    try {
      final orderId = await _repo.createOrder(orderData: orderData, items: items);
      AppLogger.i(_tag, 'createOrder success orderId=$orderId');
      emit(state.copyWith(
        createStatus:   OrdersCreateStatus.success,
        createdOrderId: orderId,
      ));
      await load(branchId: branchId);
    } catch (e, st) {
      AppLogger.e(_tag, 'createOrder failed', e, st);
      emit(state.copyWith(
        createStatus: OrdersCreateStatus.failure,
        createError:  e.toString(),
      ));
    }
  }

  Future<void> editOrder({
    required String orderId,
    String? notes,
    String? deliveryAddress,
    String? paymentMethod,
    String? customerPhone,
    String? staffNote,
    String? branchId,
  }) async {
    AppLogger.i(_tag, 'editOrder orderId=$orderId');
    try {
      await _repo.updateOrderFields(
        orderId: orderId,
        notes: notes,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        customerPhone: customerPhone,
        staffNote: staffNote,
      );
      await load(branchId: branchId);
    } catch (e, st) {
      AppLogger.e(_tag, 'editOrder failed', e, st);
      emit(state.copyWith(status: OrdersStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> updateItems({
    required String orderId,
    required List<Map<String, dynamic>> updatedItems,
    required List<String> deletedItemIds,
    required double newTotalPrice,
    String? branchId,
  }) async {
    AppLogger.i(_tag, 'updateItems orderId=$orderId');
    try {
      await _repo.updateOrderItems(
        orderId: orderId,
        updatedItems: updatedItems,
        deletedItemIds: deletedItemIds,
        newTotalPrice: newTotalPrice,
      );
      await loadSingle(orderId: orderId);
    } catch (e, st) {
      AppLogger.e(_tag, 'updateItems failed', e, st);
      emit(state.copyWith(status: OrdersStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> editFinancials({
    required String orderId,
    required double deliveryFee,
    required double deposit,
    required double maradia,
    required bool isPaid,
    required double oldDeliveryFee,
    required double oldTotal,
    required bool isCashOrder,
    String? branchId,
  }) async {
    AppLogger.i(_tag, 'editFinancials orderId=$orderId');
    try {
      final ops = <Future>[];
      if (deliveryFee != oldDeliveryFee) {
        ops.add(_repo.updateOrderDeliveryFee(
          orderId: orderId,
          fee: deliveryFee,
          newTotalPrice: oldTotal - oldDeliveryFee + deliveryFee,
        ));
      }
      ops.add(_repo.updateOrderDeposit(orderId: orderId, deposit: deposit));
      ops.add(_repo.updateOrderMaradia(orderId: orderId, maradia: maradia));
      ops.add(_repo.markOrderPaid(orderId: orderId, isPaid: isPaid, isCashOrder: isCashOrder));
      await Future.wait(ops);
      await loadSingle(orderId: orderId);
    } catch (e, st) {
      AppLogger.e(_tag, 'editFinancials failed', e, st);
      emit(state.copyWith(status: OrdersStatus.failure, errorMessage: e.toString()));
    }
  }

  void resetCreateStatus() {
    emit(state.copyWith(
      createStatus:   OrdersCreateStatus.idle,
      createdOrderId: null,
      createError:    null,
    ));
  }

  @override
  Future<void> close() async {
    AppLogger.d(_tag, 'close — stopping realtime watch');
    await _watchSub?.cancel();
    await _repo.stopWatchingOrders();
    return super.close();
  }
}
