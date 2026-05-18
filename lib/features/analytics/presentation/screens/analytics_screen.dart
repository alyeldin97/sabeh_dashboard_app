import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../cubits/analytics_cubit.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key, this.branchId});
  final String? branchId;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AnalyticsCubit>().load(branchId: widget.branchId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: EdgeInsets.all(Responsive.sidePadding(context)),
            sliver: BlocBuilder<AnalyticsCubit, AnalyticsState>(
              builder: (context, state) {
                if (state.status == AnalyticsStatus.loading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppColors.primaryDeep)),
                  );
                }
                if (state.status == AnalyticsStatus.failure) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, size: 48.r, color: AppColors.error),
                          SizedBox(height: 12.h),
                          Text(
                            state.errorMessage ?? 'Failed to load analytics',
                            style: GoogleFonts.nunito(color: AppColors.textLight),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.h),
                          TextButton(
                            onPressed: () => context
                                .read<AnalyticsCubit>()
                                .load(branchId: widget.branchId),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildListDelegate([
                    _RevenueSection(state: state),
                    SizedBox(height: 24.h),
                    _OrderStatusSection(state: state),
                    SizedBox(height: 24.h),
                    _TopProductsSection(state: state),
                    SizedBox(height: 32.h),
                  ]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final user = context.read<AuthCubit>().state.user;
    return SliverAppBar(
      pinned: true,
      expandedHeight: 90.h,
      backgroundColor: AppColors.primaryDeep,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Analytics',
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 22),
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                      if (user?.branchId != null)
                        Text(
                          'Branch view',
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 12),
                            color: AppColors.primaryPale,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () =>
                        context.read<AnalyticsCubit>().load(branchId: widget.branchId),
                    icon: Icon(Icons.refresh_rounded, color: AppColors.white, size: 22.r),
                    tooltip: 'Refresh',
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

// ── Revenue Section ──────────────────────────────────────────────────────────

class _RevenueSection extends StatelessWidget {
  const _RevenueSection({required this.state});
  final AnalyticsState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Revenue'),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _RevenueCard(
                period: 'Today',
                amount: state.todayRevenue,
                orders: state.todayOrders,
                icon: Icons.today_outlined,
                color: AppColors.primaryDeep,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _RevenueCard(
                period: 'This Week',
                amount: state.weekRevenue,
                orders: null,
                icon: Icons.date_range_outlined,
                color: const Color(0xFF6A1B9A),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _RevenueCard(
          period: 'This Month',
          amount: state.monthRevenue,
          orders: state.totalOrders,
          icon: Icons.calendar_month_outlined,
          color: AppColors.accentOrange,
          wide: true,
        ),
      ],
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({
    required this.period,
    required this.amount,
    required this.orders,
    required this.icon,
    required this.color,
    this.wide = false,
  });

  final String period;
  final double amount;
  final int? orders;
  final IconData icon;
  final Color color;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r16,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: wide
          ? Row(
              children: [
                _iconBox(color),
                SizedBox(width: 16.w),
                Expanded(child: _textContent(context)),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _iconBox(color),
                SizedBox(height: 12.h),
                _textContent(context),
              ],
            ),
    );
  }

  Widget _iconBox(Color color) => Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: AppBorderRadius.r8,
        ),
        child: Icon(icon, color: color, size: 22.r),
      );

  Widget _textContent(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            period,
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 12),
              color: AppColors.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'EGP ${amount.toStringAsFixed(0)}',
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 20),
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          if (orders != null)
            Text(
              '$orders orders total',
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 11),
                color: AppColors.textLight,
              ),
            ),
        ],
      );
}

// ── Order Status Section ─────────────────────────────────────────────────────

class _OrderStatusSection extends StatelessWidget {
  const _OrderStatusSection({required this.state});
  final AnalyticsState state;

  @override
  Widget build(BuildContext context) {
    final total = state.totalOrders == 0 ? 1 : state.totalOrders;
    final statuses = [
      _StatusRow('Pending',          state.pendingCount,        const Color(0xFFE65100), total),
      _StatusRow('Confirmed',         state.confirmedCount,      const Color(0xFF1565C0), total),
      _StatusRow('Preparing',         state.preparingCount,      const Color(0xFF6A1B9A), total),
      _StatusRow('Out for Delivery',  state.outForDeliveryCount, AppColors.accentGold,   total),
      _StatusRow('Delivered',         state.deliveredCount,      AppColors.primaryMid,   total),
      _StatusRow('Cancelled',         state.cancelledCount,      AppColors.error,         total),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Orders by Status'),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppBorderRadius.r16,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: List.generate(statuses.length, (i) {
              final s = statuses[i];
              return Padding(
                padding: EdgeInsets.only(bottom: i < statuses.length - 1 ? 14.h : 0),
                child: _StatusBarRow(row: s, context: context),
              );
            }),
          ),
        ),
      ],
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
  const _StatusBarRow({required this.row, required this.context});
  final _StatusRow row;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Row(
      children: [
        SizedBox(
          width: 120.w,
          child: Text(
            row.label,
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 13),
              color: AppColors.textMid,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: row.fraction.clamp(0.0, 1.0),
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(row.color),
              minHeight: 8.h,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 28,
          child: Text(
            '${row.count}',
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 13),
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

// ── Top Products Section ─────────────────────────────────────────────────────

class _TopProductsSection extends StatelessWidget {
  const _TopProductsSection({required this.state});
  final AnalyticsState state;

  @override
  Widget build(BuildContext context) {
    if (state.topProducts.isEmpty) return const SizedBox.shrink();

    final maxRev = state.topProducts.first.revenue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Top Products'),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppBorderRadius.r16,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: List.generate(state.topProducts.length, (i) {
              final p = state.topProducts[i];
              final fraction = maxRev > 0 ? p.revenue / maxRev : 0.0;
              return Padding(
                padding: EdgeInsets.only(bottom: i < state.topProducts.length - 1 ? 16.h : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24.r,
                          height: 24.r,
                          decoration: BoxDecoration(
                            color: AppColors.primaryMist,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: GoogleFonts.nunito(
                                fontSize: Responsive.sp(context, 11),
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDeep,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            p.name,
                            style: GoogleFonts.nunito(
                              fontSize: Responsive.sp(context, 14),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'EGP ${p.revenue.toStringAsFixed(0)}',
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 13),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDeep,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        SizedBox(width: 34.r),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: fraction.clamp(0.0, 1.0),
                              backgroundColor: AppColors.border,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryMid),
                              minHeight: 6.h,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '×${p.quantity}',
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 11),
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ── Shared ───────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: GoogleFonts.nunito(
          fontSize: Responsive.sp(context, 11),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppColors.textLight,
        ),
      );
}
