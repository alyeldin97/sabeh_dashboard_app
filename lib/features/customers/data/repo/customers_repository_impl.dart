import '../model/customer.dart';
import '../remote/customers_data_source.dart';
import 'customers_repository.dart';

class CustomersRepositoryImpl implements CustomersRepository {
  final CustomersDataSource _src;
  CustomersRepositoryImpl(this._src);

  @override
  Future<List<Customer>> getCustomers({String? search}) =>
      _src.getCustomers(search: search);
}
