import '../model/expense_model.dart';

abstract class ExpensesRepository {
  Future<List<ExpenseModel>> getExpensesByDate({
    required DateTime date,
    String? branchId,
  });
  Future<List<ExpenseModel>> getExpensesByDateRange({
    required DateTime from,
    required DateTime to,
    String? branchId,
  });
  Future<ExpenseModel> createExpense({required Map<String, dynamic> data});
  Future<ExpenseModel> updateExpense({
    required String id,
    required Map<String, dynamic> data,
  });
  Future<void> deleteExpense({required String id});
}
