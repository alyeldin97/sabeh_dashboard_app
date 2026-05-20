import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/expenses_repository.dart';
import 'expenses_state.dart';

class ExpensesCubit extends Cubit<ExpensesState> {
  final ExpensesRepository _repo;
  ExpensesCubit(this._repo) : super(const ExpensesState());

  Future<void> loadForDate(DateTime date, {String? branchId}) async {
    emit(state.copyWith(status: ExpensesStatus.loading));
    try {
      final expenses = await _repo.getExpensesByDate(date: date, branchId: branchId);
      emit(state.copyWith(status: ExpensesStatus.success, expenses: expenses));
    } catch (e) {
      emit(state.copyWith(status: ExpensesStatus.failure, error: e.toString()));
    }
  }

  Future<void> add({
    required String name,
    required double value,
    required DateTime date,
    String? branchId,
  }) async {
    try {
      final data = {
        'name':  name,
        'value': value,
        'date':  _fmt(date),
        if (branchId != null) 'branch_id': branchId,
      };
      final created = await _repo.createExpense(data: data);
      emit(state.copyWith(expenses: [...state.expenses, created]));
    } catch (e) {
      emit(state.copyWith(status: ExpensesStatus.failure, error: e.toString()));
    }
  }

  Future<void> edit({
    required String id,
    required String name,
    required double value,
    required DateTime date,
  }) async {
    try {
      final data = {'name': name, 'value': value, 'date': _fmt(date)};
      final updated = await _repo.updateExpense(id: id, data: data);
      emit(state.copyWith(
        expenses: state.expenses.map((e) => e.id == id ? updated : e).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(status: ExpensesStatus.failure, error: e.toString()));
    }
  }

  Future<void> remove(String id) async {
    try {
      await _repo.deleteExpense(id: id);
      emit(state.copyWith(
        expenses: state.expenses.where((e) => e.id != id).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(status: ExpensesStatus.failure, error: e.toString()));
    }
  }

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
