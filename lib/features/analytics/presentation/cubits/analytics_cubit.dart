import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../orders/data/model/order_model.dart';
import '../../../orders/data/repo/orders_repository.dart';

part 'analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  static const _tag = 'AnalyticsCubit';
  final OrdersRepository _repo;

  AnalyticsCubit(this._repo) : super(const AnalyticsState()) {
    AppLogger.d(_tag, 'init');
  }

  Future<void> load({String? branchId}) async {
    AppLogger.i(_tag, 'load branchId=$branchId');
    emit(state.copyWith(status: AnalyticsStatus.loading));
    try {
      final orders = await _repo.getOrders(branchId: branchId);
      AppLogger.i(_tag, 'load → ${orders.length} orders for analytics');
      final computed = _compute(orders);
      emit(computed.copyWith(status: AnalyticsStatus.success));
    } catch (e, st) {
      AppLogger.e(_tag, 'load failed', e, st);
      emit(state.copyWith(status: AnalyticsStatus.failure, errorMessage: e.toString()));
    }
  }

  AnalyticsState _compute(List<OrderModel> orders) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    double todayRev = 0, weekRev = 0, monthRev = 0;
    int todayCnt = 0;
    int pending = 0, confirmed = 0, preparing = 0, otd = 0, delivered = 0, cancelled = 0;

    final productTotals = <String, _ProductAccum>{};

    for (final o in orders) {
      final isDelivered = o.status == OrderStatus.delivered;
      if (o.createdAt.isAfter(todayStart)) {
        todayCnt++;
        if (isDelivered) todayRev += o.totalPrice;
      }
      if (o.createdAt.isAfter(weekStart) && isDelivered) weekRev += o.totalPrice;
      if (o.createdAt.isAfter(monthStart) && isDelivered) monthRev += o.totalPrice;

      switch (o.status) {
        case OrderStatus.pending:        pending++;        break;
        case OrderStatus.confirmed:      confirmed++;      break;
        case OrderStatus.preparing:      preparing++;      break;
        case OrderStatus.outForDelivery: otd++;            break;
        case OrderStatus.delivered:      delivered++;      break;
        case OrderStatus.cancelled:      cancelled++;      break;
      }

      for (final item in o.items) {
        final acc = productTotals[item.productName] ??= _ProductAccum();
        acc.qty += item.quantity;
        acc.rev += item.subtotal;
      }
    }

    final topProducts = productTotals.entries
        .map((e) => TopProduct(name: e.key, quantity: e.value.qty, revenue: e.value.rev))
        .toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    AppLogger.i(_tag, 'analytics computed: today=$todayRev week=$weekRev month=$monthRev');

    return AnalyticsState(
      todayRevenue:        todayRev,
      weekRevenue:         weekRev,
      monthRevenue:        monthRev,
      totalOrders:         orders.length,
      todayOrders:         todayCnt,
      pendingCount:        pending,
      confirmedCount:      confirmed,
      preparingCount:      preparing,
      outForDeliveryCount: otd,
      deliveredCount:      delivered,
      cancelledCount:      cancelled,
      topProducts:         topProducts.take(5).toList(),
    );
  }
}

class _ProductAccum {
  int qty = 0;
  double rev = 0;
}
