import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import '../../../app_settings/presentation/cubits/app_settings_cubit.dart';
import '../../../branches/data/model/branch_model.dart';
import '../../../branches/presentation/cubits/branches_cubit.dart';
import '../cubits/analytics_cubit.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key, this.branchId});
  final String? branchId;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  static const _presets = ['Today', '7 Days', '30 Days', 'This Month']; // resolved to l10n in build
  int _selectedPreset = 2;

  @override
  void initState() {
    super.initState();
    final cubit    = context.read<AnalyticsCubit>();
    final settings = context.read<AppSettingsCubit>().state.settings;
    if (settings != null) cubit.setOnlineWindow(settings.onlineWindowMinutes);
    if (widget.branchId != null) cubit.setBranch(widget.branchId);
    cubit.load(branchId: widget.branchId);
    context.read<BranchesCubit>().load();
  }

  void _applyPreset(int index) {
    setState(() => _selectedPreset = index);
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final from  = switch (index) {
      0 => today,
      1 => today.subtract(const Duration(days: 6)),
      2 => today.subtract(const Duration(days: 29)),
      3 => DateTime(now.year, now.month, 1),
      _ => today.subtract(const Duration(days: 29)),
    };
    final to = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final cubit = context.read<AnalyticsCubit>();
    cubit.setDateRange(from, to);
    cubit.load();
  }

  Future<void> _pickCustomRange() async {
    final state  = context.read<AnalyticsCubit>().state;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: state.fromDate, end: state.toDate),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryDeep,
            onPrimary: AppColors.white,
            surface: AppColors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _selectedPreset = -1);
      final cubit = context.read<AnalyticsCubit>();
      cubit.setDateRange(picked.start, picked.end);
      cubit.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final presets = [l10n.analyticsToday, l10n.analytics7Days, l10n.analytics30Days, l10n.analyticsThisMonth];
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(l10n),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              Responsive.sidePadding(context),
              12.h,
              Responsive.sidePadding(context),
              32.h,
            ),
            sliver: BlocBuilder<AnalyticsCubit, AnalyticsState>(
              builder: (context, state) => SliverList(
                delegate: SliverChildListDelegate([
                  _FiltersCard(
                    state: state,
                    presets: presets,
                    selectedPreset: _selectedPreset,
                    onPreset: _applyPreset,
                    onCustomRange: _pickCustomRange,
                    onBranchChanged: (id) {
                      context.read<AnalyticsCubit>().setBranch(id);
                      context.read<AnalyticsCubit>().load();
                    },
                    l10n: l10n,
                  ),
                  SizedBox(height: 20.h),
                  if (state.status == AnalyticsStatus.loading)
                    const _LoadingCard()
                  else if (state.status == AnalyticsStatus.failure)
                    _ErrorCard(
                      message: state.errorMessage,
                      onRetry: () => context.read<AnalyticsCubit>().load(),
                    )
                  else ...[
                    _KpiGrid(state: state),
                    SizedBox(height: 16.h),
                    _DiscountBreakdownCard(state: state),
                    SizedBox(height: 16.h),
                    _RatesRow(state: state),
                    SizedBox(height: 16.h),
                    _CustomerMetricsCard(state: state),
                    SizedBox(height: 16.h),
                    if (state.dailySales.isNotEmpty) ...[
                      _DailySalesChart(series: state.dailySales),
                      SizedBox(height: 16.h),
                    ],
                    if (state.salesByZone.isNotEmpty) ...[
                      _SalesByZoneCard(state: state),
                      SizedBox(height: 16.h),
                    ],
                    _StatusBreakdownCard(state: state),
                    SizedBox(height: 16.h),
                    _TopProductsCard(state: state),
                    SizedBox(height: 16.h),
                    if (state.deviceTypeCounts.isNotEmpty) ...[
                      _DeviceTypeCard(counts: state.deviceTypeCounts),
                      SizedBox(height: 16.h),
                    ],
                    if (state.abandonedCarts.isNotEmpty) ...[
                      _AbandonedCartsCard(carts: state.abandonedCarts),
                      SizedBox(height: 16.h),
                    ],
                    _ProductFunnelListCard(state: state),
                    if (state.eventCounts.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      _EventTrackingCard(counts: state.eventCounts),
                    ],
                  ],
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(AppLocalizations l10n) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 80.h,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primaryDeep,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDeep, AppColors.primaryMid],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    l10n.analyticsTitle,
                    style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 22),
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.read<AnalyticsCubit>().load(),
                    icon: Icon(Icons.refresh_rounded, color: AppColors.white, size: 22.r),
                    tooltip: l10n.analyticsRefresh,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Filters Card ─────────────────────────────────────────────────────────────

class _FiltersCard extends StatelessWidget {
  const _FiltersCard({
    required this.state,
    required this.presets,
    required this.selectedPreset,
    required this.onPreset,
    required this.onCustomRange,
    required this.onBranchChanged,
    required this.l10n,
  });

  final AnalyticsState state;
  final List<String> presets;
  final int selectedPreset;
  final ValueChanged<int> onPreset;
  final VoidCallback onCustomRange;
  final ValueChanged<String?> onBranchChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d');
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list_rounded, size: 16.r, color: AppColors.primaryMid),
              SizedBox(width: 6.w),
              Text(
                l10n.analyticsFilters,
                style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 13),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMid,
                ),
              ),
              const Spacer(),
              Text(
                '${fmt.format(state.fromDate)} – ${fmt.format(state.toDate)}',
                style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 12),
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...List.generate(presets.length, (i) => Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: _PresetChip(
                    label: presets[i],
                    selected: selectedPreset == i,
                    onTap: () => onPreset(i),
                  ),
                )),
                _PresetChip(
                  label: l10n.analyticsCustom,
                  selected: selectedPreset == -1,
                  onTap: onCustomRange,
                  icon: Icons.date_range_outlined,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          BlocBuilder<BranchesCubit, BranchesState>(
            builder: (context, bs) {
              if (bs.branches.isEmpty) return const SizedBox.shrink();
              return _BranchDropdown(
                branches: bs.branches,
                selectedId: state.branchId,
                onChanged: onBranchChanged,
                l10n: l10n,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDeep : AppColors.primaryMist,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primaryDeep : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13.r, color: selected ? AppColors.white : AppColors.primaryMid),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 12),
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.white : AppColors.primaryMid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchDropdown extends StatelessWidget {
  const _BranchDropdown({
    required this.branches,
    required this.selectedId,
    required this.onChanged,
    required this.l10n,
  });

  final List<BranchModel> branches;
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: AppBorderRadius.r8,
        color: AppColors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedId,
          isExpanded: true,
          hint: Text(
            l10n.analyticsAllBranches,
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 13),
              color: AppColors.textLight,
            ),
          ),
          style: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 13),
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textLight, size: 18.r),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(l10n.analyticsAllBranches,
                  style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13), color: AppColors.textMid)),
            ),
            ...branches.map(
              (b) => DropdownMenuItem<String?>(
                value: b.id,
                child: Text(b.name),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ── KPI Grid ──────────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.state});
  final AnalyticsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                label: l10n.analyticsTotalSales,
                value: 'EGP ${_fmt(state.totalSales)}',
                icon: Icons.payments_outlined,
                color: AppColors.primaryDeep,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _KpiCard(
                label: l10n.analyticsOrders,
                value: '${state.orderVolume}',
                icon: Icons.receipt_long_outlined,
                color: const Color(0xFF1565C0),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                label: l10n.analyticsTotalCogs,
                value: 'EGP ${_fmt(state.totalCogs)}',
                icon: Icons.inventory_2_outlined,
                color: Colors.deepOrange,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _KpiCard(
                label: l10n.analyticsGrossProfit,
                value: 'EGP ${_fmt((state.totalSales - state.totalDeliveryCharges - state.totalCogs).clamp(0, double.maxFinite))}',
                icon: Icons.account_balance_outlined,
                color: Colors.teal,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _KpiCard(
          label: l10n.analyticsAvgOrderValue,
          value: 'EGP ${_fmt(state.avgOrderValue)}',
          icon: Icons.trending_up_rounded,
          color: AppColors.accentOrange,
          wide: true,
          subtitle: '${state.orderVolume - state.cancelledCount} non-cancelled orders',
        ),
      ],
    );
  }

  String _fmt(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : v.toStringAsFixed(0);
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.wide = false,
    this.subtitle,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool wide;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final iconBox = Container(
      width: 42.r,
      height: 42.r,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppBorderRadius.r8,
      ),
      child: Icon(icon, color: color, size: 22.r),
    );

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 11),
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, wide ? 22 : 18),
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 11),
              color: AppColors.textLight,
            ),
          ),
      ],
    );

    return _Card(
      color: AppColors.white,
      padding: EdgeInsets.all(16.r),
      child: wide
          ? Row(children: [iconBox, SizedBox(width: 14.w), Expanded(child: text)])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              iconBox,
              SizedBox(height: 10.h),
              text,
            ]),
    );
  }
}

// ── Discount Breakdown Card ───────────────────────────────────────────────────

class _DiscountBreakdownCard extends StatelessWidget {
  const _DiscountBreakdownCard({required this.state});
  final AnalyticsState state;

  @override
  Widget build(BuildContext context) {
    final salesRef     = state.totalSales > 0 ? state.totalSales : 1.0;
    final nonCancelled = (state.orderVolume - state.cancelledCount).clamp(1, double.maxFinite);
    final freeDelPct   = state.freeDeliveryCount / nonCancelled * 100;
    final freeItemPct  = state.freeItemOrderCount / nonCancelled * 100;

    String pct(double v) => '${(v / salesRef * 100).toStringAsFixed(1)}% of sales';

    final l10n = AppLocalizations.of(context)!;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(l10n.analyticsDiscountsFreeItems),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _MiniCard(
                  label: l10n.analyticsDeliveryCharges,
                  value: 'EGP ${state.totalDeliveryCharges.toStringAsFixed(0)}',
                  subtitle: pct(state.totalDeliveryCharges),
                  icon: Icons.delivery_dining_outlined,
                  color: AppColors.accentGold,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _MiniCard(
                  label: l10n.analyticsTotalDiscounts,
                  value: 'EGP ${state.totalDiscounts.toStringAsFixed(0)}',
                  subtitle: pct(state.totalDiscounts),
                  icon: Icons.local_offer_outlined,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _MiniCard(
                  label: l10n.analyticsLoyaltyDiscounts,
                  value: 'EGP ${state.loyaltyDiscountTotal.toStringAsFixed(0)}',
                  subtitle: pct(state.loyaltyDiscountTotal),
                  icon: Icons.stars_rounded,
                  color: const Color(0xFF6A1B9A),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _MiniCard(
                  label: l10n.analyticsPromoDiscounts,
                  value: 'EGP ${state.promoDiscountTotal.toStringAsFixed(0)}',
                  subtitle: pct(state.promoDiscountTotal),
                  icon: Icons.discount_outlined,
                  color: const Color(0xFF1565C0),
                ),
              ),
            ],
          ),
          if (state.freeDeliveryDiscountTotal > 0) ...[
            SizedBox(height: 10.h),
            _MiniCard(
              label: l10n.analyticsFreeDeliveryValue,
              value: 'EGP ${state.freeDeliveryDiscountTotal.toStringAsFixed(0)}',
              subtitle: pct(state.freeDeliveryDiscountTotal),
              icon: Icons.local_shipping_outlined,
              color: const Color(0xFF00838F),
            ),
          ],
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _PctBadge(
                  label: l10n.analyticsFreeDelivery,
                  count: state.freeDeliveryCount,
                  pct: freeDelPct,
                  color: const Color(0xFF00838F),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _PctBadge(
                  label: l10n.analyticsFreeItems,
                  count: state.freeItemOrderCount,
                  pct: freeItemPct,
                  color: const Color(0xFFE65100),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PctBadge extends StatelessWidget {
  const _PctBadge({
    required this.label,
    required this.count,
    required this.pct,
    required this.color,
  });

  final String label;
  final int count;
  final double pct;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: AppBorderRadius.r8,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 10),
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Text(
                '${pct.toStringAsFixed(1)}%',
                style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 18),
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                '$count ${AppLocalizations.of(context)!.analyticsOrders.toLowerCase()}',
                style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 10),
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: AppBorderRadius.r8,
      ),
      child: Row(
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppBorderRadius.r8,
            ),
            child: Icon(icon, color: color, size: 16.r),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 9),
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 13),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 9),
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rates Row ─────────────────────────────────────────────────────────────────

class _RatesRow extends StatelessWidget {
  const _RatesRow({required this.state});
  final AnalyticsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _RateCard(
            label: l10n.analyticsFulfillment,
            rate: state.fulfilledRate,
            color: AppColors.primaryMid,
            detail: '${state.fulfilledCount}/${state.orderVolume}',
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _RateCard(
            label: l10n.analyticsCancellation,
            rate: state.cancellationRate,
            color: AppColors.error,
            detail: '${state.cancelledCount}/${state.orderVolume}',
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _RateCard(
            label: l10n.analyticsReturning,
            rate: state.returningCustomerRate,
            color: const Color(0xFF6A1B9A),
            detail: '${state.returningCustomers}/${state.totalUniqueCustomers}',
          ),
        ),
      ],
    );
  }
}

class _RateCard extends StatelessWidget {
  const _RateCard({
    required this.label,
    required this.rate,
    required this.color,
    required this.detail,
  });

  final String label;
  final double rate;
  final Color color;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final pct = (rate * 100).toStringAsFixed(1);
    return _Card(
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 10),
              color: AppColors.textLight,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            '$pct%',
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 20),
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: rate.clamp(0.0, 1.0),
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4.h,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            detail,
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 10),
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Customer Metrics ──────────────────────────────────────────────────────────

class _CustomerMetricsCard extends StatelessWidget {
  const _CustomerMetricsCard({required this.state});
  final AnalyticsState state;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(AppLocalizations.of(context)!.analyticsCustomerMetrics),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _MetricRow(
                  icon: Icons.people_outline_rounded,
                  label: AppLocalizations.of(context)!.analyticsUniqueCustomers,
                  value: '${state.totalUniqueCustomers}',
                  color: const Color(0xFF1565C0),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _MetricRow(
                  icon: Icons.repeat_rounded,
                  label: AppLocalizations.of(context)!.analyticsReturning,
                  value: '${state.returningCustomers}',
                  color: const Color(0xFF6A1B9A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34.r,
          height: 34.r,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: AppBorderRadius.r8,
          ),
          child: Icon(icon, color: color, size: 18.r),
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 10),
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 18),
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Daily Sales Chart ─────────────────────────────────────────────────────────

class _DailySalesChart extends StatelessWidget {
  const _DailySalesChart({required this.series});
  final List<DailySeries> series;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(AppLocalizations.of(context)!.analyticsDailySales),
          SizedBox(height: 16.h),
          SizedBox(
            height: 140.h,
            child: CustomPaint(
              size: Size.infinite,
              painter: _BarChartPainter(series: series),
            ),
          ),
          SizedBox(height: 8.h),
          if (series.length <= 10)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: series
                  .map((s) => Text(
                        DateFormat('d/M').format(s.date),
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 9),
                          color: AppColors.textLight,
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({required this.series});
  final List<DailySeries> series;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;
    final maxVal = series.map((s) => s.value).reduce(math.max);
    if (maxVal == 0) return;
    final barCount = series.length;
    final spacing  = size.width * 0.015;
    final barW     = (size.width - spacing * (barCount + 1)) / barCount;
    final fill = Paint()..color = AppColors.primaryMid;
    final dim  = Paint()..color = AppColors.primaryMist;
    final topVal = maxVal * 1.1;
    for (int i = 0; i < barCount; i++) {
      final x    = spacing + i * (barW + spacing);
      final barH = (series[i].value / topVal) * size.height;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - barH, barW, barH),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, series[i].value > 0 ? fill : dim);
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => old.series != series;
}

// ── Sales by Zone ─────────────────────────────────────────────────────────────

class _SalesByZoneCard extends StatelessWidget {
  const _SalesByZoneCard({required this.state});
  final AnalyticsState state;

  @override
  Widget build(BuildContext context) {
    final zones  = state.salesByZone;
    final maxSales = zones.isNotEmpty
        ? zones.map((z) => z.sales).reduce(math.max)
        : 1.0;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(AppLocalizations.of(context)!.analyticsSalesByZone),
          SizedBox(height: 14.h),
          ...zones.asMap().entries.map((e) {
            final z       = e.value;
            final fraction = maxSales > 0 ? z.sales / maxSales : 0.0;
            return Padding(
              padding: EdgeInsets.only(bottom: e.key < zones.length - 1 ? 12.h : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          z.zoneName,
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 12),
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'EGP ${z.sales.toStringAsFixed(0)}',
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 12),
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDeep,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '(${z.orderCount})',
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 11),
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: fraction.clamp(0.0, 1.0),
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryMid),
                      minHeight: 6.h,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Order Status Breakdown ────────────────────────────────────────────────────

class _StatusBreakdownCard extends StatelessWidget {
  const _StatusBreakdownCard({required this.state});
  final AnalyticsState state;

  @override
  Widget build(BuildContext context) {
    final total = state.orderVolume == 0 ? 1 : state.orderVolume;
    final rows  = [
      _StatusRow('Pending',          state.pendingCount,        const Color(0xFFE65100), total),
      _StatusRow('Confirmed',        state.confirmedCount,      const Color(0xFF1565C0), total),
      _StatusRow('Preparing',        state.preparingCount,      const Color(0xFF6A1B9A), total),
      _StatusRow('Out for Delivery', state.outForDeliveryCount, AppColors.accentGold,   total),
      _StatusRow('Delivered',        state.fulfilledCount,      AppColors.primaryMid,   total),
      _StatusRow('Cancelled',        state.cancelledCount,      AppColors.error,         total),
    ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(AppLocalizations.of(context)!.analyticsOrdersByStatus),
          SizedBox(height: 14.h),
          ...rows.asMap().entries.map((e) => Padding(
                padding: EdgeInsets.only(bottom: e.key < rows.length - 1 ? 12.h : 0),
                child: _StatusBarRow(row: e.value),
              )),
        ],
      ),
    );
  }
}

class _StatusRow {
  final String label;
  final int count;
  final Color color;
  final int total;
  const _StatusRow(this.label, this.count, this.color, this.total);
  double get fraction => count / total;
}

class _StatusBarRow extends StatelessWidget {
  const _StatusBarRow({required this.row});
  final _StatusRow row;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 118.w,
          child: Text(
            row.label,
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 12),
              color: AppColors.textMid,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: row.fraction.clamp(0.0, 1.0),
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(row.color),
              minHeight: 7.h,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        SizedBox(
          width: 26,
          child: Text(
            '${row.count}',
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 12),
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ── Top Products Card ─────────────────────────────────────────────────────────

class _TopProductsCard extends StatefulWidget {
  const _TopProductsCard({required this.state});
  final AnalyticsState state;

  @override
  State<_TopProductsCard> createState() => _TopProductsCardState();
}

class _TopProductsCardState extends State<_TopProductsCard>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  static const _maxVisible = 10;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final byRev = widget.state.topProductsByRevenue;
    final byQty = widget.state.topProductsByQty;
    if (byRev.isEmpty && byQty.isEmpty) return const SizedBox.shrink();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _SectionLabel('Top Products (up to 50)')),
              Text(
                '${byRev.length} products',
                style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 10),
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          TabBar(
            controller: _tab,
            labelStyle: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 12),
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 12),
              fontWeight: FontWeight.w600,
            ),
            labelColor: AppColors.primaryDeep,
            unselectedLabelColor: AppColors.textLight,
            indicatorColor: AppColors.primaryDeep,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: AppColors.border,
            tabs: [Tab(text: AppLocalizations.of(context)!.analyticsByRevenue), Tab(text: AppLocalizations.of(context)!.analyticsByQuantity)],
          ),
          SizedBox(height: 12.h),
          AnimatedBuilder(
            animation: _tab,
            builder: (context, _) {
              final products = _tab.index == 0 ? byRev : byQty;
              final visible  = _expanded
                  ? products
                  : products.take(_maxVisible).toList();
              return Column(
                children: [
                  _ProductListInline(
                    products: visible,
                    showRevenue: _tab.index == 0,
                  ),
                  if (products.length > _maxVisible) ...[
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _expanded
                                ? AppLocalizations.of(context)!.analyticsShowLess
                                : 'Show all ${products.length} ${AppLocalizations.of(context)!.analyticsProduct.toLowerCase()}s',
                            style: GoogleFonts.nunito(
                              fontSize: Responsive.sp(context, 12),
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryMid,
                            ),
                          ),
                          Icon(
                            _expanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primaryMid,
                            size: 16.r,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProductListInline extends StatelessWidget {
  const _ProductListInline({required this.products, required this.showRevenue});
  final List<TopProduct> products;
  final bool showRevenue;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)!.analyticsNoData, style: GoogleFonts.nunito(color: AppColors.textLight)),
      );
    }
    final maxVal = showRevenue
        ? products.map((p) => p.revenue).reduce(math.max)
        : products.map((p) => p.quantity.toDouble()).reduce(math.max);

    return Column(
      children: products.asMap().entries.map((e) {
        final i = e.key;
        final p = e.value;
        final fraction = maxVal > 0
            ? (showRevenue ? p.revenue : p.quantity.toDouble()) / maxVal
            : 0.0;
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            children: [
              Container(
                width: 22.r,
                height: 22.r,
                decoration: const BoxDecoration(
                  color: AppColors.primaryMist,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 10),
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            p.name,
                            style: GoogleFonts.nunito(
                              fontSize: Responsive.sp(context, 12),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          showRevenue
                              ? 'EGP ${p.revenue.toStringAsFixed(0)}'
                              : '×${p.quantity}',
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 12),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDeep,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: fraction.clamp(0.0, 1.0),
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryMid),
                        minHeight: 4.h,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Device Type Card ──────────────────────────────────────────────────────────

class _DeviceTypeCard extends StatelessWidget {
  const _DeviceTypeCard({required this.counts});
  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    final total  = counts.values.fold(0, (s, v) => s + v);
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      AppColors.primaryDeep,
      const Color(0xFF1565C0),
      AppColors.accentGold,
      AppColors.accentOrange,
    ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(AppLocalizations.of(context)!.analyticsDeviceType),
          SizedBox(height: 14.h),
          ...sorted.asMap().entries.map((e) {
            final idx  = e.key;
            final entry = e.value;
            final pct  = total > 0 ? entry.value / total : 0.0;
            final col  = colors[idx % colors.length];
            final label = entry.key == 'ios'
                ? 'iOS'
                : entry.key == 'android'
                    ? 'Android'
                    : entry.key.replaceAll('_', ' ').toLowerCase();
            return Padding(
              padding: EdgeInsets.only(bottom: idx < sorted.length - 1 ? 10.h : 0),
              child: Row(
                children: [
                  Container(
                    width: 10.r,
                    height: 10.r,
                    decoration: BoxDecoration(color: col, shape: BoxShape.circle),
                  ),
                  SizedBox(width: 8.w),
                  SizedBox(
                    width: 80.w,
                    child: Text(
                      label,
                      style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 12),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMid,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct.clamp(0.0, 1.0),
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(col),
                        minHeight: 7.h,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${(pct * 100).toStringAsFixed(1)}%',
                    style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 12),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '(${entry.value})',
                    style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 10),
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Abandoned Carts Card ──────────────────────────────────────────────────────

class _AbandonedCartsCard extends StatefulWidget {
  const _AbandonedCartsCard({required this.carts});
  final List<AbandonedCart> carts;

  @override
  State<_AbandonedCartsCard> createState() => _AbandonedCartsCardState();
}

class _AbandonedCartsCardState extends State<_AbandonedCartsCard> {
  int? _expanded;

  @override
  Widget build(BuildContext context) {
    final totalValue = widget.carts.fold(0.0, (s, c) => s + c.cartTotal);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _SectionLabel(AppLocalizations.of(context)!.analyticsAbandonedCarts)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.carts.length}',
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 12),
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Total cart value: EGP ${totalValue.toStringAsFixed(0)}',
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 11),
              color: AppColors.textLight,
            ),
          ),
          SizedBox(height: 12.h),
          ...widget.carts.asMap().entries.map((e) {
            final i    = e.key;
            final cart = e.value;
            final open = _expanded == i;
            return Column(
              children: [
                if (i > 0) Divider(height: 1, color: AppColors.border),
                InkWell(
                  onTap: () => setState(() => _expanded = open ? null : i),
                  borderRadius: AppBorderRadius.r8,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Row(
                      children: [
                        Container(
                          width: 36.r,
                          height: 36.r,
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.shopping_cart_outlined,
                              color: AppColors.error, size: 18.r),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cart.customerName ?? AppLocalizations.of(context)!.analyticsGuest,
                                style: GoogleFonts.nunito(
                                  fontSize: Responsive.sp(context, 13),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              if (cart.customerPhone != null)
                                Text(
                                  cart.customerPhone!,
                                  style: GoogleFonts.nunito(
                                    fontSize: Responsive.sp(context, 11),
                                    color: AppColors.textLight,
                                  ),
                                ),
                              Text(
                                DateFormat('MMM d, h:mm a').format(cart.abandonedAt),
                                style: GoogleFonts.nunito(
                                  fontSize: Responsive.sp(context, 10),
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'EGP ${cart.cartTotal.toStringAsFixed(0)}',
                              style: GoogleFonts.nunito(
                                fontSize: Responsive.sp(context, 13),
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              '${cart.items.length} item${cart.items.length == 1 ? '' : 's'}',
                              style: GoogleFonts.nunito(
                                fontSize: Responsive.sp(context, 10),
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          open
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textLight,
                          size: 18.r,
                        ),
                      ],
                    ),
                  ),
                ),
                if (open)
                  Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBg,
                      borderRadius: AppBorderRadius.r8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (cart.deviceType != null) ...[
                          Row(
                            children: [
                              Icon(Icons.phone_android_rounded,
                                  size: 13.r, color: AppColors.textLight),
                              SizedBox(width: 4.w),
                              Text(
                                cart.deviceType!.toUpperCase(),
                                style: GoogleFonts.nunito(
                                  fontSize: Responsive.sp(context, 10),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                        ],
                        Text(
                          AppLocalizations.of(context)!.analyticsCartItems.toUpperCase(),
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 9),
                            fontWeight: FontWeight.w700,
                            color: AppColors.textLight,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        ...cart.items.map((item) => Padding(
                              padding: EdgeInsets.only(bottom: 4.h),
                              child: Row(
                                children: [
                                  Text(
                                    '×${item.quantity}',
                                    style: GoogleFonts.nunito(
                                      fontSize: Responsive.sp(context, 11),
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryMid,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      item.productName,
                                      style: GoogleFonts.nunito(
                                        fontSize: Responsive.sp(context, 12),
                                        color: AppColors.textMid,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'EGP ${item.subtotal.toStringAsFixed(0)}',
                                    style: GoogleFonts.nunito(
                                      fontSize: Responsive.sp(context, 11),
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── Product Funnel List Card ──────────────────────────────────────────────────

class _ProductFunnelListCard extends StatefulWidget {
  const _ProductFunnelListCard({required this.state});
  final AnalyticsState state;

  @override
  State<_ProductFunnelListCard> createState() => _ProductFunnelListCardState();
}

class _ProductFunnelListCardState extends State<_ProductFunnelListCard>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  int _page = 0;
  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (_tab.indexIsChanging) setState(() => _page = 0);
      });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.state.productFunnelEntries;
    if (entries.isEmpty && !widget.state.productFunnelLoading) {
      return const SizedBox.shrink();
    }

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _SectionLabel(AppLocalizations.of(context)!.analyticsProduct + ' Funnel — Views vs Add-to-Cart')),
              if (entries.isNotEmpty)
                Text(
                  '${entries.length} products',
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 10),
                    color: AppColors.textLight,
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          if (widget.state.productFunnelLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryDeep),
              ),
            )
          else ...[
            TabBar(
              controller: _tab,
              labelStyle: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 12),
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 12),
                fontWeight: FontWeight.w600,
              ),
              labelColor: AppColors.primaryDeep,
              unselectedLabelColor: AppColors.textLight,
              indicatorColor: AppColors.primaryDeep,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: AppColors.border,
              tabs: [Tab(text: AppLocalizations.of(context)!.analyticsByViews), Tab(text: AppLocalizations.of(context)!.analyticsByAddToCart)],
            ),
            SizedBox(height: 12.h),
            AnimatedBuilder(
              animation: _tab,
              builder: (context, _) {
                final sorted = _tab.index == 0
                    ? (List.of(entries)
                      ..sort((a, b) => b.viewCount.compareTo(a.viewCount)))
                    : (List.of(entries)
                      ..sort((a, b) => b.cartCount.compareTo(a.cartCount)));
                final totalPages =
                    ((sorted.length - 1) ~/ _pageSize + 1).clamp(1, 9999);
                final start = _page * _pageSize;
                final end = (start + _pageSize).clamp(0, sorted.length);
                final page = sorted.sublist(start, end);

                return Column(
                  children: [
                    // Header row
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          SizedBox(width: 28.w),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.analyticsProduct,
                              style: GoogleFonts.nunito(
                                fontSize: Responsive.sp(context, 10),
                                fontWeight: FontWeight.w700,
                                color: AppColors.textLight,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 44.w,
                            child: Text(
                              AppLocalizations.of(context)!.analyticsViews,
                              style: GoogleFonts.nunito(
                                fontSize: Responsive.sp(context, 10),
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1565C0),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            width: 44.w,
                            child: Text(
                              AppLocalizations.of(context)!.analyticsCarts,
                              style: GoogleFonts.nunito(
                                fontSize: Responsive.sp(context, 10),
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDeep,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            width: 48.w,
                            child: Text(
                              'Conv.',
                              style: GoogleFonts.nunito(
                                fontSize: Responsive.sp(context, 10),
                                fontWeight: FontWeight.w700,
                                color: AppColors.textLight,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: AppColors.border),
                    SizedBox(height: 4.h),
                    // Data rows
                    ...page.asMap().entries.map((e) {
                      final rank  = start + e.key + 1;
                      final entry = e.value;
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 7.h),
                        child: Row(
                          children: [
                            Container(
                              width: 22.r,
                              height: 22.r,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryMist,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$rank',
                                  style: GoogleFonts.nunito(
                                    fontSize: Responsive.sp(context, 9),
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDeep,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                entry.productName,
                                style: GoogleFonts.nunito(
                                  fontSize: Responsive.sp(context, 12),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              width: 44.w,
                              child: Text(
                                '${entry.viewCount}',
                                style: GoogleFonts.nunito(
                                  fontSize: Responsive.sp(context, 12),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1565C0),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              width: 44.w,
                              child: Text(
                                '${entry.cartCount}',
                                style: GoogleFonts.nunito(
                                  fontSize: Responsive.sp(context, 12),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDeep,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              width: 48.w,
                              child: Text(
                                '${(entry.conversionRate * 100).toStringAsFixed(1)}%',
                                style: GoogleFonts.nunito(
                                  fontSize: Responsive.sp(context, 12),
                                  fontWeight: FontWeight.w700,
                                  color: entry.conversionRate >= 0.1
                                      ? AppColors.primaryMid
                                      : AppColors.textLight,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    // Pagination controls
                    if (totalPages > 1) ...[
                      SizedBox(height: 8.h),
                      Divider(height: 1, color: AppColors.border),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed:
                                _page > 0 ? () => setState(() => _page--) : null,
                            icon: Icon(Icons.chevron_left_rounded, size: 20.r),
                            color: AppColors.primaryMid,
                            disabledColor: AppColors.border,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(
                                minWidth: 32.r, minHeight: 32.r),
                          ),
                          Text(
                            'Page ${_page + 1} of $totalPages',
                            style: GoogleFonts.nunito(
                              fontSize: Responsive.sp(context, 12),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMid,
                            ),
                          ),
                          IconButton(
                            onPressed: _page < totalPages - 1
                                ? () => setState(() => _page++)
                                : null,
                            icon: Icon(Icons.chevron_right_rounded, size: 20.r),
                            color: AppColors.primaryMid,
                            disabledColor: AppColors.border,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(
                                minWidth: 32.r, minHeight: 32.r),
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

// ── Event Tracking Card ───────────────────────────────────────────────────────

class _EventTrackingCard extends StatelessWidget {
  const _EventTrackingCard({required this.counts});
  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(AppLocalizations.of(context)!.analyticsEventTracking),
          SizedBox(height: 14.h),
          ...sorted.map((e) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Row(
                  children: [
                    Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryMid,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        e.key.replaceAll('_', ' ').toLowerCase(),
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 13),
                          color: AppColors.textMid,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${e.value}',
                      style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 14),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ── Loading / Error ───────────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: const CircularProgressIndicator(color: AppColors.primaryDeep),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 40.r, color: AppColors.error),
          SizedBox(height: 10.h),
          Text(
            message ?? AppLocalizations.of(context)!.analyticsFailedLoad,
            style: GoogleFonts.nunito(color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 14.h),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(AppLocalizations.of(context)!.analyticsRetry),
            style: TextButton.styleFrom(foregroundColor: AppColors.primaryDeep),
          ),
        ],
      ),
    );
  }
}

// ── Shared Primitives ─────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child, this.color, this.padding});
  final Widget child;
  final Color? color;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: color ?? AppColors.white,
        borderRadius: AppBorderRadius.r16,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: GoogleFonts.nunito(
          fontSize: Responsive.sp(context, 10),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.textLight,
        ),
      );
}
