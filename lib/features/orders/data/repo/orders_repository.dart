import '../model/order_model.dart';

abstract class OrdersRepository {
  Future<List<OrderModel>> getOrders({String? branchId, OrderStatus? status});
  Future<OrderModel> getOrder({required String orderId});
  Future<void> updateOrderStatus({required String orderId, required OrderStatus status});
  Stream<void> watchOrders({String? branchId});
  Future<void> stopWatchingOrders();
}
