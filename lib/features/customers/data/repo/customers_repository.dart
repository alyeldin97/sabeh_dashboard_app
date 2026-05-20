import '../model/customer.dart';
import '../model/customer_address.dart';
import '../../../orders/data/model/order_model.dart';

abstract class CustomersRepository {
  Future<List<Customer>> getCustomers({String? search});
  Future<Customer> getCustomerById(String customerId);
  Future<List<OrderModel>> getCustomerOrders(String customerId);
  Future<List<CustomerAddress>> getCustomerAddresses(String customerId);
  Future<void> updateInternalNotes(String customerId, String notes);
  Future<void> adjustLoyaltyPoints(String customerId, int delta, String description);
  Future<Customer> createCustomer({required String name, String? phone, String? email});
}
