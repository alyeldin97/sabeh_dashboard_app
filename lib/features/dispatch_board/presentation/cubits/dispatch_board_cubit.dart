import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../orders/data/model/order_model.dart';
import '../../../orders/data/repo/orders_repository.dart';
import 'dispatch_board_state.dart';

class DispatchBoardCubit extends Cubit<DispatchBoardState> {
  final OrdersRepository _ordersRepo;
  StreamSubscription<void>? _watchSub;
  String? _watchedBranchId;

  DispatchBoardCubit(this._ordersRepo)
      : super(DispatchBoardState(viewDate: _today()));

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  // ── Public API ────────────────────────────────────────────────────────────

  void load({String? branchId}) => _fetch(branchId: branchId);

  void startWatching({String? branchId}) {
    if (_watchedBranchId == branchId && _watchSub != null) return;
    _watchSub?.cancel();
    _watchedBranchId = branchId;
    _watchSub = _ordersRepo.watchOrders(branchId: branchId).listen((_) {
      _fetch(branchId: branchId);
    });
  }

  void goToDate(DateTime date, {String? branchId}) {
    final normalized = DateTime(date.year, date.month, date.day);
    emit(state.copyWith(viewDate: normalized));
    _fetch(branchId: branchId);
  }

  void previousDay({String? branchId}) =>
      goToDate(state.viewDate.subtract(const Duration(days: 1)), branchId: branchId);

  void nextDay({String? branchId}) =>
      goToDate(state.viewDate.add(const Duration(days: 1)), branchId: branchId);

  void goToToday({String? branchId}) =>
      goToDate(_today(), branchId: branchId);

  void setSearch(String query) => emit(state.copyWith(searchQuery: query));

  void setDriverFilter(String? driverId) {
    if (driverId == null) {
      emit(state.copyWith(clearDriverFilter: true));
    } else {
      emit(state.copyWith(selectedDriverId: driverId));
    }
  }

  Future<void> moveToStatus({
    required String orderId,
    required OrderStatus newStatus,
    String? branchId,
  }) async {
    // Optimistic update
    final updated = _updateInColumns(orderId, (o) => o.copyWith(status: newStatus));
    if (updated != null) emit(state.copyWith(columns: updated));

    try {
      await _ordersRepo.updateOrderStatus(orderId: orderId, status: newStatus);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      _fetch(branchId: branchId); // rollback via reload
    }
  }

  Future<void> assignDriver({
    required String orderId,
    String? driverId,
    String? driverName,
    String? branchId,
  }) async {
    final updated = _updateInColumns(
      orderId,
      (o) => driverId == null
          ? o.copyWith(clearDriver: true)
          : o.copyWith(driverId: driverId, driverName: driverName),
    );
    if (updated != null) emit(state.copyWith(columns: updated));

    try {
      await _ordersRepo.updateOrderDriver(
        orderId:    orderId,
        driverId:   driverId,
        driverName: driverName,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      _fetch(branchId: branchId);
    }
  }

  // ── Internals ─────────────────────────────────────────────────────────────

  Future<void> _fetch({String? branchId}) async {
    emit(state.copyWith(status: DispatchBoardStatus.loading));
    try {
      final orders = await _ordersRepo.getOrdersByDate(
        date: state.viewDate,
        branchId: branchId,
      );
      final cols = <OrderStatus, List<OrderModel>>{
        for (final s in OrderStatus.values) s: [],
      };
      for (final o in orders) {
        cols[o.status]!.add(o);
      }
      emit(state.copyWith(status: DispatchBoardStatus.success, columns: cols));
    } catch (e) {
      emit(state.copyWith(
        status: DispatchBoardStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Returns an updated columns map with the given order mutated, or null if not found.
  Map<OrderStatus, List<OrderModel>>? _updateInColumns(
    String orderId,
    OrderModel Function(OrderModel) transform,
  ) {
    for (final entry in state.columns.entries) {
      final idx = entry.value.indexWhere((o) => o.id == orderId);
      if (idx == -1) continue;

      final updated = transform(entry.value[idx]);
      final newList = List<OrderModel>.from(entry.value);
      newList.removeAt(idx);

      final newCols = Map<OrderStatus, List<OrderModel>>.from(state.columns);
      newCols[entry.key] = newList;
      newCols[updated.status] = [updated, ...(newCols[updated.status] ?? [])];
      return newCols;
    }
    return null;
  }

  @override
  Future<void> close() {
    _watchSub?.cancel();
    _ordersRepo.stopWatchingOrders();
    return super.close();
  }
}
