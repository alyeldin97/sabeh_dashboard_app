part of 'orders_cubit.dart';

enum OrdersStatus { initial, loading, success, failure }

class OrdersState extends Equatable {
  final OrdersStatus status;
  final OrdersStatus detailStatus;
  final List<OrderModel> orders;
  final OrderModel? selectedOrder;
  final String? errorMessage;

  const OrdersState({
    this.status = OrdersStatus.initial,
    this.detailStatus = OrdersStatus.initial,
    this.orders = const [],
    this.selectedOrder,
    this.errorMessage,
  });

  OrdersState copyWith({
    OrdersStatus? status,
    OrdersStatus? detailStatus,
    List<OrderModel>? orders,
    OrderModel? selectedOrder,
    String? errorMessage,
  }) =>
      OrdersState(
        status:        status        ?? this.status,
        detailStatus:  detailStatus  ?? this.detailStatus,
        orders:        orders        ?? this.orders,
        selectedOrder: selectedOrder ?? this.selectedOrder,
        errorMessage:  errorMessage  ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, detailStatus, orders, selectedOrder, errorMessage];
}
