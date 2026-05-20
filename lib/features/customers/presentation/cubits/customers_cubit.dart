import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/model/customer.dart';
import '../../data/model/customer_address.dart';
import '../../data/repo/customers_repository.dart';
import '../../../orders/data/model/order_model.dart';

part 'customers_state.dart';

class CustomersCubit extends Cubit<CustomersState> {
  static const _tag = 'CustomersCubit';
  final CustomersRepository _repo;

  CustomersCubit(this._repo) : super(const CustomersState()) {
    AppLogger.d(_tag, 'init');
  }

  Future<void> load({String? search}) async {
    AppLogger.i(_tag, 'load search=$search');
    emit(state.copyWith(status: CustomersStatus.loading, query: search ?? ''));
    try {
      final customers = await _repo.getCustomers(
        search: (search?.isNotEmpty == true) ? search : null,
      );
      AppLogger.i(_tag, 'load → ${customers.length} customers');
      emit(state.copyWith(status: CustomersStatus.success, customers: customers));
    } catch (e, st) {
      AppLogger.e(_tag, 'load failed', e, st);
      emit(state.copyWith(status: CustomersStatus.failure, errorMessage: e.toString()));
    }
  }

  void search(String query) {
    AppLogger.d(_tag, 'search query=$query');
    load(search: query);
  }

  void selectCustomer(Customer customer) {
    AppLogger.d(_tag, 'selectCustomer id=${customer.id}');
    emit(state.copyWith(selectedCustomer: customer));
  }

  Future<void> loadCustomerDetail(String customerId) async {
    AppLogger.i(_tag, 'loadCustomerDetail id=$customerId');
    emit(state.copyWith(
      detailStatus: CustomersStatus.loading,
      customerOrders: const [],
    ));
    try {
      final results = await Future.wait([
        _repo.getCustomerById(customerId),
        _repo.getCustomerOrders(customerId),
      ]);
      final customer = results[0] as Customer;
      final orders = results[1] as List<OrderModel>;
      AppLogger.i(_tag, 'loadCustomerDetail → orders=${orders.length}');
      emit(state.copyWith(
        detailStatus:    CustomersStatus.success,
        selectedCustomer: customer,
        customerOrders:  orders,
      ));
    } catch (e, st) {
      AppLogger.e(_tag, 'loadCustomerDetail failed', e, st);
      emit(state.copyWith(
        detailStatus: CustomersStatus.failure,
        actionError:  e.toString(),
      ));
    }
  }

  Future<void> updateNotes(String customerId, String notes) async {
    AppLogger.i(_tag, 'updateNotes id=$customerId');
    emit(state.copyWith(actionStatus: CustomersStatus.loading, actionError: null));
    try {
      await _repo.updateInternalNotes(customerId, notes);
      AppLogger.i(_tag, 'updateNotes success');
      final updated = state.selectedCustomer?.copyWith(internalNotes: notes);
      emit(state.copyWith(
        actionStatus:    CustomersStatus.success,
        selectedCustomer: updated ?? state.selectedCustomer,
      ));
    } catch (e, st) {
      AppLogger.e(_tag, 'updateNotes failed', e, st);
      emit(state.copyWith(
        actionStatus: CustomersStatus.failure,
        actionError:  e.toString(),
      ));
    }
  }

  Future<void> adjustPoints(
    String customerId,
    int delta,
    String description,
  ) async {
    AppLogger.i(_tag, 'adjustPoints id=$customerId delta=$delta');
    emit(state.copyWith(actionStatus: CustomersStatus.loading, actionError: null));
    try {
      await _repo.adjustLoyaltyPoints(customerId, delta, description);
      AppLogger.i(_tag, 'adjustPoints success, reloading detail');
      emit(state.copyWith(actionStatus: CustomersStatus.success));
      await loadCustomerDetail(customerId);
    } catch (e, st) {
      AppLogger.e(_tag, 'adjustPoints failed', e, st);
      emit(state.copyWith(
        actionStatus: CustomersStatus.failure,
        actionError:  e.toString(),
      ));
    }
  }

  Future<void> loadCustomerAddresses(String customerId) async {
    AppLogger.i(_tag, 'loadCustomerAddresses id=$customerId');
    try {
      final addresses = await _repo.getCustomerAddresses(customerId);
      AppLogger.i(_tag, 'loadCustomerAddresses → ${addresses.length} addresses');
      emit(state.copyWith(customerAddresses: addresses));
    } catch (e, st) {
      AppLogger.e(_tag, 'loadCustomerAddresses failed', e, st);
      emit(state.copyWith(customerAddresses: const []));
    }
  }

  Future<Customer> createCustomer({
    required String name,
    String? phone,
    String? email,
  }) async {
    AppLogger.i(_tag, 'createCustomer name=$name');
    final customer = await _repo.createCustomer(name: name, phone: phone, email: email);
    AppLogger.i(_tag, 'createCustomer → id=${customer.id}');
    emit(state.copyWith(customers: [customer, ...state.customers]));
    return customer;
  }
}
