import '../model/expense_model.dart';
import '../remote/expenses_data_source.dart';
import 'expenses_repository.dart';

class ExpensesRepositoryImpl implements ExpensesRepository {
  final ExpensesDataSource _ds;
  ExpensesRepositoryImpl(this._ds);

  @override
  Future<List<ExpenseModel>> getExpensesByDate({
    required DateTime date,
    String? branchId,
  }) => _ds.getExpensesByDate(date: date, branchId: branchId);

  @override
  Future<List<ExpenseModel>> getExpensesByDateRange({
    required DateTime from,
    required DateTime to,
    String? branchId,
  }) => _ds.getExpensesByDateRange(from: from, to: to, branchId: branchId);

  @override
  Future<ExpenseModel> createExpense({required Map<String, dynamic> data}) =>
      _ds.createExpense(data: data);

  @override
  Future<ExpenseModel> updateExpense({
    required String id,
    required Map<String, dynamic> data,
  }) => _ds.updateExpense(id: id, data: data);

  @override
  Future<void> deleteExpense({required String id}) => _ds.deleteExpense(id: id);
}
