import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/model/customer.dart';
import '../../data/repo/customers_repository.dart';

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
}
