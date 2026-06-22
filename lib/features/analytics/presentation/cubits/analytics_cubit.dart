import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../orders/data/model/order_model.dart';
import '../../../orders/data/repo/orders_repository.dart';

part 'analytics_state.dart';

// Internal helper returned by _loadEventData
class _EventData {
  final Map<String, int> eventCounts;
  final List<ProductFunnelEntry> funnelEntries;
  const _EventData({required this.eventCounts, required this.funnelEntries});
}

class AnalyticsCubit extends Cubit<AnalyticsState> {
  static const _tag = 'AnalyticsCubit';
  final OrdersRepository _repo;

  AnalyticsCubit(this._repo) : super(AnalyticsState(
    fromDate: _defaultFrom(),
    toDate:   _defaultTo(),
  )) {
    AppLogger.d(_tag, 'init');
  }

  static DateTime _defaultFrom() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
  }

  static DateTime _defaultTo() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  SupabaseClient get _client => Supabase.instance.client;

  // ── Public API ────────────────────────────────────────────────────────────

  void setDateRange(DateTime from, DateTime to) {
    emit(state.copyWith(
      fromDate: DateTime(from.year, from.month, from.day),
      toDate:   DateTime(to.year, to.month, to.day, 23, 59, 59),
    ));
  }

  void setBranch(String? branchId) {
    if (branchId == null) {
      emit(state.copyWith(clearBranch: true));
    } else {
      emit(state.copyWith(branchId: branchId));
    }
  }

  void setOnlineWindow(int minutes) {
    emit(state.copyWith(onlineWindowMinutes: minutes.clamp(1, 60)));
  }

  void toggleCompensationFilter() {
    emit(state.copyWith(showCompensationOnly: !state.showCompensationOnly));
    load();
  }

  Future<void> load({String? branchId}) async {
    final effectiveBranch = branchId ?? state.branchId;
    AppLogger.i(_tag, 'load from=${state.fromDate} to=${state.toDate} branch=$effectiveBranch');
    emit(state.copyWith(status: AnalyticsStatus.loading));
    try {
      final orders = await _repo.getOrders(branchId: effectiveBranch);
      var filtered = _filterByDateRange(orders, state.fromDate, state.toDate);
      if (state.showCompensationOnly) {
        filtered = filtered.where((o) => o.isCompensation).toList();
      }

      final futures = await Future.wait([
        _loadEventData(effectiveBranch, state.fromDate, state.toDate),
        _loadOnlineUsers(state.onlineWindowMinutes),
        _loadAbandonedCarts(state.fromDate, state.toDate),
        _loadDeviceTypeCounts(state.fromDate, state.toDate, effectiveBranch),
        _loadBranchNames(),
        _computeTotalCogs(filtered),
      ]);

      final eventData        = futures[0] as _EventData;
      final onlineUsers      = futures[1] as int;
      final abandonedCarts   = futures[2] as List<AbandonedCart>;
      final deviceTypeCounts = futures[3] as Map<String, int>;
      final branchNames      = futures[4] as Map<String, String>;
      final totalCogs        = futures[5] as double;

      final computed = _compute(filtered, eventData.eventCounts, branchNames);
      emit(computed.copyWith(
        status:               AnalyticsStatus.success,
        fromDate:             state.fromDate,
        toDate:               state.toDate,
        branchId:             effectiveBranch,
        onlineWindowMinutes:  state.onlineWindowMinutes,
        eventCounts:          eventData.eventCounts,
        onlineUsers:          onlineUsers,
        abandonedCarts:       abandonedCarts,
        deviceTypeCounts:     deviceTypeCounts,
        productFunnelEntries: eventData.funnelEntries,
        productFunnelLoading: false,
        totalCogs:            totalCogs,
      ));
    } catch (e, st) {
      AppLogger.e(_tag, 'load failed', e, st);
      emit(state.copyWith(status: AnalyticsStatus.failure, errorMessage: e.toString()));
    }
  }

  // ── Internals ─────────────────────────────────────────────────────────────

  List<OrderModel> _filterByDateRange(
      List<OrderModel> orders, DateTime from, DateTime to) =>
      orders.where((o) => !o.createdAt.isBefore(from) && !o.createdAt.isAfter(to)).toList();

  /// Fetches all analytics events, returns aggregate counts AND per-product funnel data.
  Future<_EventData> _loadEventData(
      String? branchId, DateTime from, DateTime to) async {
    try {
      dynamic q = _client
          .from('analytics_events')
          .select('event_type, product_id')
          .gte('created_at', from.toIso8601String())
          .lte('created_at', to.toIso8601String());
      if (branchId != null) q = q.eq('branch_id', branchId);
      final rows = await q as List<dynamic>;

      final eventCounts = <String, int>{};
      final viewMap     = <String, int>{};
      final cartMap     = <String, int>{};

      for (final r in rows) {
        final row       = r as Map<String, dynamic>;
        final type      = row['event_type'] as String? ?? '';
        final productId = row['product_id'] as String?;
        eventCounts[type] = (eventCounts[type] ?? 0) + 1;
        if (productId != null) {
          if (type == 'product_click') viewMap[productId] = (viewMap[productId] ?? 0) + 1;
          if (type == 'add_to_cart')   cartMap[productId] = (cartMap[productId] ?? 0) + 1;
        }
      }

      // Batch-fetch product names for every product seen in events
      final productIds = {...viewMap.keys, ...cartMap.keys}.toList();
      final nameMap    = <String, String>{};
      if (productIds.isNotEmpty) {
        try {
          final pRows = await _client
              .from('products')
              .select('id, name')
              .inFilter('id', productIds) as List<dynamic>;
          for (final r in pRows) {
            final row = r as Map<String, dynamic>;
            nameMap[row['id'] as String] = row['name'] as String;
          }
        } catch (_) {}
      }

      final entries = productIds
          .map((id) => ProductFunnelEntry(
                productId:   id,
                productName: nameMap[id] ?? id,
                viewCount:   viewMap[id] ?? 0,
                cartCount:   cartMap[id] ?? 0,
              ))
          .toList();

      return _EventData(eventCounts: eventCounts, funnelEntries: entries);
    } catch (_) {
      return const _EventData(eventCounts: {}, funnelEntries: []);
    }
  }

  /// Counts active customer sessions, excluding staff members.
  Future<int> _loadOnlineUsers(int windowMinutes) async {
    try {
      final threshold = DateTime.now().toUtc()
          .subtract(Duration(minutes: windowMinutes))
          .toIso8601String();

      // Fetch staff IDs to exclude
      final staffRows = await _client
          .from('staff_profiles')
          .select('id') as List<dynamic>;
      final staffIds = staffRows
          .map((r) => (r as Map<String, dynamic>)['id'] as String)
          .toList();

      dynamic q = _client
          .from('user_sessions')
          .select('id')
          .gte('last_seen_at', threshold)
          .isFilter('ended_at', null);

      if (staffIds.isNotEmpty) {
        q = q.not('user_id', 'in', '(${staffIds.join(',')})');
      }

      final rows = await q as List<dynamic>;
      return rows.length;
    } catch (_) {
      return 0;
    }
  }

  Future<List<AbandonedCart>> _loadAbandonedCarts(
      DateTime from, DateTime to) async {
    try {
      final sessionRows = await _client
          .from('user_sessions')
          .select('id, user_id, ended_at, device_type')
          .eq('did_checkout', false)
          .not('ended_at', 'is', null)
          .gte('ended_at', from.toIso8601String())
          .lte('ended_at', to.toIso8601String())
          .order('ended_at', ascending: false)
          .limit(100) as List<dynamic>;

      final userIds = sessionRows
          .map((r) => (r as Map<String, dynamic>)['user_id'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toSet()
          .toList();

      if (userIds.isEmpty) return [];

      final cartRows = await _client
          .from('cart_items')
          .select('user_id, cart_key, quantity, product:products!product_id(id, name, price)')
          .inFilter('user_id', userIds) as List<dynamic>;

      final customerRows = await _client
          .from('customer_profiles')
          .select('id, name, phone')
          .inFilter('id', userIds) as List<dynamic>;

      final cartsByUser = <String, List<AbandonedItem>>{};
      for (final r in cartRows) {
        final row  = r as Map<String, dynamic>;
        final uid  = row['user_id'] as String?;
        if (uid == null) continue;
        final prod = row['product'] as Map<String, dynamic>?;
        if (prod == null) continue;
        cartsByUser.putIfAbsent(uid, () => []).add(AbandonedItem(
          productName: prod['name'] as String? ?? '?',
          quantity:    row['quantity'] as int? ?? 1,
          unitPrice:   (prod['price'] as num?)?.toDouble() ?? 0,
        ));
      }

      final customerMap = <String, Map<String, dynamic>>{};
      for (final r in customerRows) {
        final row = r as Map<String, dynamic>;
        final id  = row['id'] as String?;
        if (id != null) customerMap[id] = row;
      }

      final seen   = <String>{};
      final result = <AbandonedCart>[];
      for (final r in sessionRows) {
        final row   = r as Map<String, dynamic>;
        final uid   = row['user_id'] as String?;
        if (uid == null || seen.contains(uid)) continue;
        final items = cartsByUser[uid];
        if (items == null || items.isEmpty) continue;
        seen.add(uid);
        final customer   = customerMap[uid];
        final endedAtStr = row['ended_at'] as String?;
        result.add(AbandonedCart(
          sessionId:     row['id'] as String,
          customerName:  customer?['name'] as String?,
          customerPhone: customer?['phone'] as String?,
          abandonedAt:   endedAtStr != null
              ? DateTime.parse(endedAtStr).toLocal()
              : DateTime.now(),
          deviceType:    row['device_type'] as String?,
          items:         items,
        ));
      }
      return result;
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, int>> _loadDeviceTypeCounts(
      DateTime from, DateTime to, String? branchId) async {
    try {
      dynamic q = _client
          .from('user_sessions')
          .select('device_type')
          .gte('started_at', from.toIso8601String())
          .lte('started_at', to.toIso8601String());
      if (branchId != null) q = q.eq('branch_id', branchId);
      final rows   = await q as List<dynamic>;
      final counts = <String, int>{};
      for (final r in rows) {
        final type = (r as Map<String, dynamic>)['device_type'] as String? ?? 'unknown';
        counts[type] = (counts[type] ?? 0) + 1;
      }
      return counts;
    } catch (_) {
      return {};
    }
  }

  static bool _isBillable(OrderModel o) =>
      o.status != OrderStatus.cancelled && o.status != OrderStatus.rejected;

  Future<double> _computeTotalCogs(List<OrderModel> orders) async {
    final productIds = orders
        .where(_isBillable)
        .expand((o) => o.items)
        .where((i) => i.productId != null)
        .map((i) => i.productId!)
        .toSet()
        .toList();
    if (productIds.isEmpty) return 0;
    try {
      final rows = await _client
          .from('products')
          .select('id, cogs_percent')
          .inFilter('id', productIds) as List<dynamic>;
      final cogsMap = <String, double>{};
      for (final r in rows) {
        final row = r as Map<String, dynamic>;
        final pct = (row['cogs_percent'] as num?)?.toDouble();
        if (pct != null) cogsMap[row['id'] as String] = pct;
      }
      double total = 0;
      for (final o in orders.where(_isBillable)) {
        for (final item in o.items) {
          if (item.productId != null) {
            final pct = cogsMap[item.productId];
            if (pct != null) total += item.subtotal * pct / 100;
          }
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  Future<Map<String, String>> _loadBranchNames() async {
    try {
      final rows = await _client
          .from('branches')
          .select('id, name') as List<dynamic>;
      return {
        for (final r in rows)
          (r as Map<String, dynamic>)['id'] as String: r['name'] as String,
      };
    } catch (_) {
      return {};
    }
  }

  AnalyticsState _compute(
    List<OrderModel> orders,
    Map<String, int> eventCounts,
    Map<String, String> branchNames,
  ) {
    double totalSales              = 0;
    double totalDelivery           = 0;
    double totalDiscounts          = 0;
    double loyaltyDiscTotal        = 0;
    double promoDiscTotal          = 0;
    double freeDeliveryDiscTotal   = 0;
    int freeDeliveryCount          = 0;
    int freeItemOrderCount         = 0;

    int fulfilled = 0, cancelled = 0;
    int pending = 0, confirmed = 0, preparing = 0, otd = 0;

    final productRevMap  = <String, double>{};
    final productQtyMap  = <String, int>{};
    final customerOrders = <String, int>{};
    final dailyMap       = <String, double>{};
    final branchSalesMap = <String, double>{};
    final branchOrderMap = <String, int>{};

    for (final o in orders) {
      if (_isBillable(o)) {
        totalSales       += o.totalPrice;
        totalDelivery    += o.userPaidDeliveryFees;
        loyaltyDiscTotal += o.loyaltyDiscount;
        promoDiscTotal   += o.promoDiscount;
        totalDiscounts   += o.loyaltyDiscount + o.promoDiscount;

        if (o.zoneDeliveryFee > o.userPaidDeliveryFees && o.deliveryAddress != null) {
          freeDeliveryCount++;
          freeDeliveryDiscTotal += o.zoneDeliveryFee - o.userPaidDeliveryFees;
        }
        if (o.loyaltyCatalogReward != null || o.spendGoalReward != null) freeItemOrderCount++;

        if (o.branchId != null) {
          branchSalesMap[o.branchId!] = (branchSalesMap[o.branchId!] ?? 0) + o.totalPrice;
          branchOrderMap[o.branchId!] = (branchOrderMap[o.branchId!] ?? 0) + 1;
        }
      }

      switch (o.status) {
        case OrderStatus.delivered:      fulfilled++;  break;
        case OrderStatus.cancelled:      cancelled++;  break;
        case OrderStatus.rejected:       cancelled++;  break;
        case OrderStatus.pending:        pending++;    break;
        case OrderStatus.confirmed:      confirmed++;  break;
        case OrderStatus.preparing:      preparing++;  break;
        case OrderStatus.prepared:       preparing++;  break;
        case OrderStatus.outForDelivery: otd++;        break;
      }

      for (final item in o.items) {
        if (_isBillable(o)) {
          productRevMap[item.productName] =
              (productRevMap[item.productName] ?? 0) + item.subtotal;
          productQtyMap[item.productName] =
              (productQtyMap[item.productName] ?? 0) + item.quantity;
        }
      }

      if (o.customerId != null) {
        customerOrders[o.customerId!] = (customerOrders[o.customerId!] ?? 0) + 1;
      }

      final dayKey =
          '${o.createdAt.year}-${o.createdAt.month.toString().padLeft(2, '0')}-${o.createdAt.day.toString().padLeft(2, '0')}';
      if (_isBillable(o)) {
        dailyMap[dayKey] = (dailyMap[dayKey] ?? 0) + o.totalPrice;
      }
    }

    final totalOrders  = orders.length;
    final nonCancelled = orders.where(_isBillable).length;

    final salesByZone = branchSalesMap.entries
        .map((e) => ZoneSales(
              zoneName:   branchNames[e.key] ?? e.key,
              sales:      e.value,
              orderCount: branchOrderMap[e.key] ?? 0,
            ))
        .toList()
      ..sort((a, b) => b.sales.compareTo(a.sales));

    final topByRevenue = productRevMap.entries
        .map((e) => TopProduct(
              name:     e.key,
              quantity: productQtyMap[e.key] ?? 0,
              revenue:  e.value,
            ))
        .toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    final topByQty = productQtyMap.entries
        .map((e) => TopProduct(
              name:     e.key,
              quantity: e.value,
              revenue:  productRevMap[e.key] ?? 0,
            ))
        .toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));

    final dailySales = (dailyMap.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key)))
        .map((e) => DailySeries(date: DateTime.parse(e.key), value: e.value))
        .toList();

    return AnalyticsState(
      fromDate:              state.fromDate,
      toDate:                state.toDate,
      onlineWindowMinutes:   state.onlineWindowMinutes,
      totalSales:            totalSales,
      orderVolume:           totalOrders,
      avgOrderValue:         nonCancelled > 0 ? totalSales / nonCancelled : 0,
      totalDeliveryCharges:      totalDelivery,
      totalDiscounts:            totalDiscounts,
      loyaltyDiscountTotal:      loyaltyDiscTotal,
      promoDiscountTotal:        promoDiscTotal,
      freeDeliveryDiscountTotal: freeDeliveryDiscTotal,
      freeDeliveryCount:         freeDeliveryCount,
      freeItemOrderCount:    freeItemOrderCount,
      fulfilledCount:        fulfilled,
      cancelledCount:        cancelled,
      fulfilledRate:         totalOrders > 0 ? fulfilled / totalOrders : 0,
      cancellationRate:      totalOrders > 0 ? cancelled / totalOrders : 0,
      totalUniqueCustomers:  customerOrders.length,
      returningCustomers:    customerOrders.values.where((v) => v > 1).length,
      returningCustomerRate: customerOrders.isNotEmpty
          ? customerOrders.values.where((v) => v > 1).length / customerOrders.length
          : 0,
      salesByZone:           salesByZone,
      topProductsByRevenue:  topByRevenue.take(50).toList(),
      topProductsByQty:      topByQty.take(50).toList(),
      dailySales:            dailySales,
      pendingCount:          pending,
      confirmedCount:        confirmed,
      preparingCount:        preparing,
      outForDeliveryCount:   otd,
      eventCounts:           eventCounts,
    );
  }
}
