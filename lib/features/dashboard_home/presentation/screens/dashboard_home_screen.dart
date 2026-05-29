import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../orders/presentation/cubits/orders_cubit.dart';
import '../../../orders/data/model/order_model.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key, this.branchId, this.onMenuTap});
  final String? branchId;
  final VoidCallback? onMenuTap;

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late final List<Animation<double>> _stagger;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _stagger = List.generate(
      5,
      (i) => CurvedAnimation(
        parent: _entrance,
        curve: Interval(i * 0.1, 0.5 + i * 0.1, curve: Curves.easeOutCubic),
      ),
    );
    _entrance.forward();
    context.read<OrdersCubit>().load(branchId: widget.branchId);
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Widget _fade(int i, Widget child) => FadeTransition(
        opacity: _stagger[i],
        child: AnimatedBuilder(
          animation: _stagger[i],
          builder: (_, c) =>
              Transform.translate(offset: Offset(0, 20 * (1 - _stagger[i].value)), child: c),
          child: child,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.read<AuthCubit>().state.user;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(user?.name ?? l10n.navStaffFallback, l10n),
          SliverToBoxAdapter(child: SizedBox(height: 20.h)),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.sidePadding(context)),
            sliver: SliverToBoxAdapter(
              child: BlocBuilder<OrdersCubit, OrdersState>(
                builder: (_, state) {
                  final orders = state.orders;
                  final cols = Responsive.gridCrossAxisCount(context);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _fade(
                        0,
                        _SectionHeader(l10n.homeGlance),
                      ),
                      SizedBox(height: 14.h),
                      _fade(
                        1,
                        GridView.count(
                          crossAxisCount: cols,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: cols >= 4 ? 1.6 : 1.4,
                          children: [
                            _StatCard(
                              label: l10n.homeTotalOrders,
                              value: '${orders.length}',
                              icon: Icons.receipt_long_rounded,
                              color: AppColors.primaryDeep,
                            ),
                            _StatCard(
                              label: l10n.homePending,
                              value: '${orders.where((o) => o.status == OrderStatus.pending).length}',
                              icon: Icons.pending_actions_rounded,
                              color: const Color(0xFFE65100),
                            ),
                            _StatCard(
                              label: l10n.homeInProgress,
                              value: '${orders.where((o) => o.status == OrderStatus.preparing || o.status == OrderStatus.confirmed).length}',
                              icon: Icons.restaurant_rounded,
                              color: const Color(0xFF6A1B9A),
                            ),
                            _StatCard(
                              label: l10n.homeDelivered,
                              value: '${orders.where((o) => o.status == OrderStatus.delivered).length}',
                              icon: Icons.check_circle_rounded,
                              color: AppColors.primaryMid,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      _fade(1, const _OnlineUsersCard()),
                      SizedBox(height: 24.h),
                      _fade(2, _SectionHeader(l10n.homeActiveOrders)),
                      SizedBox(height: 12.h),
                      _fade(
                        3,
                        state.status == OrdersStatus.loading
                            ? const Center(child: CircularProgressIndicator())
                            : _ActiveOrdersPreview(
                                orders: orders
                                    .where((o) =>
                                        o.status != OrderStatus.delivered &&
                                        o.status != OrderStatus.cancelled)
                                    .take(5)
                                    .toList(),
                              ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(String name, AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 110.h,
      pinned: true,
      floating: false,
      automaticallyImplyLeading: false,
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
              child: _fade(
                0,
                Row(
                  children: [
                    if (widget.onMenuTap != null) ...[
                      GestureDetector(
                        onTap: widget.onMenuTap,
                        child: Container(
                          width: 40.r,
                          height: 40.r,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(Icons.menu_rounded, color: AppColors.white, size: 22.r),
                        ),
                      ),
                      SizedBox(width: 12.w),
                    ],
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _greeting(l10n),
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 13),
                            color: AppColors.primaryPale,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          name,
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 20),
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.notifications_outlined, color: AppColors.white, size: 22.r),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _greeting(AppLocalizations l10n) {
    final h = DateTime.now().hour;
    if (h < 12) return l10n.homeGoodMorning;
    if (h < 17) return l10n.homeGoodAfternoon;
    return l10n.homeGoodEvening;
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: Responsive.sp(context, 17),
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final iconSize = Responsive.r(context, 36);
    final padding = Responsive.r(context, 14);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r12,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppBorderRadius.r8,
            ),
            child: Icon(icon, color: color, size: Responsive.r(context, 20)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 24),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 12),
                  color: AppColors.textLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnlineUsersCard extends StatefulWidget {
  const _OnlineUsersCard();

  @override
  State<_OnlineUsersCard> createState() => _OnlineUsersCardState();
}

class _OnlineUsersCardState extends State<_OnlineUsersCard> {
  int? _count;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final cutoff = DateTime.now().subtract(const Duration(minutes: 30)).toUtc();
      final result = await Supabase.instance.client
          .from('user_sessions')
          .select('id')
          .gte('last_active', cutoff.toIso8601String());
      if (mounted) setState(() => _count = (result as List).length);
    } catch (_) {
      if (mounted) setState(() => _count = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.r(context, 14)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r12,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.wifi_rounded, color: const Color(0xFF1B5E20), size: 24.r),
                Positioned(
                  top: 8.r,
                  right: 8.r,
                  child: Container(
                    width: 8.r,
                    height: 8.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.analyticsOnlineNow,
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 11),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                  ),
                ),
                _count == null
                    ? SizedBox(height: 20.h, width: 40.w,
                        child: const LinearProgressIndicator())
                    : Text(
                        '$_count',
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 28),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                Text(
                  AppLocalizations.of(context)!.analyticsActiveInLast(30),
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 11),
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6.r,
                  height: 6.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  AppLocalizations.of(context)!.analyticsLive,
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 11),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E7D32),
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

class _ActiveOrdersPreview extends StatelessWidget {
  const _ActiveOrdersPreview({required this.orders});
  final List<OrderModel> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppBorderRadius.r12,
        ),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 40.r, color: AppColors.primaryLight),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context)!.homeAllCaughtUp,
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 15),
                fontWeight: FontWeight.w700,
                color: AppColors.textCharcoal,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.homeNoActiveOrders,
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 13),
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r12,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(orders.length, (i) {
          final o = orders[i];
          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: AppColors.primaryMist,
                    borderRadius: AppBorderRadius.r8,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 14),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  '#${o.orderNumber}',
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 14),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                subtitle: Text(
                  o.status.label,
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 12),
                    color: AppColors.textLight,
                  ),
                ),
                trailing: Text(
                  'EGP ${o.totalPrice.toStringAsFixed(0)}',
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 14),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDeep,
                  ),
                ),
              ),
              if (i < orders.length - 1) Divider(height: 1, color: AppColors.border),
            ],
          );
        }),
      ),
    );
  }
}
