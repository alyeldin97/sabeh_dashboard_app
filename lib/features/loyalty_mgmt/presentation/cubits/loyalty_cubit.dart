import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/loyalty_rule_model.dart';
import '../../data/model/loyalty_transaction_model.dart';
import '../../data/model/loyalty_goal_model.dart';
import '../../data/model/spend_goal_model.dart';
import '../../data/repo/loyalty_repository.dart';

part 'loyalty_state.dart';

class LoyaltyCubit extends Cubit<LoyaltyState> {
  final LoyaltyRepository _repo;

  LoyaltyCubit(this._repo) : super(const LoyaltyState());

  Future<void> loadAll() async {
    emit(state.copyWith(status: LoyaltyMgmtStatus.loading));
    try {
      final results = await Future.wait([
        _repo.getRules(),
        _repo.getTransactions(),
        _repo.getGoals(),
        _repo.getSpendGoals(),
      ]);
      emit(state.copyWith(
        rules:        results[0] as List<LoyaltyRuleModel>,
        transactions: results[1] as List<LoyaltyTransactionModel>,
        goals:        results[2] as List<LoyaltyGoalModel>,
        spendGoals:   results[3] as List<SpendGoalModel>,
        status:       LoyaltyMgmtStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status:       LoyaltyMgmtStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadTransactions({String? customerId}) async {
    try {
      final transactions = await _repo.getTransactions(customerId: customerId);
      emit(state.copyWith(transactions: transactions));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // ── Rules ──────────────────────────────────────────────────────────────────

  Future<bool> createRule(LoyaltyRuleModel rule) async {
    emit(state.copyWith(actionStatus: LoyaltyMgmtStatus.loading));
    try {
      await _repo.createRule(rule);
      final rules = await _repo.getRules();
      emit(state.copyWith(rules: rules, actionStatus: LoyaltyMgmtStatus.success));
      return true;
    } catch (e) {
      emit(state.copyWith(actionStatus: LoyaltyMgmtStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> updateRule(LoyaltyRuleModel rule) async {
    emit(state.copyWith(actionStatus: LoyaltyMgmtStatus.loading));
    try {
      await _repo.updateRule(rule);
      final rules = await _repo.getRules();
      emit(state.copyWith(rules: rules, actionStatus: LoyaltyMgmtStatus.success));
      return true;
    } catch (e) {
      emit(state.copyWith(actionStatus: LoyaltyMgmtStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  Future<void> deleteRule(String id) async {
    emit(state.copyWith(actionStatus: LoyaltyMgmtStatus.loading));
    try {
      await _repo.deleteRule(id);
      final rules = state.rules.where((r) => r.id != id).toList();
      emit(state.copyWith(rules: rules, actionStatus: LoyaltyMgmtStatus.success));
    } catch (e) {
      emit(state.copyWith(actionStatus: LoyaltyMgmtStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> toggleRule(String id, bool isActive) async {
    try {
      await _repo.toggleRule(id, isActive);
      final rules = state.rules
          .map((r) => r.id == id ? r.copyWith(isActive: isActive) : r)
          .toList();
      emit(state.copyWith(rules: rules));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // ── Points Catalog Rewards ─────────────────────────────────────────────────

  Future<bool> createGoal(LoyaltyGoalModel goal) async {
    emit(state.copyWith(actionStatus: LoyaltyMgmtStatus.loading));
    try {
      await _repo.createGoal(goal);
      final goals = await _repo.getGoals();
      emit(state.copyWith(goals: goals, actionStatus: LoyaltyMgmtStatus.success));
      return true;
    } catch (e) {
      emit(state.copyWith(actionStatus: LoyaltyMgmtStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> updateGoal(LoyaltyGoalModel goal) async {
    emit(state.copyWith(actionStatus: LoyaltyMgmtStatus.loading));
    try {
      await _repo.updateGoal(goal);
      final goals = await _repo.getGoals();
      emit(state.copyWith(goals: goals, actionStatus: LoyaltyMgmtStatus.success));
      return true;
    } catch (e) {
      emit(state.copyWith(actionStatus: LoyaltyMgmtStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  Future<void> deleteGoal(String id) async {
    emit(state.copyWith(actionStatus: LoyaltyMgmtStatus.loading));
    try {
      await _repo.deleteGoal(id);
      final goals = state.goals.where((g) => g.id != id).toList();
      emit(state.copyWith(goals: goals, actionStatus: LoyaltyMgmtStatus.success));
    } catch (e) {
      emit(state.copyWith(actionStatus: LoyaltyMgmtStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> toggleGoal(String id, bool isActive) async {
    try {
      await _repo.toggleGoal(id, isActive);
      final goals = state.goals
          .map((g) => g.id == id ? g.copyWith(isActive: isActive) : g)
          .toList();
      emit(state.copyWith(goals: goals));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // ── Spend Milestone Rewards ────────────────────────────────────────────────

  Future<bool> createSpendGoal(SpendGoalModel goal) async {
    emit(state.copyWith(actionStatus: LoyaltyMgmtStatus.loading));
    try {
      await _repo.createSpendGoal(goal);
      final spendGoals = await _repo.getSpendGoals();
      emit(state.copyWith(spendGoals: spendGoals, actionStatus: LoyaltyMgmtStatus.success));
      return true;
    } catch (e) {
      emit(state.copyWith(actionStatus: LoyaltyMgmtStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> updateSpendGoal(SpendGoalModel goal) async {
    emit(state.copyWith(actionStatus: LoyaltyMgmtStatus.loading));
    try {
      await _repo.updateSpendGoal(goal);
      final spendGoals = await _repo.getSpendGoals();
      emit(state.copyWith(spendGoals: spendGoals, actionStatus: LoyaltyMgmtStatus.success));
      return true;
    } catch (e) {
      emit(state.copyWith(actionStatus: LoyaltyMgmtStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  Future<void> deleteSpendGoal(String id) async {
    emit(state.copyWith(actionStatus: LoyaltyMgmtStatus.loading));
    try {
      await _repo.deleteSpendGoal(id);
      final spendGoals = state.spendGoals.where((g) => g.id != id).toList();
      emit(state.copyWith(spendGoals: spendGoals, actionStatus: LoyaltyMgmtStatus.success));
    } catch (e) {
      emit(state.copyWith(actionStatus: LoyaltyMgmtStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> toggleSpendGoal(String id, bool isActive) async {
    try {
      await _repo.toggleSpendGoal(id, isActive);
      final spendGoals = state.spendGoals
          .map((g) => g.id == id ? g.copyWith(isActive: isActive) : g)
          .toList();
      emit(state.copyWith(spendGoals: spendGoals));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // ── Transactions ───────────────────────────────────────────────────────────

  Future<bool> manualAdjustPoints({
    required String customerId,
    required int points,
    required String description,
    bool isPermanent = false,
  }) async {
    emit(state.copyWith(actionStatus: LoyaltyMgmtStatus.loading));
    try {
      await _repo.manualAdjustPoints(
        customerId:  customerId,
        points:      points,
        description: description,
        isPermanent: isPermanent,
      );
      final transactions = await _repo.getTransactions();
      emit(state.copyWith(transactions: transactions, actionStatus: LoyaltyMgmtStatus.success));
      return true;
    } catch (e) {
      emit(state.copyWith(actionStatus: LoyaltyMgmtStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }
}
