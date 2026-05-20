import '../model/loyalty_rule_model.dart';
import '../model/loyalty_transaction_model.dart';
import '../model/loyalty_goal_model.dart';
import '../model/spend_goal_model.dart';
import '../remote/loyalty_data_source.dart';
import 'loyalty_repository.dart';

class LoyaltyRepositoryImpl implements LoyaltyRepository {
  final LoyaltyDataSource _dataSource;

  LoyaltyRepositoryImpl(this._dataSource);

  @override
  Future<List<LoyaltyRuleModel>> getRules() => _dataSource.getRules();

  @override
  Future<void> createRule(LoyaltyRuleModel rule) => _dataSource.createRule(rule);

  @override
  Future<void> updateRule(LoyaltyRuleModel rule) => _dataSource.updateRule(rule);

  @override
  Future<void> deleteRule(String id) => _dataSource.deleteRule(id);

  @override
  Future<void> toggleRule(String id, bool isActive) =>
      _dataSource.toggleRule(id, isActive);

  @override
  Future<List<LoyaltyTransactionModel>> getTransactions({
    String? customerId,
    int limit = 50,
  }) =>
      _dataSource.getTransactions(customerId: customerId, limit: limit);

  @override
  Future<void> manualAdjustPoints({
    required String customerId,
    required int points,
    required String description,
    bool isPermanent = false,
  }) =>
      _dataSource.manualAdjustPoints(
        customerId:  customerId,
        points:      points,
        description: description,
        isPermanent: isPermanent,
      );

  @override
  Future<List<LoyaltyGoalModel>> getGoals() => _dataSource.getGoals();

  @override
  Future<void> createGoal(LoyaltyGoalModel goal) => _dataSource.createGoal(goal);

  @override
  Future<void> updateGoal(LoyaltyGoalModel goal) => _dataSource.updateGoal(goal);

  @override
  Future<void> deleteGoal(String id) => _dataSource.deleteGoal(id);

  @override
  Future<void> toggleGoal(String id, bool isActive) =>
      _dataSource.toggleGoal(id, isActive);

  @override
  Future<List<SpendGoalModel>> getSpendGoals() => _dataSource.getSpendGoals();

  @override
  Future<void> createSpendGoal(SpendGoalModel goal) =>
      _dataSource.createSpendGoal(goal);

  @override
  Future<void> updateSpendGoal(SpendGoalModel goal) =>
      _dataSource.updateSpendGoal(goal);

  @override
  Future<void> deleteSpendGoal(String id) => _dataSource.deleteSpendGoal(id);

  @override
  Future<void> toggleSpendGoal(String id, bool isActive) =>
      _dataSource.toggleSpendGoal(id, isActive);
}
