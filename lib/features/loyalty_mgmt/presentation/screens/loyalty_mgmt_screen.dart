import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import '../../data/model/loyalty_rule_model.dart';
import '../../data/model/loyalty_transaction_model.dart';
import '../../data/model/loyalty_goal_model.dart';
import '../../data/model/spend_goal_model.dart';
import '../cubits/loyalty_cubit.dart';
import 'loyalty_rule_form_screen.dart';
import 'loyalty_goal_form_screen.dart';
import 'spend_goal_form_screen.dart';

class LoyaltyMgmtScreen extends StatefulWidget {
  const LoyaltyMgmtScreen({super.key});

  @override
  State<LoyaltyMgmtScreen> createState() => _LoyaltyMgmtScreenState();
}

class _LoyaltyMgmtScreenState extends State<LoyaltyMgmtScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _txSearchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _txSearchCtrl.dispose();
    super.dispose();
  }

  void _openRuleForm(BuildContext context, [LoyaltyRuleModel? rule]) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<LoyaltyCubit>(),
        child: LoyaltyRuleFormScreen(rule: rule),
      ),
    ));
  }

  void _openGoalForm(BuildContext context, [LoyaltyGoalModel? goal]) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<LoyaltyCubit>(),
        child: LoyaltyGoalFormScreen(goal: goal),
      ),
    ));
  }

  void _openSpendGoalForm(BuildContext context, [SpendGoalModel? goal]) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<LoyaltyCubit>(),
        child: SpendGoalFormScreen(goal: goal),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoyaltyCubit, LoyaltyState>(
      listener: (context, state) {
        if (state.actionStatus == LoyaltyMgmtStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage!,
                style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 14))),
            backgroundColor: AppColors.error,
          ));
        }
      },
      builder: (context, state) {
        final isLoading = state.status == LoyaltyMgmtStatus.loading;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDeep,
            foregroundColor: AppColors.white,
            title: Text(
              'Loyalty Management',
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 18),
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.accentGold,
              indicatorWeight: 3,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelStyle: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w500,
              ),
              labelColor: AppColors.white,
              unselectedLabelColor: Colors.white60,
              onTap: (_) => setState(() {}),
              tabs: const [
                Tab(text: 'Rules'),
                Tab(text: 'Spend Milestones'),
                Tab(text: 'Points Rewards'),
                Tab(text: 'Transactions'),
              ],
            ),
            actions: [
              if (!isLoading)
                IconButton(
                  icon: Icon(Icons.refresh_rounded, size: 22.r),
                  onPressed: () => context.read<LoyaltyCubit>().loadAll(),
                  tooltip: 'Refresh',
                ),
            ],
          ),
          floatingActionButton: AnimatedBuilder(
            animation: _tabController,
            builder: (_, __) {
              final idx = _tabController.index;
              if (idx == 3) return const SizedBox.shrink();
              return FloatingActionButton(
                heroTag: 'loyalty_fab',
                backgroundColor: AppColors.primaryDeep,
                foregroundColor: AppColors.white,
                onPressed: () {
                  if (idx == 0) {
                    _openRuleForm(context);
                  } else if (idx == 1) {
                    _openSpendGoalForm(context);
                  } else {
                    _openGoalForm(context);
                  }
                },
                child: const Icon(Icons.add_rounded),
              );
            },
          ),
          body: isLoading &&
                  state.rules.isEmpty &&
                  state.goals.isEmpty &&
                  state.spendGoals.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryDeep))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _RulesTab(
                      rules: state.rules,
                      onEdit: (r) => _openRuleForm(context, r),
                      onToggle: (id, v) =>
                          context.read<LoyaltyCubit>().toggleRule(id, v),
                    ),
                    _SpendGoalsTab(
                      goals: state.spendGoals,
                      onEdit: (g) => _openSpendGoalForm(context, g),
                      onToggle: (id, v) =>
                          context.read<LoyaltyCubit>().toggleSpendGoal(id, v),
                    ),
                    _PointsRewardsTab(
                      goals: state.goals,
                      onEdit: (g) => _openGoalForm(context, g),
                      onToggle: (id, v) =>
                          context.read<LoyaltyCubit>().toggleGoal(id, v),
                    ),
                    _TransactionsTab(
                      transactions: state.transactions,
                      searchCtrl: _txSearchCtrl,
                      onSearch: (q) {
                        context.read<LoyaltyCubit>().loadTransactions(
                            customerId: q.trim().isEmpty ? null : q.trim());
                      },
                    ),
                  ],
                ),
        );
      },
    );
  }
}

// ── Rules Tab ─────────────────────────────────────────────────────────────────

class _RulesTab extends StatelessWidget {
  const _RulesTab({required this.rules, required this.onEdit, required this.onToggle});
  final List<LoyaltyRuleModel> rules;
  final void Function(LoyaltyRuleModel) onEdit;
  final void Function(String, bool) onToggle;

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty) {
      return _EmptyState(
        icon: Icons.workspace_premium_outlined,
        title: 'No loyalty rules',
        subtitle: 'Tap + to create your first earning rule',
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(16.r),
      itemCount: rules.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, i) => _RuleCard(
        rule: rules[i],
        onEdit: () => onEdit(rules[i]),
        onToggle: (v) => onToggle(rules[i].id, v),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({required this.rule, required this.onEdit, required this.onToggle});
  final LoyaltyRuleModel rule;
  final VoidCallback onEdit;
  final void Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r16,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 44.r, height: 44.r,
              decoration: BoxDecoration(
                color: rule.isActive ? AppColors.primaryMist : AppColors.border,
                borderRadius: AppBorderRadius.r12,
              ),
              child: Icon(Icons.workspace_premium_outlined,
                  color: rule.isActive ? AppColors.primaryDeep : AppColors.textLight, size: 22.r),
            ),
            SizedBox(width: 12.w),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rule.name,
                    style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w700, color: AppColors.textDark)),
                Text(rule.ruleType == 'cashback_event' ? 'Cashback Event' : 'Base Earn',
                    style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 12), color: AppColors.textLight)),
              ],
            )),
            Switch(value: rule.isActive, onChanged: onToggle, activeThumbColor: AppColors.primaryDeep),
            GestureDetector(
              onTap: onEdit,
              child: Padding(padding: const EdgeInsets.all(4),
                  child: Icon(Icons.edit_outlined, size: 20.r, color: AppColors.textLight)),
            ),
          ]),
          SizedBox(height: 10.h),
          Wrap(spacing: 8, runSpacing: 4, children: [
            _Chip(icon: Icons.stars_rounded,
                label: '${rule.pointsPerEgp.toStringAsFixed(rule.pointsPerEgp == rule.pointsPerEgp.roundToDouble() ? 0 : 2)} pts/EGP',
                color: AppColors.primaryDeep),
            if (rule.minOrderValue > 0)
              _Chip(icon: Icons.shopping_bag_outlined,
                  label: 'Min EGP ${rule.minOrderValue.toStringAsFixed(0)}',
                  color: const Color(0xFF6A1B9A)),
          ]),
        ],
      ),
    );
  }
}

// ── Spend Milestones Tab ──────────────────────────────────────────────────────

class _SpendGoalsTab extends StatelessWidget {
  const _SpendGoalsTab({required this.goals, required this.onEdit, required this.onToggle});
  final List<SpendGoalModel> goals;
  final void Function(SpendGoalModel) onEdit;
  final void Function(String, bool) onToggle;

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return _EmptyState(
        icon: Icons.trending_up_rounded,
        title: 'No spend milestones',
        subtitle: 'Tap + to create your first spend milestone',
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(16.r),
      itemCount: goals.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, i) => _SpendGoalCard(
        goal: goals[i],
        onEdit: () => onEdit(goals[i]),
        onToggle: (v) => onToggle(goals[i].id, v),
      ),
    );
  }
}

class _SpendGoalCard extends StatelessWidget {
  const _SpendGoalCard({required this.goal, required this.onEdit, required this.onToggle});
  final SpendGoalModel goal;
  final VoidCallback onEdit;
  final void Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    Color rewardColor;
    IconData rewardIcon;
    String rewardLabel;
    switch (goal.rewardType) {
      case 'free_product':
        rewardColor = AppColors.accentGold;
        rewardIcon  = Icons.redeem_outlined;
        rewardLabel = 'Free Product';
        break;
      case 'discount':
        rewardColor = const Color(0xFF6A1B9A);
        rewardIcon  = Icons.discount_outlined;
        rewardLabel = '${goal.rewardDiscountAmount.toStringAsFixed(0)}% Discount';
        break;
      default:
        rewardColor = const Color(0xFF1565C0);
        rewardIcon  = Icons.delivery_dining_outlined;
        rewardLabel = 'Free Delivery';
    }

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r16,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 44.r, height: 44.r,
              decoration: BoxDecoration(
                color: goal.isActive ? AppColors.primaryMist : AppColors.border,
                borderRadius: AppBorderRadius.r12,
              ),
              child: Center(child: Text(goal.icon, style: TextStyle(fontSize: 22.r))),
            ),
            SizedBox(width: 12.w),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.title,
                    style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w700, color: AppColors.textDark)),
                if (goal.description != null && goal.description!.isNotEmpty)
                  Text(goal.description!,
                      style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 12), color: AppColors.textLight),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            )),
            Switch(value: goal.isActive, onChanged: onToggle, activeThumbColor: AppColors.primaryDeep),
            GestureDetector(
              onTap: onEdit,
              child: Padding(padding: const EdgeInsets.all(4),
                  child: Icon(Icons.edit_outlined, size: 20.r, color: AppColors.textLight)),
            ),
          ]),
          SizedBox(height: 10.h),
          Wrap(spacing: 8, runSpacing: 4, children: [
            _Chip(icon: Icons.payments_outlined,
                label: 'Spend EGP ${goal.spendRequired.toStringAsFixed(0)}',
                color: AppColors.primaryDeep),
            _Chip(icon: rewardIcon, label: rewardLabel, color: rewardColor),
          ]),
        ],
      ),
    );
  }
}

// ── Points Rewards Tab ────────────────────────────────────────────────────────

class _PointsRewardsTab extends StatelessWidget {
  const _PointsRewardsTab({required this.goals, required this.onEdit, required this.onToggle});
  final List<LoyaltyGoalModel> goals;
  final void Function(LoyaltyGoalModel) onEdit;
  final void Function(String, bool) onToggle;

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return _EmptyState(
        icon: Icons.card_giftcard_outlined,
        title: 'No points rewards',
        subtitle: 'Tap + to create your first points reward',
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(16.r),
      itemCount: goals.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, i) => _PointsRewardCard(
        goal: goals[i],
        onEdit: () => onEdit(goals[i]),
        onToggle: (v) => onToggle(goals[i].id, v),
      ),
    );
  }
}

class _PointsRewardCard extends StatelessWidget {
  const _PointsRewardCard({required this.goal, required this.onEdit, required this.onToggle});
  final LoyaltyGoalModel goal;
  final VoidCallback onEdit;
  final void Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    final isFreeDelivery = goal.rewardType == 'free_delivery';
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r16,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 44.r, height: 44.r,
              decoration: BoxDecoration(
                color: goal.isActive ? AppColors.primaryMist : AppColors.border,
                borderRadius: AppBorderRadius.r12,
              ),
              child: Center(child: Text(goal.icon, style: TextStyle(fontSize: 22.r))),
            ),
            SizedBox(width: 12.w),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.title,
                    style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w700, color: AppColors.textDark)),
                if (goal.description != null && goal.description!.isNotEmpty)
                  Text(goal.description!,
                      style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 12), color: AppColors.textLight),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            )),
            Switch(value: goal.isActive, onChanged: onToggle, activeThumbColor: AppColors.primaryDeep),
            GestureDetector(
              onTap: onEdit,
              child: Padding(padding: const EdgeInsets.all(4),
                  child: Icon(Icons.edit_outlined, size: 20.r, color: AppColors.textLight)),
            ),
          ]),
          SizedBox(height: 10.h),
          Wrap(spacing: 8, runSpacing: 4, children: [
            _Chip(icon: Icons.stars_rounded,
                label: '${goal.pointsRequired} pts',
                color: AppColors.primaryDeep),
            _Chip(
              icon: isFreeDelivery ? Icons.delivery_dining_outlined : Icons.redeem_outlined,
              label: isFreeDelivery ? 'Free Delivery' : 'Free Product',
              color: isFreeDelivery ? const Color(0xFF1565C0) : AppColors.accentGold,
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Transactions Tab ──────────────────────────────────────────────────────────

class _TransactionsTab extends StatelessWidget {
  const _TransactionsTab({
    required this.transactions,
    required this.searchCtrl,
    required this.onSearch,
  });
  final List<LoyaltyTransactionModel> transactions;
  final TextEditingController searchCtrl;
  final void Function(String) onSearch;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: AppColors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: TextField(
          controller: searchCtrl,
          onChanged: onSearch,
          style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 14), color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: 'Filter by customer ID…',
            hintStyle: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13), color: AppColors.textLight),
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.textLight, size: 20.r),
            suffixIcon: searchCtrl.text.isNotEmpty
                ? GestureDetector(
                    onTap: () { searchCtrl.clear(); onSearch(''); },
                    child: Icon(Icons.close_rounded, color: AppColors.textLight, size: 18.r))
                : null,
            filled: true,
            fillColor: AppColors.scaffoldBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: AppColors.primaryMid, width: 2)),
          ),
        ),
      ),
      Expanded(
        child: transactions.isEmpty
            ? _EmptyState(icon: Icons.receipt_long_outlined, title: 'No transactions', subtitle: 'Loyalty transactions will appear here')
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: transactions.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (_, i) => _TransactionItem(tx: transactions[i]),
              ),
      ),
    ]);
  }
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({required this.tx});
  final LoyaltyTransactionModel tx;

  @override
  Widget build(BuildContext context) {
    final isPositive  = tx.points >= 0;
    final pointsColor = isPositive ? AppColors.primaryDeep : AppColors.error;
    final pointsLabel = isPositive ? '+${tx.points}' : '${tx.points}';

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r12,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 1))],
      ),
      child: Row(children: [
        Container(
          width: 40.r, height: 40.r,
          decoration: BoxDecoration(
            color: isPositive ? AppColors.primaryMist : AppColors.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(_typeIcon(tx.type), size: 20.r, color: pointsColor),
        ),
        SizedBox(width: 12.w),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tx.customerName ?? tx.customerId,
                style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w700, color: AppColors.textDark),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            if (tx.description != null && tx.description!.isNotEmpty)
              Text(tx.description!,
                  style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 12), color: AppColors.textLight),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            Row(children: [
              _TypeBadge(type: tx.type),
              const SizedBox(width: 6),
              Text('${tx.createdAt.day}/${tx.createdAt.month}/${tx.createdAt.year}',
                  style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 11), color: AppColors.textLight)),
            ]),
          ],
        )),
        SizedBox(width: 8.w),
        Text(pointsLabel,
            style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w800, color: pointsColor)),
        Text(' pts', style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 11), color: AppColors.textLight)),
      ]),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'earn':    return Icons.add_circle_outline_rounded;
      case 'redeem':  return Icons.remove_circle_outline_rounded;
      case 'expire':  return Icons.timer_off_outlined;
      case 'referral': return Icons.people_outline_rounded;
      default:        return Icons.edit_outlined;
    }
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (type) {
      case 'earn':     color = AppColors.primaryDeep; break;
      case 'redeem':   color = AppColors.accentGold; break;
      case 'expire':   color = AppColors.error; break;
      case 'referral': color = const Color(0xFF6A1B9A); break;
      default:         color = const Color(0xFF1565C0);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(type.toUpperCase(),
          style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 10), fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 11), fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 64.r, color: AppColors.primaryLight),
        SizedBox(height: 16.h),
        Text(title, style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 18), fontWeight: FontWeight.w700, color: AppColors.textCharcoal)),
        SizedBox(height: 8.h),
        Text(subtitle, style: GoogleFonts.nunito(color: AppColors.textLight)),
      ]),
    );
  }
}
