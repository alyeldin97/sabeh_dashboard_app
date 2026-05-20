import '../model/order_model.dart';
import '../remote/orders_data_source.dart';
import 'orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersDataSource _ds;
  OrdersRepositoryImpl(this._ds);

  @override
  Future<List<OrderModel>> getOrders({String? branchId, OrderStatus? status}) =>
      _ds.getOrders(branchId: branchId, status: status);

  @override
  Future<List<OrderModel>> getOrdersByDate({required DateTime date, String? branchId}) =>
      _ds.getOrdersByDate(date: date, branchId: branchId);

  @override
  Future<OrderModel> getOrder({required String orderId}) =>
      _ds.getOrder(orderId: orderId);

  @override
  Future<void> updateOrderStatus({required String orderId, required OrderStatus status}) =>
      _ds.updateOrderStatus(orderId: orderId, status: status);

  @override
  Future<void> updateOrderDriver({
    required String orderId,
    String? driverId,
    String? driverName,
  }) => _ds.updateOrderDriver(orderId: orderId, driverId: driverId, driverName: driverName);

  @override
  Future<String> createOrder({
    required Map<String, dynamic> orderData,
    required List<Map<String, dynamic>> items,
  }) =>
      _ds.createOrder(orderData: orderData, items: items);

  @override
  Stream<void> watchOrders({String? branchId}) => _ds.watchOrders(branchId: branchId);

  @override
  Future<void> stopWatchingOrders() => _ds.stopWatchingOrders();
}
