import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../model/expense_model.dart';
import '../expenses_data_source.dart';

class SupabaseExpensesDataSource implements ExpensesDataSource {
  static const _tag = 'ExpensesDataSource';
  final SupabaseClient _client;

  SupabaseExpensesDataSource(this._client);

  static String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Future<List<ExpenseModel>> getExpensesByDate({
    required DateTime date,
    String? branchId,
  }) async {
    AppLogger.net(_tag, 'getExpensesByDate', 'date=${_fmtDate(date)}');
    try {
      var q = _client.from('expenses').select().eq('date', _fmtDate(date));
      if (branchId != null) q = q.eq('branch_id', branchId) as dynamic;
      final rows = await (q as dynamic).order('created_at', ascending: true);
      final result = (rows as List)
          .map((r) => ExpenseModel.fromJson(r as Map<String, dynamic>))
          .toList();
      AppLogger.i(_tag, 'getExpensesByDate → ${result.length}');
      return result;
    } catch (e, st) {
      AppLogger.e(_tag, 'getExpensesByDate failed', e, st);
      rethrow;
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByDateRange({
    required DateTime from,
    required DateTime to,
    String? branchId,
  }) async {
    AppLogger.net(_tag, 'getExpensesByDateRange', 'from=${_fmtDate(from)} to=${_fmtDate(to)}');
    try {
      var q = _client
          .from('expenses')
          .select()
          .gte('date', _fmtDate(from))
          .lte('date', _fmtDate(to));
      if (branchId != null) q = q.eq('branch_id', branchId) as dynamic;
      final rows = await (q as dynamic).order('date', ascending: true);
      final result = (rows as List)
          .map((r) => ExpenseModel.fromJson(r as Map<String, dynamic>))
          .toList();
      AppLogger.i(_tag, 'getExpensesByDateRange → ${result.length}');
      return result;
    } catch (e, st) {
      AppLogger.e(_tag, 'getExpensesByDateRange failed', e, st);
      rethrow;
    }
  }

  @override
  Future<ExpenseModel> createExpense({required Map<String, dynamic> data}) async {
    AppLogger.net(_tag, 'createExpense', data.toString());
    try {
      final row = await _client.from('expenses').insert(data).select().single();
      return ExpenseModel.fromJson(row);
    } catch (e, st) {
      AppLogger.e(_tag, 'createExpense failed', e, st);
      rethrow;
    }
  }

  @override
  Future<ExpenseModel> updateExpense({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    AppLogger.net(_tag, 'updateExpense', 'id=$id');
    try {
      final row =
          await _client.from('expenses').update(data).eq('id', id).select().single();
      return ExpenseModel.fromJson(row);
    } catch (e, st) {
      AppLogger.e(_tag, 'updateExpense failed', e, st);
      rethrow;
    }
  }

  @override
  Future<void> deleteExpense({required String id}) async {
    AppLogger.net(_tag, 'deleteExpense', 'id=$id');
    try {
      await _client.from('expenses').delete().eq('id', id);
    } catch (e, st) {
      AppLogger.e(_tag, 'deleteExpense failed', e, st);
      rethrow;
    }
  }
}
