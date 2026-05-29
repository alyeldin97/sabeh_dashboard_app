import '../model/order_history_model.dart';
import '../model/order_model.dart';

abstract class OrdersDataSource {
  Future<List<OrderModel>> getOrders({String? branchId, OrderStatus? status});
  Future<List<OrderModel>> getOrdersByDate({required DateTime date, String? branchId});
  Future<List<OrderModel>> getOrdersByDateRange({required DateTime from, required DateTime to, String? branchId});
  Future<OrderModel> getOrder({required String orderId});
  Future<void> updateOrderStatus({required String orderId, required OrderStatus status});
  Future<void> updateOrderDriver({
    required String orderId,
    String? driverId,
    String? driverName,
  });
  Future<void> markOrderPaid({required String orderId, required bool isPaid, bool isCashOrder = false});
  Future<void> updateOrderFields({
    required String orderId,
    String? notes,
    String? deliveryAddress,
    String? paymentMethod,
    String? customerPhone,
    String? staffNote,
  });
  Future<void> updateOrderItems({
    required String orderId,
    required List<Map<String, dynamic>> updatedItems,
    required List<String> deletedItemIds,
    required double newTotalPrice,
  });
  Future<void> updateOrderDeliveryFee({
    required String orderId,
    required double fee,
    required double newTotalPrice,
  });
  Future<void> updateOrderDeposit({required String orderId, required double deposit});
  Future<void> updateOrderMaradia({required String orderId, required double maradia});
  Future<String> createOrder({
    required Map<String, dynamic> orderData,
    required List<Map<String, dynamic>> items,
  });
  Future<void> addOrderHistory({
    required String orderId,
    required String action,
    String? actorId,
    String? actorName,
    String? actorRole,
  });
  Future<List<OrderHistoryModel>> getOrderHistory({required String orderId});

  Stream<void> watchOrders({String? branchId});
  Future<void> stopWatchingOrders();
}
