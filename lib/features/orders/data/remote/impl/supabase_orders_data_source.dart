import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/utils/app_logger.dart';
import '../orders_data_source.dart';
import '../../model/order_history_model.dart';
import '../../model/order_model.dart';

class SupabaseOrdersDataSource implements OrdersDataSource {
  static const _tag = 'OrdersDataSource';
  static const _orderSelect = '*, order_items(*), customer_profiles!customer_id(phone)';

  final SupabaseClient _client;
  RealtimeChannel? _ordersChannel;
  StreamController<void>? _ordersController;

  SupabaseOrdersDataSource(this._client);

  @override
  Future<List<OrderModel>> getOrders({String? branchId, OrderStatus? status}) async {
    AppLogger.net(_tag, 'getOrders', 'branchId=$branchId status=${status?.name}');
    try {
      var query = _client.from('orders').select(_orderSelect);
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
          .select(_orderSelect)
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
  Future<List<OrderModel>> getOrdersByDate({
    required DateTime date,
    String? branchId,
  }) async {
    AppLogger.net(_tag, 'getOrdersByDate', 'date=$date branchId=$branchId');
    try {
      final start = DateTime(date.year, date.month, date.day).toUtc();
      final end   = start.add(const Duration(days: 1));

      if (branchId != null) {
        return await _fetchByDateForBranch(branchId: branchId, start: start, end: end);
      }

      final rows = await _client
          .from('orders')
          .select(_orderSelect)
          .gte('created_at', start.toIso8601String())
          .lt('created_at', end.toIso8601String())
          .order('created_at', ascending: false);
      final result = (rows as List)
          .map((r) => OrderModel.fromJson(r as Map<String, dynamic>))
          .toList();
      AppLogger.i(_tag, 'getOrdersByDate → ${result.length} orders');
      return result;
    } catch (e, st) {
      AppLogger.e(_tag, 'getOrdersByDate failed', e, st);
      rethrow;
    }
  }

  @override
  Future<List<OrderModel>> getOrdersByDateRange({
    required DateTime from,
    required DateTime to,
    String? branchId,
  }) async {
    AppLogger.net(_tag, 'getOrdersByDateRange', 'from=$from to=$to branchId=$branchId');
    try {
      final start = DateTime(from.year, from.month, from.day).toUtc();
      final end   = DateTime(to.year, to.month, to.day).toUtc().add(const Duration(days: 1));

      if (branchId != null) {
        return await _fetchByDateForBranch(branchId: branchId, start: start, end: end);
      }

      final rows = await _client
          .from('orders')
          .select(_orderSelect)
          .gte('created_at', start.toIso8601String())
          .lt('created_at', end.toIso8601String())
          .order('created_at', ascending: false);
      final result = (rows as List)
          .map((r) => OrderModel.fromJson(r as Map<String, dynamic>))
          .toList();
      AppLogger.i(_tag, 'getOrdersByDateRange → ${result.length} orders');
      return result;
    } catch (e, st) {
      AppLogger.e(_tag, 'getOrdersByDateRange failed', e, st);
      rethrow;
    }
  }

  /// Fetches orders for [branchId] using zone-aware filtering:
  ///   1. Orders whose zone_id belongs to this branch.
  ///   2. Legacy orders with no zone_id but explicit branch_id (manual/old orders).
  Future<List<OrderModel>> _fetchByDateForBranch({
    required String branchId,
    required DateTime start,
    required DateTime end,
  }) async {
    // Resolve zone IDs for this branch.
    final zoneRows = await _client
        .from('delivery_zones')
        .select('id')
        .eq('branch_id', branchId)
        .eq('is_active', true);
    final zoneIds = (zoneRows as List).map((r) => r['id'] as String).toList();

    final futures = <Future<List<OrderModel>>>[];

    if (zoneIds.isNotEmpty) {
      futures.add(() async {
        final rows = await _client
            .from('orders')
            .select(_orderSelect)
            .inFilter('zone_id', zoneIds)
            .gte('created_at', start.toIso8601String())
            .lt('created_at', end.toIso8601String())
            .order('created_at', ascending: false);
        return (rows as List)
            .map((r) => OrderModel.fromJson(r as Map<String, dynamic>))
            .toList();
      }());
    }

    // Legacy: no zone_id but direct branch_id set.
    futures.add(() async {
      final rows = await _client
          .from('orders')
          .select(_orderSelect)
          .isFilter('zone_id', null)
          .eq('branch_id', branchId)
          .gte('created_at', start.toIso8601String())
          .lt('created_at', end.toIso8601String())
          .order('created_at', ascending: false);
      return (rows as List)
          .map((r) => OrderModel.fromJson(r as Map<String, dynamic>))
          .toList();
    }());

    final results = await Future.wait(futures);
    final seen    = <String>{};
    final merged  = <OrderModel>[];
    for (final batch in results) {
      for (final o in batch) {
        if (seen.add(o.id)) merged.add(o);
      }
    }
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    AppLogger.i(_tag, '_fetchByDateForBranch → ${merged.length} orders (branch=$branchId zones=${zoneIds.length})');
    return merged;
  }

  @override
  Future<void> updateOrderDriver({
    required String orderId,
    String? driverId,
    String? driverName,
  }) async {
    AppLogger.net(_tag, 'updateOrderDriver', 'orderId=$orderId driver=$driverName');
    try {
      await _client.from('orders').update({
        'driver_id':   driverId,
        'driver_name': driverName,
      }).eq('id', orderId);
      AppLogger.i(_tag, 'updateOrderDriver success');
    } catch (e, st) {
      AppLogger.e(_tag, 'updateOrderDriver failed', e, st);
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
  Future<void> markOrderPaid({required String orderId, required bool isPaid, bool isCashOrder = false}) async {
    AppLogger.net(_tag, 'markOrderPaid', 'orderId=$orderId isPaid=$isPaid isCashOrder=$isCashOrder');
    try {
      final payload = <String, dynamic>{'is_paid': isPaid};
      if (isCashOrder) {
        payload['payment_method'] = isPaid ? 'instapay' : 'cash';
      }
      await _client.from('orders').update(payload).eq('id', orderId);
      AppLogger.i(_tag, 'markOrderPaid success');
    } catch (e, st) {
      AppLogger.e(_tag, 'markOrderPaid failed', e, st);
      rethrow;
    }
  }

  @override
  Future<void> updateOrderFields({
    required String orderId,
    String? notes,
    String? deliveryAddress,
    String? paymentMethod,
    String? customerPhone,
    String? staffNote,
  }) async {
    AppLogger.net(_tag, 'updateOrderFields', 'orderId=$orderId');
    try {
      final payload = <String, dynamic>{};
      if (notes != null)           payload['notes'] = notes.isEmpty ? null : notes;
      if (deliveryAddress != null) payload['delivery_address'] = deliveryAddress.isEmpty ? null : deliveryAddress;
      if (paymentMethod != null)   payload['payment_method'] = paymentMethod;
      if (customerPhone != null)   payload['customer_phone'] = customerPhone.isEmpty ? null : customerPhone;
      if (staffNote != null)       payload['staff_note'] = staffNote.isEmpty ? null : staffNote;
      if (payload.isEmpty) return;
      await _client.from('orders').update(payload).eq('id', orderId);
      AppLogger.i(_tag, 'updateOrderFields success');
    } catch (e, st) {
      AppLogger.e(_tag, 'updateOrderFields failed', e, st);
      rethrow;
    }
  }

  @override
  Future<void> updateOrderItems({
    required String orderId,
    required List<Map<String, dynamic>> updatedItems,
    required List<String> deletedItemIds,
    required double newTotalPrice,
  }) async {
    AppLogger.net(_tag, 'updateOrderItems', 'orderId=$orderId updated=${updatedItems.length} deleted=${deletedItemIds.length}');
    try {
      for (final item in updatedItems) {
        await _client.from('order_items').update({
          'quantity': item['quantity'],
          'subtotal': item['subtotal'],
        }).eq('id', item['id'] as String);
      }
      for (final id in deletedItemIds) {
        await _client.from('order_items').delete().eq('id', id);
      }
      await _client.from('orders').update({'total_price': newTotalPrice}).eq('id', orderId);
      AppLogger.i(_tag, 'updateOrderItems success');
    } catch (e, st) {
      AppLogger.e(_tag, 'updateOrderItems failed', e, st);
      rethrow;
    }
  }

  @override
  Future<void> updateOrderDeliveryFee({
    required String orderId,
    required double fee,
    required double newTotalPrice,
  }) async {
    AppLogger.net(_tag, 'updateOrderDeliveryFee', 'orderId=$orderId fee=$fee');
    try {
      await _client.from('orders').update({
        'user_paid_delivery_fees': fee,
        'total_price': newTotalPrice,
      }).eq('id', orderId);
      AppLogger.i(_tag, 'updateOrderDeliveryFee success');
    } catch (e, st) {
      AppLogger.e(_tag, 'updateOrderDeliveryFee failed', e, st);
      rethrow;
    }
  }

  @override
  Future<void> updateOrderDeposit({required String orderId, required double deposit}) async {
    AppLogger.net(_tag, 'updateOrderDeposit', 'orderId=$orderId deposit=$deposit');
    try {
      await _client.from('orders').update({'deposit': deposit}).eq('id', orderId);
      AppLogger.i(_tag, 'updateOrderDeposit success');
    } catch (e, st) {
      AppLogger.e(_tag, 'updateOrderDeposit failed', e, st);
      rethrow;
    }
  }

  @override
  Future<void> updateOrderMaradia({required String orderId, required double maradia}) async {
    AppLogger.net(_tag, 'updateOrderMaradia', 'orderId=$orderId maradia=$maradia');
    try {
      await _client.from('orders').update({'maradia': maradia}).eq('id', orderId);
      AppLogger.i(_tag, 'updateOrderMaradia success');
    } catch (e, st) {
      AppLogger.e(_tag, 'updateOrderMaradia failed', e, st);
      rethrow;
    }
  }

  @override
  Future<String> createOrder({
    required Map<String, dynamic> orderData,
    required List<Map<String, dynamic>> items,
  }) async {
    AppLogger.net(_tag, 'createOrder', 'items=${items.length}');
    try {
      final orderRow = await _client
          .from('orders')
          .insert(orderData)
          .select('id')
          .single();
      final orderId = orderRow['id'] as String;
      AppLogger.d(_tag, 'createOrder → orderId=$orderId, inserting ${items.length} items');

      final itemsWithOrderId = items.map((item) => {
        ...item,
        'order_id': orderId,
      }).toList();

      await _client.from('order_items').insert(itemsWithOrderId);
      AppLogger.i(_tag, 'createOrder success orderId=$orderId');
      return orderId;
    } catch (e, st) {
      AppLogger.e(_tag, 'createOrder failed', e, st);
      rethrow;
    }
  }

  @override
  Future<void> addOrderHistory({
    required String orderId,
    required String action,
    String? actorId,
    String? actorName,
    String? actorRole,
  }) async {
    AppLogger.net(_tag, 'addOrderHistory', 'orderId=$orderId action=$action');
    try {
      await _client.from('order_history').insert({
        'order_id':   orderId,
        'action':     action,
        'actor_id':   actorId,
        'actor_name': actorName,
        'actor_role': actorRole,
      });
    } catch (e, st) {
      AppLogger.e(_tag, 'addOrderHistory failed', e, st);
      rethrow;
    }
  }

  @override
  Future<List<OrderHistoryModel>> getOrderHistory({required String orderId}) async {
    AppLogger.net(_tag, 'getOrderHistory', 'orderId=$orderId');
    try {
      final rows = await _client
          .from('order_history')
          .select()
          .eq('order_id', orderId)
          .order('created_at', ascending: true);
      return (rows as List)
          .map((r) => OrderHistoryModel.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      AppLogger.e(_tag, 'getOrderHistory failed', e, st);
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
