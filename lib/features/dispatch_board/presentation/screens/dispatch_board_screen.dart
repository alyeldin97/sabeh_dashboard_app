import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import '../../../auth/data/model/staff_user.dart';
import '../../../orders/data/model/order_model.dart';
import '../../../staff_mgmt/data/model/staff_member.dart';
import '../../../staff_mgmt/presentation/cubits/staff_cubit.dart';
import '../cubits/dispatch_board_cubit.dart';
import '../cubits/dispatch_board_state.dart';
import '../widgets/kanban_column.dart';
import '../widgets/order_dispatch_card.dart';
import 'daily_report_screen.dart';
import 'driver_report_screen.dart';

class DispatchBoardScreen extends StatelessWidget {
  const DispatchBoardScreen({super.key, this.branchId});
  final String? branchId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => DispatchBoardCubit(DependencyInjector().ordersRepository)
            ..load(branchId: branchId)
            ..startWatching(branchId: branchId),
        ),
        BlocProvider(
          create: (_) => DependencyInjector().staffCubit..load(),
        ),
      ],
      child: _DispatchBoardView(branchId: branchId),
    );
  }
}

class _DispatchBoardView extends StatefulWidget {
  const _DispatchBoardView({this.branchId});
  final String? branchId;

  @override
  State<_DispatchBoardView> createState() => _DispatchBoardViewState();
}

class _DispatchBoardViewState extends State<_DispatchBoardView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _searchCtrl = TextEditingController();

  static const _statuses = OrderStatus.values;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _statuses.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = Responsive.isWeb(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          _BoardTopBar(
            branchId: widget.branchId,
            searchCtrl: _searchCtrl,
            isWeb: isWeb,
          ),
          if (!isWeb)
            BlocBuilder<DispatchBoardCubit, DispatchBoardState>(
              buildWhen: (p, c) => p.columns != c.columns,
              builder: (ctx, s) => _MobileTabBar(
                tabCtrl: _tabCtrl,
                columns: s.columns,
              ),
            ),
          Expanded(
            child: BlocBuilder<DispatchBoardCubit, DispatchBoardState>(
              builder: (ctx, state) {
                if (state.status == DispatchBoardStatus.loading &&
                    state.columns.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == DispatchBoardStatus.failure) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 36),
                        const SizedBox(height: 8),
                        Text(state.errorMessage ?? 'Failed to load orders',
                            style: GoogleFonts.nunito()),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => ctx
                              .read<DispatchBoardCubit>()
                              .load(branchId: widget.branchId),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final drivers = _deliveryDrivers(ctx);

                if (isWeb) {
                  return _WebBoard(
                    state:    state,
                    drivers:  drivers,
                    branchId: widget.branchId,
                  );
                }
                return _MobileBoard(
                  tabCtrl:  _tabCtrl,
                  state:    state,
                  drivers:  drivers,
                  branchId: widget.branchId,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<StaffMember> _deliveryDrivers(BuildContext ctx) {
    final staffState = ctx.read<StaffCubit>().state;
    return staffState.members
        .where((m) =>
            m.role == StaffRole.deliveryUser ||
            m.role == StaffRole.deliveryManager)
        .toList();
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────

class _BoardTopBar extends StatelessWidget {
  const _BoardTopBar({
    required this.branchId,
    required this.searchCtrl,
    required this.isWeb,
  });
  final String? branchId;
  final TextEditingController searchCtrl;
  final bool isWeb;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DispatchBoardCubit, DispatchBoardState>(
      builder: (ctx, state) {
        final cubit = ctx.read<DispatchBoardCubit>();
        return Container(
          color: AppColors.primaryDeep,
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.of(context).padding.top + 12,
            16,
            12,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.view_kanban_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Dispatch Board',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  // Report buttons
                  _TopBtn(
                    icon: Icons.person_outlined,
                    label: 'Driver',
                    onTap: () => Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => DriverReportScreen(
                          initialDate: state.viewDate,
                          branchId:    branchId,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _TopBtn(
                    icon: Icons.bar_chart_rounded,
                    label: 'Daily',
                    onTap: () => Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => DailyReportScreen(
                          initialDate: state.viewDate,
                          branchId:    branchId,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Date navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded,
                        color: Colors.white70, size: 26),
                    onPressed: () =>
                        cubit.previousDay(branchId: branchId),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final cubitRef = ctx.read<DispatchBoardCubit>();
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: state.viewDate,
                        firstDate: DateTime(2024),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        cubitRef.goToDate(picked, branchId: branchId);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 14, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text(
                            state.isToday
                                ? 'Today — ${DateFormat('dd MMM').format(state.viewDate)}'
                                : DateFormat('EEE, dd MMM yyyy')
                                    .format(state.viewDate),
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded,
                        color: Colors.white70, size: 26),
                    onPressed: () =>
                        cubit.nextDay(branchId: branchId),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  if (!state.isToday) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () =>
                          cubit.goToToday(branchId: branchId),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Today',
                          style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              // Search + stats row
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextField(
                        controller: searchCtrl,
                        onChanged: (v) =>
                            ctx.read<DispatchBoardCubit>().setSearch(v),
                        style: GoogleFonts.nunito(
                            fontSize: 13, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search orders…',
                          hintStyle: GoogleFonts.nunito(
                              color: Colors.white38, fontSize: 13),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: Colors.white38, size: 18),
                          suffixIcon: state.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded,
                                      color: Colors.white38, size: 16),
                                  onPressed: () {
                                    searchCtrl.clear();
                                    ctx
                                        .read<DispatchBoardCubit>()
                                        .setSearch('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Total count badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.receipt_long_outlined,
                            size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          '${state.totalCount}',
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TopBtn extends StatelessWidget {
  const _TopBtn({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white70),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Web horizontal board ──────────────────────────────────────────────────────

class _WebBoard extends StatelessWidget {
  const _WebBoard({
    required this.state,
    required this.drivers,
    this.branchId,
  });
  final DispatchBoardState state;
  final List<StaffMember> drivers;
  final String? branchId;

  @override
  Widget build(BuildContext context) {
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.primaryMid.withValues(alpha: 0.4)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: OrderStatus.values.map((s) {
            final orders = state.filteredColumn(s);
            return KanbanColumn(
              status:   s,
              orders:   orders,
              drivers:  drivers,
              branchId: branchId,
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Mobile TabBar board ───────────────────────────────────────────────────────

class _MobileTabBar extends StatelessWidget {
  const _MobileTabBar({
    required this.tabCtrl,
    required this.columns,
  });
  final TabController tabCtrl;
  final Map<OrderStatus, List<OrderModel>> columns;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDeep,
      child: TabBar(
        controller: tabCtrl,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        dividerColor: Colors.transparent,
        tabs: OrderStatus.values.map((s) {
          final count = (columns[s] ?? []).length;
          final color = statusColor(s);
          return Tab(
            height: 40,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  s.label,
                  style: GoogleFonts.nunito(
                      fontSize: 12, fontWeight: FontWeight.w700),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: GoogleFonts.nunito(
                          fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MobileBoard extends StatelessWidget {
  const _MobileBoard({
    required this.tabCtrl,
    required this.state,
    required this.drivers,
    this.branchId,
  });
  final TabController tabCtrl;
  final DispatchBoardState state;
  final List<StaffMember> drivers;
  final String? branchId;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabCtrl,
      children: OrderStatus.values.map((s) {
        final orders = state.filteredColumn(s);
        return KanbanColumn(
          status:    s,
          orders:    orders,
          drivers:   drivers,
          branchId:  branchId,
          isCompact: true,
        );
      }).toList(),
    );
  }
}
