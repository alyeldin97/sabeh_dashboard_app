import '../model/customer.dart';

abstract class CustomersRepository {
  Future<List<Customer>> getCustomers({String? search});
}
