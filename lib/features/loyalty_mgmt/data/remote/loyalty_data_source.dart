import '../model/loyalty_rule_model.dart';
import '../model/loyalty_transaction_model.dart';
import '../model/loyalty_goal_model.dart';
import '../model/spend_goal_model.dart';

abstract class LoyaltyDataSource {
  Future<List<LoyaltyRuleModel>> getRules();
  Future<void> createRule(LoyaltyRuleModel rule);
  Future<void> updateRule(LoyaltyRuleModel rule);
  Future<void> deleteRule(String id);
  Future<void> toggleRule(String id, bool isActive);

  Future<List<LoyaltyTransactionModel>> getTransactions({
    String? customerId,
    int limit,
  });
  Future<void> manualAdjustPoints({
    required String customerId,
    required int points,
    required String description,
    bool isPermanent,
  });

  // Points catalog rewards (loyalty_goals table)
  Future<List<LoyaltyGoalModel>> getGoals();
  Future<void> createGoal(LoyaltyGoalModel goal);
  Future<void> updateGoal(LoyaltyGoalModel goal);
  Future<void> deleteGoal(String id);
  Future<void> toggleGoal(String id, bool isActive);

  // Spend milestone rewards (spend_goals table)
  Future<List<SpendGoalModel>> getSpendGoals();
  Future<void> createSpendGoal(SpendGoalModel goal);
  Future<void> updateSpendGoal(SpendGoalModel goal);
  Future<void> deleteSpendGoal(String id);
  Future<void> toggleSpendGoal(String id, bool isActive);
}
