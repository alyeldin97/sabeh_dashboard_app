import '../model/order_model.dart';

abstract class OrdersDataSource {
  Future<List<OrderModel>> getOrders({String? branchId, OrderStatus? status});
  Future<List<OrderModel>> getOrdersByDate({required DateTime date, String? branchId});
  Future<OrderModel> getOrder({required String orderId});
  Future<void> updateOrderStatus({required String orderId, required OrderStatus status});
  Future<void> updateOrderDriver({
    required String orderId,
    String? driverId,
    String? driverName,
  });
  Future<String> createOrder({
    required Map<String, dynamic> orderData,
    required List<Map<String, dynamic>> items,
  });

  /// Emits once whenever any row in the orders table changes.
  Stream<void> watchOrders({String? branchId});

  /// Cancel the channel opened by [watchOrders].
  Future<void> stopWatchingOrders();
}
