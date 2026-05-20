part of 'customers_cubit.dart';

enum CustomersStatus { initial, loading, success, failure }

class CustomersState extends Equatable {
  final CustomersStatus status;
  final List<Customer> customers;
  final String query;
  final String? errorMessage;
  final Customer? selectedCustomer;
  final List<OrderModel> customerOrders;
  final List<CustomerAddress> customerAddresses;
  final CustomersStatus detailStatus;
  final CustomersStatus actionStatus;
  final String? actionError;

  const CustomersState({
    this.status = CustomersStatus.initial,
    this.customers = const [],
    this.query = '',
    this.errorMessage,
    this.selectedCustomer,
    this.customerOrders = const [],
    this.customerAddresses = const [],
    this.detailStatus = CustomersStatus.initial,
    this.actionStatus = CustomersStatus.initial,
    this.actionError,
  });

  CustomersState copyWith({
    CustomersStatus? status,
    List<Customer>? customers,
    String? query,
    String? errorMessage,
    Customer? selectedCustomer,
    List<OrderModel>? customerOrders,
    List<CustomerAddress>? customerAddresses,
    CustomersStatus? detailStatus,
    CustomersStatus? actionStatus,
    String? actionError,
  }) =>
      CustomersState(
        status:            status            ?? this.status,
        customers:         customers         ?? this.customers,
        query:             query             ?? this.query,
        errorMessage:      errorMessage      ?? this.errorMessage,
        selectedCustomer:  selectedCustomer  ?? this.selectedCustomer,
        customerOrders:    customerOrders    ?? this.customerOrders,
        customerAddresses: customerAddresses ?? this.customerAddresses,
        detailStatus:      detailStatus      ?? this.detailStatus,
        actionStatus:      actionStatus      ?? this.actionStatus,
        actionError:       actionError       ?? this.actionError,
      );

  @override
  List<Object?> get props => [
        status, customers, query, errorMessage,
        selectedCustomer, customerOrders, customerAddresses,
        detailStatus, actionStatus, actionError,
      ];
}
