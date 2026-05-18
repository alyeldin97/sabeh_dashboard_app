part of 'analytics_cubit.dart';

enum AnalyticsStatus { initial, loading, success, failure }

class TopProduct {
  final String name;
  final int quantity;
  final double revenue;
  const TopProduct({required this.name, required this.quantity, required this.revenue});
}

class AnalyticsState extends Equatable {
  final AnalyticsStatus status;
  final String? errorMessage;

  final double todayRevenue;
  final double weekRevenue;
  final double monthRevenue;
  final int totalOrders;
  final int todayOrders;

  final int pendingCount;
  final int confirmedCount;
  final int preparingCount;
  final int outForDeliveryCount;
  final int deliveredCount;
  final int cancelledCount;

  final List<TopProduct> topProducts;

  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.errorMessage,
    this.todayRevenue = 0,
    this.weekRevenue = 0,
    this.monthRevenue = 0,
    this.totalOrders = 0,
    this.todayOrders = 0,
    this.pendingCount = 0,
    this.confirmedCount = 0,
    this.preparingCount = 0,
    this.outForDeliveryCount = 0,
    this.deliveredCount = 0,
    this.cancelledCount = 0,
    this.topProducts = const [],
  });

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    String? errorMessage,
    double? todayRevenue,
    double? weekRevenue,
    double? monthRevenue,
    int? totalOrders,
    int? todayOrders,
    int? pendingCount,
    int? confirmedCount,
    int? preparingCount,
    int? outForDeliveryCount,
    int? deliveredCount,
    int? cancelledCount,
    List<TopProduct>? topProducts,
  }) =>
      AnalyticsState(
        status:              status              ?? this.status,
        errorMessage:        errorMessage        ?? this.errorMessage,
        todayRevenue:        todayRevenue        ?? this.todayRevenue,
        weekRevenue:         weekRevenue         ?? this.weekRevenue,
        monthRevenue:        monthRevenue        ?? this.monthRevenue,
        totalOrders:         totalOrders         ?? this.totalOrders,
        todayOrders:         todayOrders         ?? this.todayOrders,
        pendingCount:        pendingCount        ?? this.pendingCount,
        confirmedCount:      confirmedCount      ?? this.confirmedCount,
        preparingCount:      preparingCount      ?? this.preparingCount,
        outForDeliveryCount: outForDeliveryCount ?? this.outForDeliveryCount,
        deliveredCount:      deliveredCount      ?? this.deliveredCount,
        cancelledCount:      cancelledCount      ?? this.cancelledCount,
        topProducts:         topProducts         ?? this.topProducts,
      );

  @override
  List<Object?> get props => [
        status, errorMessage, todayRevenue, weekRevenue, monthRevenue,
        totalOrders, todayOrders, pendingCount, confirmedCount, preparingCount,
        outForDeliveryCount, deliveredCount, cancelledCount, topProducts,
      ];
}
