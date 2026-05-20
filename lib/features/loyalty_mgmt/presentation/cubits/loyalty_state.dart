part of 'loyalty_cubit.dart';

enum LoyaltyMgmtStatus { initial, loading, success, failure }

class LoyaltyState extends Equatable {
  final List<LoyaltyRuleModel> rules;
  final List<LoyaltyTransactionModel> transactions;
  final List<LoyaltyGoalModel> goals;
  final List<SpendGoalModel> spendGoals;
  final LoyaltyMgmtStatus status;
  final LoyaltyMgmtStatus actionStatus;
  final String? errorMessage;

  const LoyaltyState({
    this.rules       = const [],
    this.transactions = const [],
    this.goals       = const [],
    this.spendGoals  = const [],
    this.status      = LoyaltyMgmtStatus.initial,
    this.actionStatus = LoyaltyMgmtStatus.initial,
    this.errorMessage,
  });

  LoyaltyState copyWith({
    List<LoyaltyRuleModel>?       rules,
    List<LoyaltyTransactionModel>? transactions,
    List<LoyaltyGoalModel>?       goals,
    List<SpendGoalModel>?         spendGoals,
    LoyaltyMgmtStatus?            status,
    LoyaltyMgmtStatus?            actionStatus,
    String?                       errorMessage,
  }) =>
      LoyaltyState(
        rules:        rules        ?? this.rules,
        transactions: transactions ?? this.transactions,
        goals:        goals        ?? this.goals,
        spendGoals:   spendGoals   ?? this.spendGoals,
        status:       status       ?? this.status,
        actionStatus: actionStatus ?? this.actionStatus,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props =>
      [rules, transactions, goals, spendGoals, status, actionStatus, errorMessage];
}
