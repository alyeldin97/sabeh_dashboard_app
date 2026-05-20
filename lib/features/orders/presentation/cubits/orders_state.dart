part of 'orders_cubit.dart';

enum OrdersStatus { initial, loading, success, failure }

enum OrdersCreateStatus { idle, loading, success, failure }

class OrdersState extends Equatable {
  final OrdersStatus status;
  final OrdersStatus detailStatus;
  final List<OrderModel> orders;
  final OrderModel? selectedOrder;
  final String? errorMessage;
  final OrdersCreateStatus createStatus;
  final String? createdOrderId;
  final String? createError;

  const OrdersState({
    this.status = OrdersStatus.initial,
    this.detailStatus = OrdersStatus.initial,
    this.orders = const [],
    this.selectedOrder,
    this.errorMessage,
    this.createStatus = OrdersCreateStatus.idle,
    this.createdOrderId,
    this.createError,
  });

  OrdersState copyWith({
    OrdersStatus? status,
    OrdersStatus? detailStatus,
    List<OrderModel>? orders,
    OrderModel? selectedOrder,
    String? errorMessage,
    OrdersCreateStatus? createStatus,
    String? createdOrderId,
    String? createError,
  }) =>
      OrdersState(
        status:         status         ?? this.status,
        detailStatus:   detailStatus   ?? this.detailStatus,
        orders:         orders         ?? this.orders,
        selectedOrder:  selectedOrder  ?? this.selectedOrder,
        errorMessage:   errorMessage   ?? this.errorMessage,
        createStatus:   createStatus   ?? this.createStatus,
        createdOrderId: createdOrderId ?? this.createdOrderId,
        createError:    createError    ?? this.createError,
      );

  @override
  List<Object?> get props => [
        status, detailStatus, orders, selectedOrder, errorMessage,
        createStatus, createdOrderId, createError,
      ];
}
