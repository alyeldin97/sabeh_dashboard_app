import '../model/order_model.dart';

abstract class OrdersRepository {
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
  Stream<void> watchOrders({String? branchId});
  Future<void> stopWatchingOrders();
}
