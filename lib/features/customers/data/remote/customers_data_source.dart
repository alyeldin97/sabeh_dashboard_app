import '../model/customer.dart';

abstract class CustomersDataSource {
  Future<List<Customer>> getCustomers({String? search});
}
