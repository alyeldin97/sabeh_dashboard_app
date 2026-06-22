import 'dart:typed_data';
import '../model/order_history_model.dart';
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
  Future<List<OrderModel>> getOrdersByDateRange({required DateTime from, required DateTime to, String? branchId}) =>
      _ds.getOrdersByDateRange(from: from, to: to, branchId: branchId);

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
  Future<void> markOrderPaid({required String orderId, required bool isPaid, bool isCashOrder = false}) =>
      _ds.markOrderPaid(orderId: orderId, isPaid: isPaid, isCashOrder: isCashOrder);

  @override
  Future<void> updateOrderFields({
    required String orderId,
    String? notes,
    String? deliveryAddress,
    String? paymentMethod,
    String? customerPhone,
    String? staffNote,
    String? orderType,
  }) => _ds.updateOrderFields(
        orderId: orderId,
        notes: notes,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        customerPhone: customerPhone,
        staffNote: staffNote,
        orderType: orderType,
      );

  @override
  Future<void> updateOrderItems({
    required String orderId,
    required List<Map<String, dynamic>> updatedItems,
    required List<String> deletedItemIds,
    required double newTotalPrice,
  }) => _ds.updateOrderItems(
        orderId: orderId,
        updatedItems: updatedItems,
        deletedItemIds: deletedItemIds,
        newTotalPrice: newTotalPrice,
      );

  @override
  Future<void> updateOrderDeliveryFee({
    required String orderId,
    required double fee,
    required double newTotalPrice,
  }) => _ds.updateOrderDeliveryFee(orderId: orderId, fee: fee, newTotalPrice: newTotalPrice);

  @override
  Future<void> updateOrderDeposit({required String orderId, required double deposit}) =>
      _ds.updateOrderDeposit(orderId: orderId, deposit: deposit);

  @override
  Future<void> updateOrderMaradia({required String orderId, required double maradia}) =>
      _ds.updateOrderMaradia(orderId: orderId, maradia: maradia);

  @override
  Future<String> createOrder({
    required Map<String, dynamic> orderData,
    required List<Map<String, dynamic>> items,
  }) =>
      _ds.createOrder(orderData: orderData, items: items);

  @override
  Future<void> addOrderHistory({
    required String orderId,
    required String action,
    String? actorId,
    String? actorName,
    String? actorRole,
  }) => _ds.addOrderHistory(
        orderId: orderId,
        action: action,
        actorId: actorId,
        actorName: actorName,
        actorRole: actorRole,
      );

  @override
  Future<List<OrderHistoryModel>> getOrderHistory({required String orderId}) =>
      _ds.getOrderHistory(orderId: orderId);

  @override
  Stream<void> watchOrders({String? branchId}) => _ds.watchOrders(branchId: branchId);

  @override
  Future<void> stopWatchingOrders() => _ds.stopWatchingOrders();

  @override
  Future<String> uploadTransactionInvoiceImage({
    required String orderId,
    required Uint8List bytes,
    required String extension,
  }) => _ds.uploadTransactionInvoiceImage(orderId: orderId, bytes: bytes, extension: extension);

  @override
  Future<void> updateTransactionInvoice({
    required String orderId,
    String? imageUrl,
  }) => _ds.updateTransactionInvoice(orderId: orderId, imageUrl: imageUrl);
}
