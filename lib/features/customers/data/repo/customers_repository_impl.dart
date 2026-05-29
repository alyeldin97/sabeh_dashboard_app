import '../model/customer.dart';
import '../model/customer_address.dart';
import '../../../orders/data/model/order_model.dart';
import '../remote/customers_data_source.dart';
import 'customers_repository.dart';

class CustomersRepositoryImpl implements CustomersRepository {
  final CustomersDataSource _src;
  CustomersRepositoryImpl(this._src);

  @override
  Future<List<Customer>> getCustomers({String? search}) =>
      _src.getCustomers(search: search);

  @override
  Future<Customer> getCustomerById(String customerId) =>
      _src.getCustomerById(customerId);

  @override
  Future<List<OrderModel>> getCustomerOrders(String customerId) =>
      _src.getCustomerOrders(customerId);

  @override
  Future<List<CustomerAddress>> getCustomerAddresses(String customerId) =>
      _src.getCustomerAddresses(customerId);

  @override
  Future<void> updateInternalNotes(String customerId, String notes) =>
      _src.updateInternalNotes(customerId, notes);

  @override
  Future<void> adjustLoyaltyPoints(String customerId, int delta, String description) =>
      _src.adjustLoyaltyPoints(customerId, delta, description);

  @override
  Future<Customer> createCustomer({required String name, String? phone, String? email}) =>
      _src.createCustomer(name: name, phone: phone, email: email);

  @override
  Future<CustomerAddress> createCustomerAddress({
    required String customerId,
    String? label,
    required String street,
    String? building,
    String? floor,
    String? apartment,
    String? landmark,
    bool isDefault = false,
  }) => _src.createCustomerAddress(
    customerId: customerId,
    label: label,
    street: street,
    building: building,
    floor: floor,
    apartment: apartment,
    landmark: landmark,
    isDefault: isDefault,
  );
}
