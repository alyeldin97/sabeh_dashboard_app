import 'package:supabase_flutter/supabase_flutter.dart';
import '../loyalty_data_source.dart';
import '../../model/loyalty_rule_model.dart';
import '../../model/loyalty_transaction_model.dart';
import '../../model/loyalty_goal_model.dart';
import '../../model/spend_goal_model.dart';
import '../../../../../core/utils/app_logger.dart';

class SupabaseLoyaltyDataSource implements LoyaltyDataSource {
  final SupabaseClient _client;
  static const _tag = 'LoyaltyDataSource';

  SupabaseLoyaltyDataSource(this._client);

  // ── Rules ──────────────────────────────────────────────────────────────────

  @override
  Future<List<LoyaltyRuleModel>> getRules() async {
    AppLogger.net(_tag, 'getRules');
    final rows = await _client
        .from('loyalty_rules')
        .select()
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) => LoyaltyRuleModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> createRule(LoyaltyRuleModel rule) async {
    AppLogger.net(_tag, 'createRule', rule.name);
    await _client.from('loyalty_rules').insert(rule.toJson());
  }

  @override
  Future<void> updateRule(LoyaltyRuleModel rule) async {
    AppLogger.net(_tag, 'updateRule', rule.id);
    await _client
        .from('loyalty_rules')
        .update(rule.toJson())
        .eq('id', rule.id);
  }

  @override
  Future<void> deleteRule(String id) async {
    AppLogger.net(_tag, 'deleteRule', id);
    await _client.from('loyalty_rules').delete().eq('id', id);
  }

  @override
  Future<void> toggleRule(String id, bool isActive) async {
    AppLogger.net(_tag, 'toggleRule', '$id -> $isActive');
    await _client
        .from('loyalty_rules')
        .update({'is_active': isActive})
        .eq('id', id);
  }

  // ── Transactions ───────────────────────────────────────────────────────────

  @override
  Future<List<LoyaltyTransactionModel>> getTransactions({
    String? customerId,
    int limit = 50,
  }) async {
    AppLogger.net(_tag, 'getTransactions', customerId);
    try {
      var query = _client
          .from('loyalty_transactions')
          .select('*, customer_profiles(name)');
      if (customerId != null) {
        query = query.eq('customer_id', customerId) as dynamic;
      }
      final rows = await (query as dynamic)
          .order('created_at', ascending: false)
          .limit(limit);
      return (rows as List)
          .map((r) => LoyaltyTransactionModel.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.w(_tag, 'getTransactions with join failed, retrying without join', e);
      var fallback = _client
          .from('loyalty_transactions')
          .select();
      if (customerId != null) {
        fallback = fallback.eq('customer_id', customerId) as dynamic;
      }
      final rows = await (fallback as dynamic)
          .order('created_at', ascending: false)
          .limit(limit);
      return (rows as List)
          .map((r) => LoyaltyTransactionModel.fromJson(r as Map<String, dynamic>))
          .toList();
    }
  }

  @override
  Future<void> manualAdjustPoints({
    required String customerId,
    required int points,
    required String description,
    bool isPermanent = false,
  }) async {
    AppLogger.net(_tag, 'manualAdjustPoints', '$customerId pts=$points');
    await _client.from('loyalty_transactions').insert({
      'customer_id': customerId,
      'points':      points,
      'type':        'manual',
      'description': description,
      'is_permanent': isPermanent,
    });
    await _client.rpc('increment_loyalty_points', params: {
      'customer_id_param': customerId,
      'points_delta':      points,
    }).catchError((_) async {
      final profile = await _client
          .from('customer_profiles')
          .select('loyalty_points')
          .eq('id', customerId)
          .single();
      final current = (profile['loyalty_points'] as num?)?.toInt() ?? 0;
      await _client
          .from('customer_profiles')
          .update({'loyalty_points': current + points})
          .eq('id', customerId);
    });
  }

  // ── Points Catalog Rewards (loyalty_goals) ─────────────────────────────────

  @override
  Future<List<LoyaltyGoalModel>> getGoals() async {
    AppLogger.net(_tag, 'getGoals');
    final rows = await _client
        .from('loyalty_goals')
        .select()
        .order('sort_order');
    return (rows as List)
        .map((r) => LoyaltyGoalModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> createGoal(LoyaltyGoalModel goal) async {
    AppLogger.net(_tag, 'createGoal', goal.title);
    await _client.from('loyalty_goals').insert(goal.toJson());
  }

  @override
  Future<void> updateGoal(LoyaltyGoalModel goal) async {
    AppLogger.net(_tag, 'updateGoal', goal.id);
    await _client
        .from('loyalty_goals')
        .update(goal.toJson())
        .eq('id', goal.id);
  }

  @override
  Future<void> deleteGoal(String id) async {
    AppLogger.net(_tag, 'deleteGoal', id);
    await _client.from('loyalty_goals').delete().eq('id', id);
  }

  @override
  Future<void> toggleGoal(String id, bool isActive) async {
    AppLogger.net(_tag, 'toggleGoal', '$id -> $isActive');
    await _client
        .from('loyalty_goals')
        .update({'is_active': isActive})
        .eq('id', id);
  }

  // ── Spend Milestone Rewards (spend_goals) ──────────────────────────────────

  @override
  Future<List<SpendGoalModel>> getSpendGoals() async {
    AppLogger.net(_tag, 'getSpendGoals');
    final rows = await _client
        .from('spend_goals')
        .select()
        .order('spend_required');
    return (rows as List)
        .map((r) => SpendGoalModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> createSpendGoal(SpendGoalModel goal) async {
    AppLogger.net(_tag, 'createSpendGoal', goal.title);
    await _client.from('spend_goals').insert(goal.toJson());
  }

  @override
  Future<void> updateSpendGoal(SpendGoalModel goal) async {
    AppLogger.net(_tag, 'updateSpendGoal', goal.id);
    await _client
        .from('spend_goals')
        .update(goal.toJson())
        .eq('id', goal.id);
  }

  @override
  Future<void> deleteSpendGoal(String id) async {
    AppLogger.net(_tag, 'deleteSpendGoal', id);
    await _client.from('spend_goals').delete().eq('id', id);
  }

  @override
  Future<void> toggleSpendGoal(String id, bool isActive) async {
    AppLogger.net(_tag, 'toggleSpendGoal', '$id -> $isActive');
    await _client
        .from('spend_goals')
        .update({'is_active': isActive})
        .eq('id', id);
  }
}
