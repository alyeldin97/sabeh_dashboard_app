part of 'analytics_cubit.dart';

enum AnalyticsStatus { initial, loading, success, failure }

// ── Data Models ───────────────────────────────────────────────────────────────

class TopProduct {
  final String name;
  final int quantity;
  final double revenue;
  const TopProduct({required this.name, required this.quantity, required this.revenue});
}

class DailySeries {
  final DateTime date;
  final double value;
  const DailySeries({required this.date, required this.value});
}

class ZoneSales {
  final String zoneName;
  final double sales;
  final int orderCount;
  const ZoneSales({required this.zoneName, required this.sales, required this.orderCount});
}

class AbandonedItem {
  final String productName;
  final int quantity;
  final double unitPrice;
  const AbandonedItem({required this.productName, required this.quantity, required this.unitPrice});
  double get subtotal => unitPrice * quantity;
}

class AbandonedCart {
  final String sessionId;
  final String? customerName;
  final String? customerPhone;
  final DateTime abandonedAt;
  final String? deviceType;
  final List<AbandonedItem> items;
  const AbandonedCart({
    required this.sessionId,
    this.customerName,
    this.customerPhone,
    required this.abandonedAt,
    this.deviceType,
    required this.items,
  });
  double get cartTotal => items.fold(0, (s, i) => s + i.subtotal);
}

class ProductFunnelEntry {
  final String productId;
  final String productName;
  final int viewCount;
  final int cartCount;
  const ProductFunnelEntry({
    required this.productId,
    required this.productName,
    required this.viewCount,
    required this.cartCount,
  });
  double get conversionRate => viewCount > 0 ? cartCount / viewCount : 0.0;
}

// ── State ─────────────────────────────────────────────────────────────────────

class AnalyticsState extends Equatable {
  final AnalyticsStatus status;
  final String? errorMessage;

  // Active filters
  final DateTime fromDate;
  final DateTime toDate;
  final String? branchId;
  final int onlineWindowMinutes;

  // Core KPIs
  final double totalSales;
  final int orderVolume;
  final double avgOrderValue;
  final double totalCogs;

  // Delivery & discounts
  final double totalDeliveryCharges;
  final double totalDiscounts;
  final double loyaltyDiscountTotal;
  final double promoDiscountTotal;
  final double freeDeliveryDiscountTotal;
  final int freeDeliveryCount;
  final int freeItemOrderCount;

  // Fulfillment rates
  final int fulfilledCount;
  final int cancelledCount;
  final double fulfilledRate;
  final double cancellationRate;

  // Customer metrics
  final int totalUniqueCustomers;
  final int returningCustomers;
  final double returningCustomerRate;

  // Online users (live, customers only)
  final int onlineUsers;

  // Sales by delivery zone (branch)
  final List<ZoneSales> salesByZone;

  // Abandoned carts
  final List<AbandonedCart> abandonedCarts;

  // Device type session breakdown
  final Map<String, int> deviceTypeCounts;

  // Top products (up to 50)
  final List<TopProduct> topProductsByRevenue;
  final List<TopProduct> topProductsByQty;

  // Daily sales chart
  final List<DailySeries> dailySales;

  // Status breakdown
  final int pendingCount;
  final int confirmedCount;
  final int preparingCount;
  final int outForDeliveryCount;

  // Event tracking (aggregate)
  final Map<String, int> eventCounts;

  // Product funnel — all products, views + add-to-cart
  final List<ProductFunnelEntry> productFunnelEntries;
  final bool productFunnelLoading;

  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.errorMessage,
    required this.fromDate,
    required this.toDate,
    this.branchId,
    this.onlineWindowMinutes = 3,
    this.totalSales = 0,
    this.orderVolume = 0,
    this.avgOrderValue = 0,
    this.totalCogs = 0,
    this.totalDeliveryCharges = 0,
    this.totalDiscounts = 0,
    this.loyaltyDiscountTotal = 0,
    this.promoDiscountTotal = 0,
    this.freeDeliveryDiscountTotal = 0,
    this.freeDeliveryCount = 0,
    this.freeItemOrderCount = 0,
    this.fulfilledCount = 0,
    this.cancelledCount = 0,
    this.fulfilledRate = 0,
    this.cancellationRate = 0,
    this.totalUniqueCustomers = 0,
    this.returningCustomers = 0,
    this.returningCustomerRate = 0,
    this.onlineUsers = 0,
    this.salesByZone = const [],
    this.abandonedCarts = const [],
    this.deviceTypeCounts = const {},
    this.topProductsByRevenue = const [],
    this.topProductsByQty = const [],
    this.dailySales = const [],
    this.pendingCount = 0,
    this.confirmedCount = 0,
    this.preparingCount = 0,
    this.outForDeliveryCount = 0,
    this.eventCounts = const {},
    this.productFunnelEntries = const [],
    this.productFunnelLoading = false,
  });

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    String? errorMessage,
    DateTime? fromDate,
    DateTime? toDate,
    String? branchId,
    bool clearBranch = false,
    int? onlineWindowMinutes,
    double? totalSales,
    int? orderVolume,
    double? avgOrderValue,
    double? totalCogs,
    double? totalDeliveryCharges,
    double? totalDiscounts,
    double? loyaltyDiscountTotal,
    double? promoDiscountTotal,
    double? freeDeliveryDiscountTotal,
    int? freeDeliveryCount,
    int? freeItemOrderCount,
    int? fulfilledCount,
    int? cancelledCount,
    double? fulfilledRate,
    double? cancellationRate,
    int? totalUniqueCustomers,
    int? returningCustomers,
    double? returningCustomerRate,
    int? onlineUsers,
    List<ZoneSales>? salesByZone,
    List<AbandonedCart>? abandonedCarts,
    Map<String, int>? deviceTypeCounts,
    List<TopProduct>? topProductsByRevenue,
    List<TopProduct>? topProductsByQty,
    List<DailySeries>? dailySales,
    int? pendingCount,
    int? confirmedCount,
    int? preparingCount,
    int? outForDeliveryCount,
    Map<String, int>? eventCounts,
    List<ProductFunnelEntry>? productFunnelEntries,
    bool? productFunnelLoading,
  }) =>
      AnalyticsState(
        status:                status                ?? this.status,
        errorMessage:          errorMessage          ?? this.errorMessage,
        fromDate:              fromDate              ?? this.fromDate,
        toDate:                toDate                ?? this.toDate,
        branchId:              clearBranch ? null    : branchId ?? this.branchId,
        onlineWindowMinutes:   onlineWindowMinutes   ?? this.onlineWindowMinutes,
        totalSales:            totalSales            ?? this.totalSales,
        orderVolume:           orderVolume           ?? this.orderVolume,
        avgOrderValue:         avgOrderValue         ?? this.avgOrderValue,
        totalCogs:             totalCogs             ?? this.totalCogs,
        totalDeliveryCharges:  totalDeliveryCharges  ?? this.totalDeliveryCharges,
        totalDiscounts:            totalDiscounts            ?? this.totalDiscounts,
        loyaltyDiscountTotal:      loyaltyDiscountTotal      ?? this.loyaltyDiscountTotal,
        promoDiscountTotal:        promoDiscountTotal        ?? this.promoDiscountTotal,
        freeDeliveryDiscountTotal: freeDeliveryDiscountTotal ?? this.freeDeliveryDiscountTotal,
        freeDeliveryCount:         freeDeliveryCount         ?? this.freeDeliveryCount,
        freeItemOrderCount:    freeItemOrderCount    ?? this.freeItemOrderCount,
        fulfilledCount:        fulfilledCount        ?? this.fulfilledCount,
        cancelledCount:        cancelledCount        ?? this.cancelledCount,
        fulfilledRate:         fulfilledRate         ?? this.fulfilledRate,
        cancellationRate:      cancellationRate      ?? this.cancellationRate,
        totalUniqueCustomers:  totalUniqueCustomers  ?? this.totalUniqueCustomers,
        returningCustomers:    returningCustomers    ?? this.returningCustomers,
        returningCustomerRate: returningCustomerRate ?? this.returningCustomerRate,
        onlineUsers:           onlineUsers           ?? this.onlineUsers,
        salesByZone:           salesByZone           ?? this.salesByZone,
        abandonedCarts:        abandonedCarts        ?? this.abandonedCarts,
        deviceTypeCounts:      deviceTypeCounts      ?? this.deviceTypeCounts,
        topProductsByRevenue:  topProductsByRevenue  ?? this.topProductsByRevenue,
        topProductsByQty:      topProductsByQty      ?? this.topProductsByQty,
        dailySales:            dailySales            ?? this.dailySales,
        pendingCount:          pendingCount          ?? this.pendingCount,
        confirmedCount:        confirmedCount        ?? this.confirmedCount,
        preparingCount:        preparingCount        ?? this.preparingCount,
        outForDeliveryCount:   outForDeliveryCount   ?? this.outForDeliveryCount,
        eventCounts:           eventCounts           ?? this.eventCounts,
        productFunnelEntries:  productFunnelEntries  ?? this.productFunnelEntries,
        productFunnelLoading:  productFunnelLoading  ?? this.productFunnelLoading,
      );

  @override
  List<Object?> get props => [
        status, errorMessage, fromDate, toDate, branchId, onlineWindowMinutes,
        totalSales, orderVolume, avgOrderValue, totalCogs,
        totalDeliveryCharges, totalDiscounts, loyaltyDiscountTotal, promoDiscountTotal,
        freeDeliveryDiscountTotal, freeDeliveryCount, freeItemOrderCount,
        fulfilledCount, cancelledCount, fulfilledRate, cancellationRate,
        totalUniqueCustomers, returningCustomers, returningCustomerRate,
        onlineUsers, salesByZone, abandonedCarts, deviceTypeCounts,
        topProductsByRevenue, topProductsByQty, dailySales,
        pendingCount, confirmedCount, preparingCount, outForDeliveryCount,
        eventCounts, productFunnelEntries, productFunnelLoading,
      ];
}
