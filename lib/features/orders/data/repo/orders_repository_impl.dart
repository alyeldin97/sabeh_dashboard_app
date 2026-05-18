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
  Future<OrderModel> getOrder({required String orderId}) =>
      _ds.getOrder(orderId: orderId);

  @override
  Future<void> updateOrderStatus({required String orderId, required OrderStatus status}) =>
      _ds.updateOrderStatus(orderId: orderId, status: status);

  @override
  Stream<void> watchOrders({String? branchId}) => _ds.watchOrders(branchId: branchId);

  @override
  Future<void> stopWatchingOrders() => _ds.stopWatchingOrders();
}
