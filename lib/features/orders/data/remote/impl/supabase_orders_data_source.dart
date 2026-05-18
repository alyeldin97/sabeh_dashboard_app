import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/utils/app_logger.dart';
import '../orders_data_source.dart';
import '../../model/order_model.dart';

class SupabaseOrdersDataSource implements OrdersDataSource {
  static const _tag = 'OrdersDataSource';

  final SupabaseClient _client;
  RealtimeChannel? _ordersChannel;
  StreamController<void>? _ordersController;

  SupabaseOrdersDataSource(this._client);

  @override
  Future<List<OrderModel>> getOrders({String? branchId, OrderStatus? status}) async {
    AppLogger.net(_tag, 'getOrders', 'branchId=$branchId status=${status?.name}');
    try {
      var query = _client.from('orders').select('*, order_items(*)');
      if (branchId != null) query = query.eq('branch_id', branchId) as dynamic;
      if (status != null)   query = query.eq('status', status.value) as dynamic;
      final rows = await (query as dynamic).order('created_at', ascending: false);
      final result = (rows as List)
          .map((r) => OrderModel.fromJson(r as Map<String, dynamic>))
          .toList();
      AppLogger.i(_tag, 'getOrders → ${result.length} orders');
      return result;
    } catch (e, st) {
      AppLogger.e(_tag, 'getOrders failed', e, st);
      rethrow;
    }
  }

  @override
  Future<OrderModel> getOrder({required String orderId}) async {
    AppLogger.net(_tag, 'getOrder', 'orderId=$orderId');
    try {
      final row = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('id', orderId)
          .single();
      final order = OrderModel.fromJson(row);
      AppLogger.i(_tag, 'getOrder → status=${order.status.name} items=${order.items.length}');
      return order;
    } catch (e, st) {
      AppLogger.e(_tag, 'getOrder failed', e, st);
      rethrow;
    }
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    AppLogger.net(_tag, 'updateOrderStatus', 'orderId=$orderId → ${status.name}');
    try {
      await _client
          .from('orders')
          .update({'status': status.value})
          .eq('id', orderId);
      AppLogger.i(_tag, 'updateOrderStatus success');
    } catch (e, st) {
      AppLogger.e(_tag, 'updateOrderStatus failed', e, st);
      rethrow;
    }
  }

  @override
  Stream<void> watchOrders({String? branchId}) {
    AppLogger.d(_tag, 'watchOrders branchId=$branchId');
    _ordersController?.close();
    _ordersController = StreamController<void>.broadcast();

    _ordersChannel = _client
        .channel('orders_realtime_${branchId ?? 'all'}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          filter: branchId != null
              ? PostgresChangeFilter(
                  type: PostgresChangeFilterType.eq,
                  column: 'branch_id',
                  value: branchId,
                )
              : null,
          callback: (_) {
            AppLogger.d(_tag, 'watchOrders → change detected');
            if (!(_ordersController?.isClosed ?? true)) {
              _ordersController!.add(null);
            }
          },
        )
        .subscribe((status, [_]) {
          AppLogger.d(_tag, 'watchOrders channel status=$status');
        });

    return _ordersController!.stream;
  }

  @override
  Future<void> stopWatchingOrders() async {
    AppLogger.d(_tag, 'stopWatchingOrders');
    if (_ordersChannel != null) {
      await _client.removeChannel(_ordersChannel!);
      _ordersChannel = null;
    }
    await _ordersController?.close();
    _ordersController = null;
  }
}
