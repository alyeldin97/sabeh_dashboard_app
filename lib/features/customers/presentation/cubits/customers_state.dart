part of 'customers_cubit.dart';

enum CustomersStatus { initial, loading, success, failure }

class CustomersState extends Equatable {
  final CustomersStatus status;
  final List<Customer> customers;
  final String query;
  final String? errorMessage;

  const CustomersState({
    this.status = CustomersStatus.initial,
    this.customers = const [],
    this.query = '',
    this.errorMessage,
  });

  CustomersState copyWith({
    CustomersStatus? status,
    List<Customer>? customers,
    String? query,
    String? errorMessage,
  }) => CustomersState(
        status: status ?? this.status,
        customers: customers ?? this.customers,
        query: query ?? this.query,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, customers, query, errorMessage];
}
