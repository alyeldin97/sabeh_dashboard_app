import '../model/order_model.dart';

abstract class OrdersDataSource {
  Future<List<OrderModel>> getOrders({String? branchId, OrderStatus? status});
  Future<OrderModel> getOrder({required String orderId});
  Future<void> updateOrderStatus({required String orderId, required OrderStatus status});

  /// Emits once whenever any row in the orders table changes.
  /// Caller is responsible for cancelling the subscription.
  Stream<void> watchOrders({String? branchId});

  /// Cancel the channel opened by [watchOrders].
  Future<void> stopWatchingOrders();
}
