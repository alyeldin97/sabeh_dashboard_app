import '../model/customer.dart';
import '../model/customer_address.dart';
import '../../../orders/data/model/order_model.dart';

abstract class CustomersDataSource {
  Future<List<Customer>> getCustomers({String? search});
  Future<Customer> getCustomerById(String customerId);
  Future<List<OrderModel>> getCustomerOrders(String customerId);
  Future<List<CustomerAddress>> getCustomerAddresses(String customerId);
  Future<void> updateInternalNotes(String customerId, String notes);
  Future<void> adjustLoyaltyPoints(String customerId, int delta, String description, {String? reason});
  Future<Customer> createCustomer({required String name, String? phone, String? email});
  Future<CustomerAddress> createCustomerAddress({
    required String customerId,
    String? label,
    required String street,
    String? building,
    String? floor,
    String? apartment,
    String? landmark,
    bool isDefault = false,
  });
}
