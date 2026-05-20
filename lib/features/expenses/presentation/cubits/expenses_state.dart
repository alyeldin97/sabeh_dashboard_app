import 'package:equatable/equatable.dart';
import '../../data/model/expense_model.dart';

enum ExpensesStatus { initial, loading, success, failure }

class ExpensesState extends Equatable {
  final ExpensesStatus status;
  final List<ExpenseModel> expenses;
  final String? error;

  const ExpensesState({
    this.status = ExpensesStatus.initial,
    this.expenses = const [],
    this.error,
  });

  ExpensesState copyWith({
    ExpensesStatus? status,
    List<ExpenseModel>? expenses,
    String? error,
  }) => ExpensesState(
        status:   status   ?? this.status,
        expenses: expenses ?? this.expenses,
        error:    error,
      );

  double get total => expenses.fold(0.0, (sum, e) => sum + e.value);

  @override
  List<Object?> get props => [status, expenses, error];
}
