import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/styling/colors.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import '../../../auth/data/model/staff_user.dart';
import '../../../expenses/data/model/expense_model.dart' show ExpenseModel, ExpenseType;
import '../../../expenses/presentation/cubits/expenses_cubit.dart';
import '../../../expenses/presentation/cubits/expenses_state.dart';
import '../../../orders/data/model/order_model.dart';
import '../../../staff_mgmt/data/model/staff_member.dart';

// ── Zone data class ────────────────────────────────────────────────────────────

class _ZoneData {
  final String id;
  final String name;
  final String? nameAr;
  final String? branchId;
  final double userPaidDeliveryFees;
  final double deliveryFeesPaidToDriver;

  const _ZoneData({
    required this.id,
    required this.name,
    this.nameAr,
    this.branchId,
    required this.userPaidDeliveryFees,
    required this.deliveryFeesPaidToDriver,
  });

  factory _ZoneData.fromJson(Map<String, dynamic> j) => _ZoneData(
        id:              j['id'] as String,
        name:            j['name'] as String,
        nameAr:          j['name_ar'] as String?,
        branchId:        j['branch_id'] as String?,
        userPaidDeliveryFees: (j['user_paid_delivery_fees'] as num?)?.toDouble() ?? 0,
        deliveryFeesPaidToDriver:    (j['delivery_fees_paid_to_driver'] as num?)?.toDouble() ?? 0,
      );

  _ZoneData copyWith({double? deliveryFeesPaidToDriver}) => _ZoneData(
        id: id, name: name, nameAr: nameAr, branchId: branchId,
        userPaidDeliveryFees: userPaidDeliveryFees,
        deliveryFeesPaidToDriver: deliveryFeesPaidToDriver ?? this.deliveryFeesPaidToDriver,
      );
}

// ── Zone stat data class ───────────────────────────────────────────────────────

class _ZoneStat {
  final String name;
  final String? zoneId;
  final int count;
  final double custFees;
  final double bizCost;
  final double totalValue;
  final double cogs;

  const _ZoneStat({
    required this.name,
    this.zoneId,
    required this.count,
    required this.custFees,
    required this.bizCost,
    this.totalValue = 0,
    this.cogs = 0,
  });

  double get avgValue => count > 0 ? totalValue / count : 0;
}

// ── Branch data class ─────────────────────────────────────────────────────────

class _BranchItem {
  final String id;
  final String name;
  const _BranchItem({required this.id, required this.name});
}

// ── Driver stat data class ─────────────────────────────────────────────────────

class _DriverStat {
  final StaffMember driver;
  final List<OrderModel> orders;
  final int cashCount;
  final double cashVal;
  final int ipCount;
  final double ipVal;
  final double actualCost;
  final double maradia;
  final double deposits;
  final double owes;

  const _DriverStat({
    required this.driver,
    required this.orders,
    required this.cashCount,
    required this.cashVal,
    required this.ipCount,
    required this.ipVal,
    required this.actualCost,
    required this.maradia,
    required this.deposits,
    required this.owes,
  });
}

// ── Main Screen ────────────────────────────────────────────────────────────────

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, this.branchId, this.initialDate});
  final String? branchId;
  final DateTime? initialDate;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  // ── Date state ─────────────────────────────────────────────────────────────
  late DateTime _date;
  bool _isRangeMode = false;
  DateTime? _rangeFrom;
  DateTime? _rangeTo;

  // ── Data ───────────────────────────────────────────────────────────────────
  List<OrderModel> _orders  = [];
  List<StaffMember> _drivers = [];
  List<_ZoneData> _zones    = [];
  Map<String, double> _cogsMap = {};
  List<_BranchItem> _branches = [];
  String? _selectedBranchId;
  bool _loading = false;
  String? _error;
  double _totalCogs = 0;
  late final ExpensesCubit _expensesCubit;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    final now = widget.initialDate ?? DateTime.now();
    _date = DateTime(now.year, now.month, now.day);
    _rangeFrom = _date;
    _rangeTo   = _date;
    _expensesCubit = ExpensesCubit(DependencyInjector().expensesRepo);
    _loadBranches();
    _loadAll();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _expensesCubit.close();
    super.dispose();
  }

  // ── Loaders ────────────────────────────────────────────────────────────────

  Future<void> _loadBranches() async {
    if (widget.branchId != null) return; // branch-scoped, no filter needed
    try {
      final rows = await Supabase.instance.client
          .from('branches')
          .select('id, name')
          .order('name');
      if (mounted) {
        setState(() {
          _branches = (rows as List)
              .map((r) => _BranchItem(
                    id: r['id'] as String,
                    name: r['name'] as String,
                  ))
              .toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _loadAll() async {
    setState(() { _loading = true; _error = null; _totalCogs = 0; });
    final effectiveBranchId = widget.branchId ?? _selectedBranchId;
    try {
      final ordersRepo = DependencyInjector().ordersRepository;
      final staffRepo  = DependencyInjector().staffRepository;

      await _loadZones();

      List<OrderModel> orders;
      if (_isRangeMode && _rangeFrom != null && _rangeTo != null) {
        orders = await ordersRepo.getOrdersByDateRange(
            from: _rangeFrom!, to: _rangeTo!, branchId: effectiveBranchId);
        await _expensesCubit.loadForDateRange(
            _rangeFrom!, _rangeTo!, branchId: effectiveBranchId);
      } else {
        orders = await ordersRepo.getOrdersByDate(
            date: _date, branchId: effectiveBranchId);
        await _expensesCubit.loadForDate(_date, branchId: effectiveBranchId);
      }

      final allStaff = await staffRepo.getAll();
      _orders  = orders;
      _drivers = allStaff
          .where((m) =>
              m.role == StaffRole.deliveryUser ||
              m.role == StaffRole.deliveryManager)
          .toList();
      _totalCogs = await _computeCogs(_orders);
      setState(() => _loading = false);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _loadZones() async {
    try {
      final rows = await Supabase.instance.client
          .from('delivery_zones')
          .select('id, name, name_ar, branch_id, user_paid_delivery_fees, delivery_fees_paid_to_driver')
          .eq('is_active', true)
          .order('name');
      _zones = (rows as List)
          .map((r) => _ZoneData.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }

  Future<double> _computeCogs(List<OrderModel> orders) async {
    final productIds = orders
        .where((o) => o.status != OrderStatus.cancelled)
        .expand((o) => o.items)
        .where((i) => i.productId != null)
        .map((i) => i.productId!)
        .toSet()
        .toList();
    if (productIds.isEmpty) { _cogsMap = {}; return 0; }
    try {
      final rows = await Supabase.instance.client
          .from('products')
          .select('id, cogs_percent')
          .inFilter('id', productIds);
      _cogsMap = {};
      for (final r in (rows as List)) {
        _cogsMap[r['id'] as String] =
            (r['cogs_percent'] as num?)?.toDouble() ?? 0;
      }
      double total = 0;
      for (final o in orders.where((o) => o.status != OrderStatus.cancelled)) {
        for (final item in o.items) {
          if (item.productId != null) {
            total += item.subtotal * (_cogsMap[item.productId] ?? 0) / 100;
          }
        }
      }
      return total;
    } catch (_) { _cogsMap = {}; return 0; }
  }

  // ── Updaters ───────────────────────────────────────────────────────────────

  Future<void> _updateDeposit(String orderId, double deposit) async {
    try {
      await DependencyInjector()
          .ordersRepository
          .updateOrderDeposit(orderId: orderId, deposit: deposit);
      setState(() {
        _orders = _orders
            .map((o) => o.id == orderId ? o.copyWith(deposit: deposit) : o)
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'),
              duration: const Duration(seconds: 2)));
      }
    }
  }

  Future<void> _updateMaradia(String orderId, double maradia) async {
    try {
      await DependencyInjector()
          .ordersRepository
          .updateOrderMaradia(orderId: orderId, maradia: maradia);
      setState(() {
        _orders = _orders
            .map((o) => o.id == orderId ? o.copyWith(maradia: maradia) : o)
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'),
              duration: const Duration(seconds: 2)));
      }
    }
  }

  Future<void> _updateZoneDeliveryCost(String zoneId, double cost) async {
    try {
      await Supabase.instance.client
          .from('delivery_zones')
          .update({'delivery_fees_paid_to_driver': cost})
          .eq('id', zoneId);
      // Backfill orders for this zone that were placed with no cost set
      await Supabase.instance.client
          .from('orders')
          .update({'driver_delivery_cost': cost})
          .eq('zone_id', zoneId)
          .eq('driver_delivery_cost', 0);
      setState(() {
        _zones = _zones
            .map((z) => z.id == zoneId ? z.copyWith(deliveryFeesPaidToDriver: cost) : z)
            .toList();
        _orders = _orders
            .map((o) => o.zoneId == zoneId && o.zoneDeliveryFee == 0
                ? o.copyWith(zoneDeliveryFee: cost)
                : o)
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'),
              duration: const Duration(seconds: 2)));
      }
    }
  }

  // ── Date helpers ───────────────────────────────────────────────────────────

  String get _dateLabel {
    final fmt = DateFormat('dd MMM yyyy');
    if (_isRangeMode && _rangeFrom != null && _rangeTo != null) {
      if (_rangeFrom == _rangeTo) return fmt.format(_rangeFrom!);
      return '${fmt.format(_rangeFrom!)} – ${fmt.format(_rangeTo!)}';
    }
    return fmt.format(_date);
  }

  Future<void> _pickRange() async {
    final initial = _isRangeMode && _rangeFrom != null && _rangeTo != null
        ? DateTimeRange(start: _rangeFrom!, end: _rangeTo!)
        : DateTimeRange(start: _date, end: _date);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: initial,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: AppColors.primaryDeep, onPrimary: Colors.white)),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _isRangeMode = true;
        _rangeFrom = picked.start;
        _rangeTo   = picked.end;
      });
      _loadAll();
    }
  }

  // ── Computed totals ────────────────────────────────────────────────────────

  List<OrderModel> get _active =>
      _orders.where((o) => o.status != OrderStatus.cancelled).toList();

  double get _totalSales    => _active.fold(0.0, (s, o) => s + o.totalPrice);
  double get _totalDelivery => _active.fold(0.0, (s, o) => s + o.userPaidDeliveryFees);
  double get _netSales      => _totalSales - _totalDelivery;

  List<_DriverStat> get _driverStats {
    return _drivers.map((driver) {
      final all  = _orders.where((o) => o.driverId == driver.id).toList();
      final cash = all
          .where((o) => o.status != OrderStatus.cancelled && o.isCash)
          .toList();
      final ip = all
          .where((o) => o.status != OrderStatus.cancelled && !o.isCash)
          .toList();
      final cashVal    = cash.fold(0.0, (s, o) => s + o.amountDue);
      final ipVal      = ip.fold(0.0, (s, o) => s + o.amountDue);
      final active     = all.where((o) => o.status != OrderStatus.cancelled);
      final dep        = active.fold(0.0, (s, o) => s + o.deposit);
      final actualCost = active.fold(0.0, (s, o) => s + _effectiveCost(o));
      final maradia    = active.fold(0.0, (s, o) => s + o.maradia);
      return _DriverStat(
        driver: driver, orders: all,
        cashCount: cash.length, cashVal: cashVal,
        ipCount: ip.length,    ipVal: ipVal,
        actualCost: actualCost, maradia: maradia,
        deposits: dep,
        owes: cashVal - actualCost - maradia,
      );
    }).where((s) => s.orders.isNotEmpty).toList();
  }

  double get _totalCash      => _driverStats.fold(0.0, (s, d) => s + d.cashVal);
  double get _totalInstapay  => _driverStats.fold(0.0, (s, d) => s + d.ipVal);
  double get _totalDeposits  => _driverStats.fold(0.0, (s, d) => s + d.deposits);
  double get _totalOwes      => _driverStats.fold(0.0, (s, d) => s + d.owes);
  double get _totalMaradia   => _driverStats.fold(0.0, (s, d) => s + d.maradia);

  /// Effective driver cost for [o]: stored value if non-zero, else current zone cost.
  double _effectiveCost(OrderModel o) {
    if (o.zoneDeliveryFee > 0) return o.zoneDeliveryFee;
    final zd = _zones.where((z) => z.id == o.zoneId).firstOrNull
            ?? _zones.where((z) => z.name.toLowerCase() == (o.zoneName?.toLowerCase() ?? '')).firstOrNull;
    return zd?.deliveryFeesPaidToDriver ?? 0;
  }

  // build a name→_ZoneData lookup (checks both name and name_ar)
  Map<String, _ZoneData> get _zoneByName {
    final m = <String, _ZoneData>{};
    for (final z in _zones) {
      m[z.name.toLowerCase()] = z;
      if (z.nameAr != null) m[z.nameAr!] = z;
    }
    return m;
  }

  List<_ZoneStat> get _zoneStats {
    final lookup = _zoneByName;
    final Map<String, List<OrderModel>> byZone = {};
    for (final o in _active) {
      final key = (o.zoneName?.trim().isNotEmpty == true) ? o.zoneName! : '—';
      byZone.putIfAbsent(key, () => []).add(o);
    }
    final stats = byZone.entries.map((e) {
      final zd         = lookup[e.key.toLowerCase()] ?? lookup[e.key];
      final custFees   = e.value.fold(0.0, (s, o) => s + o.userPaidDeliveryFees);
      final bizCost    = e.value.fold(0.0, (s, o) => s + _effectiveCost(o));
      final totalValue = e.value.fold(0.0, (s, o) => s + o.totalPrice);
      double cogs = 0;
      for (final o in e.value) {
        for (final item in o.items) {
          if (item.productId != null) {
            cogs += item.subtotal * (_cogsMap[item.productId] ?? 0) / 100;
          }
        }
      }
      return _ZoneStat(
        name: e.key, zoneId: zd?.id,
        count: e.value.length,
        custFees: custFees,
        bizCost: bizCost,
        totalValue: totalValue,
        cogs: cogs,
      );
    }).toList();
    stats.sort((a, b) => b.count.compareTo(a.count));
    return stats;
  }

  double get _totalDeliveryCost =>
      _zoneStats.fold(0.0, (s, z) => s + z.bizCost);

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider.value(
      value: _expensesCubit,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: AppColors.primaryDeep,
              foregroundColor: Colors.white,
              title: Text(
                'Reports · التقارير',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800, fontSize: 16),
              ),
              actions: [
                TextButton.icon(
                  onPressed: _isRangeMode
                      ? () {
                          setState(() {
                            _isRangeMode = false;
                            final n = DateTime.now();
                            _date = DateTime(n.year, n.month, n.day);
                          });
                          _loadAll();
                        }
                      : _pickRange,
                  icon: Icon(
                    _isRangeMode
                        ? Icons.today_outlined
                        : Icons.date_range_outlined,
                    size: 16,
                    color: Colors.white70,
                  ),
                  label: Text(
                    _isRangeMode ? l10n.reportsModeSingleDay : l10n.reportsModeDateRange,
                    style:
                        GoogleFonts.nunito(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(_branches.isNotEmpty ? 116 : 90),
                child: Column(
                  children: [
                    if (!_isRangeMode)
                      _DateBar(
                        l10n: l10n,
                        date: _date,
                        onPrev: () {
                          setState(() =>
                              _date = _date.subtract(const Duration(days: 1)));
                          _loadAll();
                        },
                        onNext: () {
                          setState(
                              () => _date = _date.add(const Duration(days: 1)));
                          _loadAll();
                        },
                        onPick: (d) {
                          setState(() => _date = d);
                          _loadAll();
                        },
                      )
                    else
                      _RangeBar(l10n: l10n, label: _dateLabel, onTap: _pickRange),
                    if (_branches.isNotEmpty)
                      _BranchFilterBar(
                        branches: _branches,
                        selectedId: _selectedBranchId,
                        onChanged: (id) {
                          setState(() => _selectedBranchId = id);
                          _loadAll();
                        },
                      ),
                    TabBar(
                      controller: _tabs,
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white54,
                      labelStyle: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700, fontSize: 13),
                      unselectedLabelStyle: GoogleFonts.nunito(
                          fontWeight: FontWeight.w500, fontSize: 13),
                      tabs: [
                        Tab(icon: const Icon(Icons.bar_chart_rounded, size: 16),
                            text: l10n.reportsTabSummary),
                        Tab(icon: const Icon(Icons.delivery_dining_rounded, size: 16),
                            text: l10n.reportsTabDrivers),
                        Tab(icon: const Icon(Icons.receipt_long_outlined, size: 16),
                            text: l10n.reportsTabExpenses),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!,
                              style: GoogleFonts.nunito(color: Colors.red)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                              onPressed: _loadAll,
                              child: Text(l10n.reportsRetry)),
                        ],
                      ),
                    )
                  : BlocBuilder<ExpensesCubit, ExpensesState>(
                      builder: (ctx, expState) => TabBarView(
                        controller: _tabs,
                        children: [
                          _SummaryTab(
                            l10n:            l10n,
                            totalSales:      _totalSales,
                            totalDelivery:   _totalDelivery,
                            netSales:        _netSales,
                            totalCogs:       _totalCogs,
                            totalCash:       _totalCash,
                            totalInstapay:   _totalInstapay,
                            totalDeposits:   _totalDeposits,
                            totalOwes:       _totalOwes,
                            totalMaradia:    _totalMaradia,
                            totalExpenses:   expState.total,
                            totalDeliveryCost: _totalDeliveryCost,
                            driverStats:     _driverStats,
                            zoneStats:       _zoneStats,
                            zones:           _zones,
                            orders:          _active,
                            onUpdateZoneDeliveryCost: _updateZoneDeliveryCost,
                            onUpdateDeposit: _updateDeposit,
                            onUpdateMaradia: _updateMaradia,
                          ),
                          _DriversTab(
                            l10n:            l10n,
                            drivers:         _drivers,
                            orders:          _orders,
                            zones:           _zones,
                            onUpdateDeposit: _updateDeposit,
                            onUpdateMaradia: _updateMaradia,
                          ),
                          _ExpensesTab(
                            l10n:     l10n,
                            isRange:  _isRangeMode,
                            date:     _date,
                            branchId: widget.branchId,
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}

// ── Summary Tab ────────────────────────────────────────────────────────────────

class _SummaryTab extends StatelessWidget {
  const _SummaryTab({
    required this.l10n,
    required this.totalSales,
    required this.totalDelivery,
    required this.netSales,
    required this.totalCogs,
    required this.totalCash,
    required this.totalInstapay,
    required this.totalDeposits,
    required this.totalOwes,
    required this.totalMaradia,
    required this.totalExpenses,
    required this.totalDeliveryCost,
    required this.driverStats,
    required this.zoneStats,
    required this.zones,
    required this.orders,
    required this.onUpdateZoneDeliveryCost,
    required this.onUpdateDeposit,
    required this.onUpdateMaradia,
  });

  final AppLocalizations l10n;
  final double totalSales;
  final double totalDelivery;
  final double netSales;
  final double totalCogs;
  final double totalCash;
  final double totalInstapay;
  final double totalDeposits;
  final double totalOwes;
  final double totalMaradia;
  final double totalExpenses;
  final double totalDeliveryCost;
  final List<_DriverStat> driverStats;
  final List<_ZoneStat> zoneStats;
  final List<_ZoneData> zones;
  final List<OrderModel> orders;
  final Future<void> Function(String zoneId, double cost) onUpdateZoneDeliveryCost;
  final Future<void> Function(String orderId, double deposit) onUpdateDeposit;
  final Future<void> Function(String orderId, double maradia) onUpdateMaradia;

  static String _egp(double v) => 'EGP ${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final grossProfit = netSales - totalCogs;
    final netCash     = totalOwes - totalExpenses;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Income ────────────────────────────────────────────────────────
          _SectionTitle(l10n.reportsIncomeTitle),
          const SizedBox(height: 10),
          Wrap(spacing: 10, runSpacing: 10, children: [
            _KpiCard(label: l10n.reportsTotalSales,
                value: _egp(totalSales), color: AppColors.primaryDeep,
                icon: Icons.bar_chart_rounded),
            _KpiCard(label: l10n.reportsDeliveryFees,
                value: _egp(totalDelivery), color: Colors.amber.shade700,
                icon: Icons.local_shipping_outlined),
            _KpiCard(label: l10n.reportsDeliveryCost,
                value: _egp(totalDeliveryCost), color: Colors.red.shade400,
                icon: Icons.local_shipping_rounded),
            _KpiCard(label: l10n.reportsNetSales,
                value: _egp(netSales), color: Colors.teal,
                icon: Icons.trending_up_rounded),
            _KpiCard(label: l10n.reportsTotalCogs,
                value: _egp(totalCogs), color: Colors.deepOrange,
                icon: Icons.inventory_2_outlined),
            _KpiCard(
              label: l10n.reportsGrossProfit,
              value: '${_egp(grossProfit.abs())}${grossProfit < 0 ? ' ${l10n.reportsLoss}' : ''}',
              color: grossProfit >= 0 ? Colors.green : Colors.red,
              icon: Icons.account_balance_outlined,
              highlighted: true,
            ),
          ]),

          const SizedBox(height: 24),

          // ── Cash Flow ─────────────────────────────────────────────────────
          _SectionTitle(l10n.reportsCashFlowTitle),
          const SizedBox(height: 10),
          Wrap(spacing: 10, runSpacing: 10, children: [
            _KpiCard(label: l10n.reportsCashSales,
                value: _egp(totalCash), color: Colors.green,
                icon: Icons.payments_outlined),
            _KpiCard(label: l10n.reportsInstapay,
                value: _egp(totalInstapay), color: Colors.indigo,
                icon: Icons.account_balance_wallet_outlined),
            if (totalDeposits > 0)
              _KpiCard(label: l10n.reportsDepositsPaid,
                  value: _egp(totalDeposits), color: Colors.teal,
                  icon: Icons.savings_outlined),
            _KpiCard(label: l10n.reportsDriversOwe,
                value: _egp(totalOwes), color: Colors.amber.shade700,
                icon: Icons.people_outlined),
            if (totalMaradia > 0)
              _KpiCard(
                label: 'إجمالي المراضية\nTotal Maradia',
                value: _egp(totalMaradia),
                color: Colors.orange.shade700,
                icon: Icons.handshake_outlined,
              ),
            _KpiCard(label: l10n.reportsTotalExpenses,
                value: _egp(totalExpenses), color: Colors.orange,
                icon: Icons.receipt_outlined),
            _KpiCard(
              label: l10n.reportsNetCash,
              value: '${_egp(netCash.abs())}${netCash < 0 ? ' ${l10n.reportsDeficit}' : ''}',
              color: netCash >= 0 ? Colors.green : Colors.red,
              icon: Icons.savings_outlined,
              highlighted: true,
            ),
          ]),

          const SizedBox(height: 24),

          // ── Driver accounts ───────────────────────────────────────────────
          _SectionTitle(l10n.reportsDriverAccountsTitle),
          const SizedBox(height: 10),
          if (driverStats.isEmpty)
            _EmptyState(l10n.reportsNoAssignedOrders)
          else
            _DriverTable(stats: driverStats),

          const SizedBox(height: 24),

          // ── Zone accounts ─────────────────────────────────────────────────
          _SectionTitle(l10n.reportsZoneAccountsTitle),
          const SizedBox(height: 10),
          if (zoneStats.isEmpty)
            _EmptyState(l10n.reportsNoZoneData)
          else
            _ZoneTable(
              l10n: l10n,
              stats: zoneStats,
              zones: zones,
              onEditCost: onUpdateZoneDeliveryCost,
            ),

          const SizedBox(height: 24),

          // ── All Orders ────────────────────────────────────────────────────
          Row(
            children: [
              _SectionTitle(l10n.reportsAllOrdersTitle),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryDeep.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${orders.length}',
                    style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDeep)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (orders.isEmpty)
            _EmptyState(l10n.reportsNoOrders)
          else
            _OrdersTable(
              orders: orders,
              zones: zones,
              onUpdateDeposit: onUpdateDeposit,
              onUpdateMaradia: onUpdateMaradia,
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Driver Table ──────────────────────────────────────────────────────────────

class _DriverTable extends StatelessWidget {
  const _DriverTable({required this.stats});
  final List<_DriverStat> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: Colors.grey.shade700),
          dataTextStyle: GoogleFonts.nunito(fontSize: 12),
          columnSpacing: 14,
          columns: const [
            DataColumn(label: Text('الطيار\nDriver')),
            DataColumn(label: Text('الطلبات\nOrders'), numeric: true),
            DataColumn(label: Text('كاش\nCash #'), numeric: true),
            DataColumn(label: Text('قيمة كاش\nCash EGP'), numeric: true),
            DataColumn(label: Text('عربون\nDeposit'), numeric: true),
            DataColumn(label: Text('انستاباي\nInstapay #'), numeric: true),
            DataColumn(label: Text('قيمة IP\nIP EGP'), numeric: true),
            DataColumn(label: Text('تكلفة فعلية\nActual'), numeric: true),
            DataColumn(label: Text('مراضية\nMaradia'), numeric: true),
            DataColumn(label: Text('المستحق\nOwes'), numeric: true),
          ],
          rows: stats.map((d) {
            final owesColor = d.owes >= 0 ? Colors.green : Colors.red;
            return DataRow(cells: [
              DataCell(Text(d.driver.name,
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700))),
              DataCell(Text(d.orders.length.toString())),
              DataCell(Text(d.cashCount.toString())),
              DataCell(Text(d.cashVal.toStringAsFixed(0))),
              DataCell(Text(
                d.deposits > 0 ? d.deposits.toStringAsFixed(0) : '—',
                style: GoogleFonts.nunito(
                    color: d.deposits > 0 ? Colors.teal : Colors.grey.shade400),
              )),
              DataCell(Text(d.ipCount.toString())),
              DataCell(Text(d.ipVal.toStringAsFixed(0))),
              DataCell(Text(
                d.actualCost > 0 ? d.actualCost.toStringAsFixed(0) : '—',
                style: GoogleFonts.nunito(color: Colors.red.shade400),
              )),
              DataCell(Text(
                d.maradia > 0 ? d.maradia.toStringAsFixed(0) : '—',
                style: GoogleFonts.nunito(color: Colors.orange.shade700),
              )),
              DataCell(Text(d.owes.toStringAsFixed(0),
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700, color: owesColor))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

// ── Zone Table ────────────────────────────────────────────────────────────────

class _ZoneTable extends StatelessWidget {
  const _ZoneTable({
    required this.l10n,
    required this.stats,
    required this.zones,
    required this.onEditCost,
  });
  final AppLocalizations l10n;
  final List<_ZoneStat> stats;
  final List<_ZoneData> zones;
  final Future<void> Function(String zoneId, double cost) onEditCost;

  void _showEditDialog(BuildContext context, _ZoneStat stat) {
    if (stat.zoneId == null) return;
    final currentZone = zones.firstWhere((z) => z.id == stat.zoneId,
        orElse: () => _ZoneData(
            id: '', name: stat.name, userPaidDeliveryFees: 0, deliveryFeesPaidToDriver: 0));
    final ctrl = TextEditingController(
        text: currentZone.deliveryFeesPaidToDriver > 0
            ? currentZone.deliveryFeesPaidToDriver.toStringAsFixed(2)
            : '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${l10n.reportsDeliveryCost} · ${stat.name}',
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800, fontSize: 14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.reportsCustomerFee}: EGP ${currentZone.userPaidDeliveryFees.toStringAsFixed(0)}',
              style: GoogleFonts.nunito(
                  fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.reportsSetDeposit,
                labelStyle: GoogleFonts.nunito(fontSize: 12),
                prefixText: 'EGP ',
                border: const OutlineInputBorder(),
              ),
              style: GoogleFonts.nunito(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.reportsCancel, style: GoogleFonts.nunito(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDeep,
                foregroundColor: Colors.white),
            onPressed: () {
              final v = double.tryParse(ctrl.text) ?? 0;
              Navigator.pop(context);
              onEditCost(stat.zoneId!, v);
            },
            child: Text(l10n.reportsSave,
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Totals row
    final totOrders     = stats.fold(0, (s, z) => s + z.count);
    final totCustFees   = stats.fold(0.0, (s, z) => s + z.custFees);
    final totBizCost    = stats.fold(0.0, (s, z) => s + z.bizCost);
    final totOrderValue = stats.fold(0.0, (s, z) => s + z.totalValue);
    final totCogs       = stats.fold(0.0, (s, z) => s + z.cogs);
    final totAvg        = totOrders > 0 ? totOrderValue / totOrders : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: Colors.grey.shade700),
          dataTextStyle: GoogleFonts.nunito(fontSize: 12),
          columnSpacing: 14,
          columns: [
            DataColumn(label: Text(l10n.reportsZoneLabel)),
            DataColumn(label: Text(l10n.reportsOrdersLabel), numeric: true),
            DataColumn(label: const Text('Order Value\nقيمة الطلبات'), numeric: true),
            DataColumn(label: const Text('Avg Order\nمتوسط'), numeric: true),
            DataColumn(label: Text(l10n.reportsCustFeeLabel), numeric: true),
            DataColumn(label: Text(l10n.reportsActualCostLabel), numeric: true),
            DataColumn(label: const Text('COGS\nالتكلفة'), numeric: true),
            DataColumn(label: Text(l10n.reportsEditLabel)),
          ],
          rows: [
            ...stats.map((z) {
              return DataRow(cells: [
                DataCell(Text(z.name,
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700))),
                DataCell(Text('${z.count}')),
                DataCell(Text(z.totalValue.toStringAsFixed(0),
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w600))),
                DataCell(Text(z.avgValue.toStringAsFixed(0),
                    style: GoogleFonts.nunito(color: Colors.teal.shade700))),
                DataCell(Text(z.custFees.toStringAsFixed(0))),
                DataCell(
                  z.bizCost > 0
                      ? Text(z.bizCost.toStringAsFixed(0),
                          style: GoogleFonts.nunito(color: Colors.red.shade400))
                      : Text(z.zoneId != null ? l10n.reportsSetCost : '—',
                          style: GoogleFonts.nunito(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                              fontStyle: FontStyle.italic)),
                ),
                DataCell(
                  z.cogs > 0
                      ? Text(z.cogs.toStringAsFixed(0),
                          style: GoogleFonts.nunito(color: Colors.deepOrange))
                      : Text('—',
                          style: GoogleFonts.nunito(color: Colors.grey.shade300)),
                ),
                DataCell(
                  z.zoneId != null
                      ? GestureDetector(
                          onTap: () => _showEditDialog(context, z),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDeep
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(Icons.edit_outlined,
                                size: 14, color: AppColors.primaryDeep),
                          ),
                        )
                      : Text('—',
                          style: GoogleFonts.nunito(color: Colors.grey.shade400)),
                ),
              ]);
            }),
            // Totals row
            DataRow(
              color: WidgetStateProperty.all(AppColors.primaryDeep.withValues(alpha: 0.06)),
              cells: [
                DataCell(Text(l10n.reportsTotal,
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w800))),
                DataCell(Text('$totOrders',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w800))),
                DataCell(Text(totOrderValue.toStringAsFixed(0),
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w800))),
                DataCell(Text(totAvg.toStringAsFixed(0),
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        color: Colors.teal.shade700))),
                DataCell(Text(totCustFees.toStringAsFixed(0),
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w800))),
                DataCell(Text(totBizCost.toStringAsFixed(0),
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        color: Colors.red.shade400))),
                DataCell(Text(totCogs.toStringAsFixed(0),
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        color: Colors.deepOrange))),
                const DataCell(SizedBox.shrink()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Orders Table ──────────────────────────────────────────────────────────────

class _OrdersTable extends StatelessWidget {
  const _OrdersTable({
    required this.orders,
    required this.zones,
    required this.onUpdateDeposit,
    required this.onUpdateMaradia,
  });
  final List<OrderModel> orders;
  final List<_ZoneData> zones;
  final Future<void> Function(String orderId, double deposit) onUpdateDeposit;
  final Future<void> Function(String orderId, double maradia) onUpdateMaradia;

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:        return Colors.amber;
      case OrderStatus.confirmed:      return Colors.blue;
      case OrderStatus.preparing:      return Colors.deepOrange;
      case OrderStatus.prepared:       return Colors.teal;
      case OrderStatus.outForDelivery: return Colors.purple;
      case OrderStatus.delivered:      return Colors.green;
      case OrderStatus.cancelled:      return Colors.red;
      case OrderStatus.rejected:       return Colors.deepOrange;
    }
  }

  void _showEditDialog(
    BuildContext context,
    OrderModel order, {
    required bool isDeposit,
  }) {
    final initial = isDeposit ? order.deposit : order.maradia;
    final ctrl = TextEditingController(
        text: initial > 0 ? initial.toStringAsFixed(2) : '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          isDeposit ? 'عربون · Deposit' : 'مراضية · Maradia',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: 'EGP ',
            border: const OutlineInputBorder(),
            labelStyle: GoogleFonts.nunito(fontSize: 12),
          ),
          style: GoogleFonts.nunito(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.nunito(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDeep,
                foregroundColor: Colors.white),
            onPressed: () {
              final v = double.tryParse(ctrl.text) ?? 0;
              Navigator.pop(context);
              if (isDeposit) {
                onUpdateDeposit(order.id, v);
              } else {
                onUpdateMaradia(order.id, v);
              }
            },
            child: Text('Save', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: Colors.grey.shade700),
          dataTextStyle: GoogleFonts.nunito(fontSize: 11),
          columnSpacing: 12,
          dataRowMinHeight: 36,
          dataRowMaxHeight: 52,
          columns: const [
            DataColumn(label: Text('#'), numeric: true),
            DataColumn(label: Text('رقم الطلب\nOrder #')),
            DataColumn(label: Text('السعر\nPrice'), numeric: true),
            DataColumn(label: Text('عربون\nDeposit'), numeric: true),
            DataColumn(label: Text('مراضية\nMaradia'), numeric: true),
            DataColumn(label: Text('المنطقة\nZone')),
            DataColumn(label: Text('رسوم التوصيل\nCust Fee'), numeric: true),
            DataColumn(label: Text('تكلفة التوصيل\nActual Cost'), numeric: true),
            DataColumn(label: Text('طريقة الدفع\nPayment')),
            DataColumn(label: Text('الطيار\nDriver')),
            DataColumn(label: Text('الحالة\nStatus')),
            DataColumn(label: Text('ملاحظات\nNotes')),
          ],
          rows: orders.asMap().entries.map((entry) {
            final idx = entry.key;
            final o   = entry.value;
            final sc  = _statusColor(o.status);
            final isCancelled = o.status == OrderStatus.cancelled;
            final zd  = zones.where((z) => z.id == o.zoneId).firstOrNull
                     ?? zones.where((z) => z.name.toLowerCase() == (o.zoneName?.toLowerCase() ?? '')).firstOrNull;
            final effectiveDriverCost = o.zoneDeliveryFee > 0 ? o.zoneDeliveryFee : (zd?.deliveryFeesPaidToDriver ?? 0);

            return DataRow(
              color: WidgetStateProperty.resolveWith((states) {
                if (isCancelled) return Colors.red.withValues(alpha: 0.04);
                return idx.isEven ? Colors.white : Colors.grey.shade50;
              }),
              cells: [
                DataCell(Text('${idx + 1}',
                    style: GoogleFonts.nunito(
                        color: Colors.grey.shade400, fontSize: 10))),
                DataCell(
                  Text(
                    '#${o.id.substring(0, 6).toUpperCase()}',
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700, fontSize: 11,
                        color: isCancelled ? Colors.grey : AppColors.textDark),
                  ),
                ),
                DataCell(Text(
                  o.totalPrice.toStringAsFixed(0),
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      color: isCancelled ? Colors.grey : AppColors.textDark),
                )),
                // Deposit — tappable to edit
                DataCell(
                  GestureDetector(
                    onTap: () => _showEditDialog(context, o, isDeposit: true),
                    child: o.deposit > 0
                        ? Text(o.deposit.toStringAsFixed(0),
                            style: GoogleFonts.nunito(
                                color: Colors.teal.shade700,
                                fontWeight: FontWeight.w600))
                        : Icon(Icons.add_circle_outline,
                            size: 14, color: Colors.grey.shade300),
                  ),
                ),
                // Maradia — tappable to edit
                DataCell(
                  GestureDetector(
                    onTap: () => _showEditDialog(context, o, isDeposit: false),
                    child: o.maradia > 0
                        ? Text(o.maradia.toStringAsFixed(0),
                            style: GoogleFonts.nunito(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w600))
                        : Icon(Icons.add_circle_outline,
                            size: 14, color: Colors.grey.shade300),
                  ),
                ),
                DataCell(
                  o.zoneName != null
                      ? Text(o.zoneName!,
                          style: GoogleFonts.nunito(fontSize: 11))
                      : Text('—',
                          style: GoogleFonts.nunito(
                              color: Colors.grey.shade300)),
                ),
                DataCell(Text(
                  o.userPaidDeliveryFees > 0
                      ? o.userPaidDeliveryFees.toStringAsFixed(0)
                      : '—',
                  style: GoogleFonts.nunito(
                      color: Colors.amber.shade700,
                      fontWeight: FontWeight.w600),
                )),
                DataCell(
                  effectiveDriverCost > 0
                      ? Text(effectiveDriverCost.toStringAsFixed(0),
                          style: GoogleFonts.nunito(
                              color: Colors.red.shade400,
                              fontWeight: FontWeight.w600))
                      : Text('—',
                          style: GoogleFonts.nunito(
                              color: Colors.grey.shade300)),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (o.isCash ? Colors.green : Colors.indigo)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      o.isCash ? 'Cash' : 'IP',
                      style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: o.isCash ? Colors.green : Colors.indigo),
                    ),
                  ),
                ),
                DataCell(Text(
                  o.driverName ?? '—',
                  style: GoogleFonts.nunito(
                      color: o.driverName != null
                          ? AppColors.textDark
                          : Colors.grey.shade300),
                )),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: sc.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      o.status.label,
                      style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: sc),
                    ),
                  ),
                ),
                DataCell(
                  o.notes != null && o.notes!.isNotEmpty
                      ? SizedBox(
                          width: 120,
                          child: Text(o.notes!,
                              style: GoogleFonts.nunito(
                                  fontSize: 10, color: Colors.grey.shade600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis))
                      : Text('—',
                          style: GoogleFonts.nunito(
                              color: Colors.grey.shade300)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Drivers Tab ───────────────────────────────────────────────────────────────

class _DriversTab extends StatefulWidget {
  const _DriversTab({
    required this.l10n,
    required this.drivers,
    required this.orders,
    required this.zones,
    required this.onUpdateDeposit,
    required this.onUpdateMaradia,
  });
  final AppLocalizations l10n;
  final List<StaffMember> drivers;
  final List<OrderModel> orders;
  final List<_ZoneData> zones;
  final Future<void> Function(String orderId, double deposit) onUpdateDeposit;
  final Future<void> Function(String orderId, double maradia) onUpdateMaradia;

  @override
  State<_DriversTab> createState() => _DriversTabState();
}

class _DriversTabState extends State<_DriversTab> {
  StaffMember? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.drivers.isNotEmpty) _selected = widget.drivers.first;
  }

  @override
  void didUpdateWidget(_DriversTab old) {
    super.didUpdateWidget(old);
    if (_selected != null &&
        !widget.drivers.any((d) => d.id == _selected!.id) &&
        widget.drivers.isNotEmpty) {
      _selected = widget.drivers.first;
    }
  }

  List<OrderModel> get _driverOrders => _selected == null
      ? []
      : widget.orders.where((o) => o.driverId == _selected!.id).toList();

  List<OrderModel> get _activeOrders =>
      _driverOrders.where((o) => o.status != OrderStatus.cancelled).toList();

  double get _cashVal =>
      _activeOrders.where((o) => o.isCash).fold(0.0, (s, o) => s + o.amountDue);

  // IP: deposit already received by us directly; amountDue = totalPrice - deposit flows via instapay
  double get _ipVal =>
      _activeOrders.where((o) => !o.isCash).fold(0.0, (s, o) => s + o.amountDue);

  // All deposits (cash + IP) go directly to us, not through driver
  double get _deposits =>
      _activeOrders.fold(0.0, (s, o) => s + o.deposit);

  double _effectiveCost(OrderModel o) {
    if (o.zoneDeliveryFee > 0) return o.zoneDeliveryFee;
    final zd = widget.zones.where((z) => z.id == o.zoneId).firstOrNull
            ?? widget.zones.where((z) => z.name.toLowerCase() == (o.zoneName?.toLowerCase() ?? '')).firstOrNull;
    return zd?.deliveryFeesPaidToDriver ?? 0;
  }

  double get _actualCost =>
      _activeOrders.fold(0.0, (s, o) => s + _effectiveCost(o));

  double get _maradia => _activeOrders.fold(0.0, (s, o) => s + o.maradia);
  double get _owes    => _cashVal - _actualCost - _maradia;
  int get _cashCount  => _activeOrders.where((o) => o.isCash).length;
  int get _ipCount    => _activeOrders.where((o) => !o.isCash).length;

  @override
  Widget build(BuildContext context) {
    if (widget.drivers.isEmpty) {
      return Center(
        child: Text(widget.l10n.reportsNoDrivers,
            style: GoogleFonts.nunito(color: Colors.grey, fontSize: 14)),
      );
    }

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.drivers.map((d) {
                final sel = _selected?.id == d.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(d.name,
                        style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight:
                                sel ? FontWeight.w700 : FontWeight.w500,
                            color: sel
                                ? Colors.white
                                : AppColors.textDark)),
                    selected: sel,
                    selectedColor: AppColors.primaryDeep,
                    backgroundColor: Colors.grey.shade100,
                    side: BorderSide(
                        color: sel
                            ? AppColors.primaryDeep
                            : Colors.grey.shade300),
                    onSelected: (_) => setState(() => _selected = d),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const Divider(height: 1),

        Expanded(
          child: _selected == null
              ? Center(
                  child: Text(widget.l10n.reportsSelectDriver,
                      style: GoogleFonts.nunito(color: Colors.grey)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Driver Owes Us ──────────────────────────────
                      _SectionTitle('يُسلّم الطيار · Driver Owes Us'),
                      const SizedBox(height: 8),
                      Wrap(spacing: 10, runSpacing: 10, children: [
                        _KpiCard(
                            label: widget.l10n.reportsTotalOrders,
                            value: '${_activeOrders.length}',
                            color: AppColors.primaryDeep,
                            icon: Icons.receipt_long_outlined),
                        _KpiCard(
                            label: 'كاش ($_cashCount طلب) · Cash Orders',
                            value: 'EGP ${_cashVal.toStringAsFixed(2)}',
                            color: Colors.green.shade700,
                            icon: Icons.payments_outlined,
                            highlighted: true),
                      ]),
                      const SizedBox(height: 16),

                      // ── Goes Directly To Us ──────────────────────────
                      _SectionTitle('مباشر لنا · Goes Directly To Us'),
                      const SizedBox(height: 8),
                      Wrap(spacing: 10, runSpacing: 10, children: [
                        if (_ipVal > 0)
                          _KpiCard(
                              label: 'انستاباي ($_ipCount) · Instapay → Us',
                              value: 'EGP ${_ipVal.toStringAsFixed(2)}',
                              color: Colors.indigo,
                              icon: Icons.account_balance_wallet_outlined),
                        if (_deposits > 0)
                          _KpiCard(
                              label: 'عربون · Deposits → Us',
                              value: 'EGP ${_deposits.toStringAsFixed(2)}',
                              color: Colors.teal,
                              icon: Icons.savings_outlined),
                        if (_ipVal == 0 && _deposits == 0)
                          Text('—', style: GoogleFonts.nunito(color: Colors.grey)),
                      ]),
                      const SizedBox(height: 16),

                      // ── We Owe Driver ────────────────────────────────
                      _SectionTitle('مستحق للطيار · We Owe Driver'),
                      const SizedBox(height: 8),
                      Wrap(spacing: 10, runSpacing: 10, children: [
                        if (_actualCost > 0)
                          _KpiCard(
                              label: 'تكلفة توصيل فعلية · Actual Delivery',
                              value: 'EGP ${_actualCost.toStringAsFixed(2)}',
                              color: Colors.red.shade400,
                              icon: Icons.local_shipping_rounded),
                        if (_maradia > 0)
                          _KpiCard(
                              label: 'مراضية · Maradia',
                              value: 'EGP ${_maradia.toStringAsFixed(2)}',
                              color: Colors.orange.shade700,
                              icon: Icons.handshake_outlined),
                        if (_actualCost == 0 && _maradia == 0)
                          Text('—', style: GoogleFonts.nunito(color: Colors.grey)),
                      ]),
                      const SizedBox(height: 16),

                      // ── Net ──────────────────────────────────────────
                      _KpiCard(
                        label: _owes >= 0
                            ? 'يُسلّم للمتجر · Driver Hands Back'
                            : 'ملزوم للطيار · We Owe Driver',
                        value: 'EGP ${_owes.abs().toStringAsFixed(2)}',
                        color: _owes >= 0 ? Colors.green : Colors.red,
                        icon: Icons.account_balance_outlined,
                        highlighted: true,
                      ),

                      const SizedBox(height: 20),
                      _SectionTitle('${widget.l10n.reportsOrdersTitle} (${_activeOrders.length})'),
                      const SizedBox(height: 10),

                      if (_activeOrders.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(widget.l10n.reportsNoAssignedOrders,
                                style: GoogleFonts.cairo(
                                    color: Colors.grey, fontSize: 14)),
                          ),
                        )
                      else
                        ..._activeOrders.map((o) => _DriverOrderCard(
                              l10n: widget.l10n,
                              order: o,
                              onUpdateDeposit: widget.onUpdateDeposit,
                              onUpdateMaradia: widget.onUpdateMaradia,
                            )),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Driver order card ─────────────────────────────────────────────────────────

class _DriverOrderCard extends StatelessWidget {
  const _DriverOrderCard({
    required this.l10n,
    required this.order,
    required this.onUpdateDeposit,
    required this.onUpdateMaradia,
  });
  final AppLocalizations l10n;
  final OrderModel order;
  final Future<void> Function(String, double) onUpdateDeposit;
  final Future<void> Function(String, double) onUpdateMaradia;

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:        return Colors.amber;
      case OrderStatus.confirmed:      return Colors.blue;
      case OrderStatus.preparing:      return Colors.deepOrange;
      case OrderStatus.prepared:       return Colors.teal;
      case OrderStatus.outForDelivery: return Colors.purple;
      case OrderStatus.delivered:      return Colors.green;
      case OrderStatus.cancelled:      return Colors.red;
      case OrderStatus.rejected:       return Colors.deepOrange;
    }
  }

  void _showEditDialog(BuildContext context, {required bool isDeposit}) {
    final initial = isDeposit ? order.deposit : order.maradia;
    final ctrl = TextEditingController(
        text: initial > 0 ? initial.toStringAsFixed(2) : '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          isDeposit ? '${l10n.reportsSetDeposit} · عربون' : 'مراضية · Maradia',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.reportsAmount,
            labelStyle: GoogleFonts.nunito(),
            prefixText: 'EGP ',
            border: const OutlineInputBorder(),
          ),
          style: GoogleFonts.nunito(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.reportsCancel,
                style: GoogleFonts.nunito(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: isDeposit ? Colors.teal : Colors.orange,
                foregroundColor: Colors.white),
            onPressed: () {
              final v = double.tryParse(ctrl.text) ?? 0;
              Navigator.pop(context);
              if (isDeposit) {
                onUpdateDeposit(order.id, v);
              } else {
                onUpdateMaradia(order.id, v);
              }
            },
            child: Text(l10n.reportsSave,
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = order.status == OrderStatus.cancelled;
    final sc = _statusColor(order.status);
    final dateFmt = DateFormat('dd MMM, hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: sc.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(
                  '#${order.orderNumber}',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color:
                          isCancelled ? Colors.grey : AppColors.textDark),
                ),
              ),
              _Badge(order.status.label, sc),
              const SizedBox(width: 6),
              _Badge(order.isCash ? 'Cash' : 'Instapay',
                  order.isCash ? Colors.green : Colors.indigo),
              const SizedBox(width: 8),
              Text(dateFmt.format(order.createdAt.toLocal()),
                  style: GoogleFonts.nunito(
                      fontSize: 10, color: Colors.grey)),
            ]),
            if (order.zoneName != null) ...[
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.location_on_outlined,
                    size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 3),
                Text(order.zoneName!,
                    style: GoogleFonts.nunito(
                        fontSize: 11, color: Colors.grey.shade600)),
              ]),
            ],
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.deposit > 0
                            ? '${l10n.reportsDue}: EGP ${order.amountDue.toStringAsFixed(2)}'
                            : 'EGP ${order.totalPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isCancelled
                                ? Colors.grey
                                : AppColors.textDark),
                      ),
                      if (order.deposit > 0)
                        Text(
                          '${l10n.reportsTotal} ${order.totalPrice.toStringAsFixed(2)}  ·  عربون ${order.deposit.toStringAsFixed(2)}',
                          style: GoogleFonts.nunito(
                              fontSize: 11,
                              color: Colors.teal.shade700,
                              fontWeight: FontWeight.w600),
                        ),
                      const SizedBox(height: 2),
                      Row(children: [
                        Icon(Icons.local_shipping_outlined,
                            size: 12, color: Colors.amber.shade700),
                        const SizedBox(width: 3),
                        Text(
                          'EGP ${order.userPaidDeliveryFees.toStringAsFixed(2)}',
                          style: GoogleFonts.nunito(
                              fontSize: 11,
                              color: Colors.amber.shade700,
                              fontWeight: FontWeight.w600),
                        ),
                      ]),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => _showEditDialog(context, isDeposit: true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: order.deposit > 0
                              ? Colors.teal.withValues(alpha: 0.08)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: order.deposit > 0
                                  ? Colors.teal.shade200
                                  : Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.savings_outlined,
                                size: 13,
                                color: order.deposit > 0
                                    ? Colors.teal
                                    : Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              order.deposit > 0
                                  ? 'عربون ${order.deposit.toStringAsFixed(0)}'
                                  : l10n.reportsSetDeposit,
                              style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: order.deposit > 0
                                      ? Colors.teal
                                      : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _showEditDialog(context, isDeposit: false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: order.maradia > 0
                              ? Colors.orange.withValues(alpha: 0.08)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: order.maradia > 0
                                  ? Colors.orange.shade200
                                  : Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.handshake_outlined,
                                size: 13,
                                color: order.maradia > 0
                                    ? Colors.orange.shade700
                                    : Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              order.maradia > 0
                                  ? 'مراضية ${order.maradia.toStringAsFixed(0)}'
                                  : 'مراضية',
                              style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: order.maradia > 0
                                      ? Colors.orange.shade700
                                      : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Expenses Tab ──────────────────────────────────────────────────────────────

class _ExpensesTab extends StatefulWidget {
  const _ExpensesTab({
    required this.l10n,
    required this.isRange,
    required this.date,
    this.branchId,
  });
  final AppLocalizations l10n;
  final bool isRange;
  final DateTime date;
  final String? branchId;

  @override
  State<_ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<_ExpensesTab> {
  void _showDialog(BuildContext ctx, ExpenseModel? existing) {
    final nameCtrl = TextEditingController(text: existing?.name);
    final valCtrl  = TextEditingController(
        text: existing != null ? existing.value.toStringAsFixed(2) : '');
    ExpenseType selectedType = existing?.type ?? ExpenseType.miscellaneous;

    showDialog(
      context: ctx,
      builder: (_) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: Text(
            existing == null ? widget.l10n.reportsAddExpense : widget.l10n.reportsEditExpense,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ExpenseType>(
                initialValue: selectedType,
                decoration: InputDecoration(
                  labelText: 'Type (النوع)',
                  labelStyle: GoogleFonts.nunito(),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                ),
                style: GoogleFonts.nunito(
                    fontSize: 13, color: Colors.black87),
                items: ExpenseType.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text('${t.labelAr} · ${t.labelEn}',
                              style: GoogleFonts.nunito(fontSize: 12)),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setDialogState(() => selectedType = v);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Description (البيان)',
                  labelStyle: GoogleFonts.nunito(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount (القيمة)',
                  labelStyle: GoogleFonts.nunito(),
                  prefixText: 'EGP ',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(widget.l10n.reportsCancel,
                  style: GoogleFonts.nunito(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDeep,
                  foregroundColor: Colors.white),
              onPressed: () {
                final name  = nameCtrl.text.trim();
                final value = double.tryParse(valCtrl.text) ?? 0;
                if (name.isEmpty || value <= 0) return;
                Navigator.pop(dialogCtx);
                if (existing == null) {
                  ctx.read<ExpensesCubit>().add(
                        name: name, value: value,
                        date: widget.date, type: selectedType,
                        branchId: widget.branchId,
                      );
                } else {
                  ctx.read<ExpensesCubit>().edit(
                        id: existing.id, name: name,
                        value: value, date: widget.date,
                        type: selectedType,
                      );
                }
              },
              child: Text(widget.l10n.reportsSave,
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  static String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<DateTime> _days(List<ExpenseModel> expenses) {
    return expenses
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b));
  }

  Map<ExpenseType, Map<String, double>> _pivot(List<ExpenseModel> expenses) {
    final result = <ExpenseType, Map<String, double>>{};
    for (final e in expenses) {
      result.putIfAbsent(e.type, () => <String, double>{});
      final key = _dayKey(e.date);
      result[e.type]![key] = (result[e.type]![key] ?? 0) + e.value;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpensesCubit, ExpensesState>(
      builder: (ctx, state) => widget.isRange
          ? _buildPivot(ctx, state.expenses)
          : _buildList(ctx, state),
    );
  }

  Widget _buildList(BuildContext ctx, ExpensesState state) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Text('Expenses · المصروفات',
                  style: GoogleFonts.nunito(
                      fontSize: 14, fontWeight: FontWeight.w800)),
              const Spacer(),
              if (state.expenses.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    'EGP ${state.total.toStringAsFixed(2)}',
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.orange.shade800),
                  ),
                ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text(widget.l10n.reportsAdd,
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDeep,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8)),
                onPressed: () => _showDialog(ctx, null),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        Expanded(
          child: state.status == ExpensesStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : state.expenses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(widget.l10n.reportsNoExpenses,
                              style: GoogleFonts.cairo(
                                  color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.expenses.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 6),
                      itemBuilder: (_, i) {
                        final e = state.expenses[i];
                        return _ExpenseRow(
                          l10n: widget.l10n,
                          expense: e,
                          onEdit: () => _showDialog(ctx, e),
                          onDelete: () =>
                              ctx.read<ExpensesCubit>().remove(e.id),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildPivot(BuildContext ctx, List<ExpenseModel> expenses) {
    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(widget.l10n.reportsNoExpenses,
                style:
                    GoogleFonts.nunito(color: Colors.grey, fontSize: 14)),
          ],
        ),
      );
    }

    final days       = _days(expenses);
    final pivot      = _pivot(expenses);
    final types      = ExpenseType.values.where((t) => pivot.containsKey(t)).toList();
    final grandTotal = expenses.fold(0.0, (s, e) => s + e.value);
    final dayFmt     = DateFormat('d/M');

    double rowTotal(ExpenseType t) =>
        expenses.where((e) => e.type == t).fold(0.0, (s, e) => s + e.value);
    double colTotal(DateTime d) {
      final k = _dayKey(d);
      return expenses
          .where((e) => _dayKey(e.date) == k)
          .fold(0.0, (s, e) => s + e.value);
    }

    const typeW  = 150.0;
    const cellW  = 72.0;
    const totalW = 90.0;
    const rowH   = 40.0;
    const headH  = 44.0;

    final cellStyle  = GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600);
    final totalStyle = GoogleFonts.nunito(
        fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryDeep);
    final grandStyle = GoogleFonts.nunito(
        fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white);

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            _SummaryChip(
                label: widget.l10n.reportsTotal,
                value: 'EGP ${grandTotal.toStringAsFixed(0)}',
                color: AppColors.primaryDeep),
            const SizedBox(width: 10),
            _SummaryChip(
                label: widget.l10n.reportsTypes,
                value: '${types.length}',
                color: Colors.teal),
            const SizedBox(width: 10),
            _SummaryChip(
                label: widget.l10n.reportsDays,
                value: '${days.length}',
                color: Colors.amber.shade700),
          ]),
        ),
        const Divider(height: 1),

        Expanded(
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: typeW, height: headH,
                      alignment: Alignment.centerLeft,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryDeep,
                        border: Border(
                            right: BorderSide(color: Colors.white24)),
                      ),
                      child: Text(widget.l10n.reportsTypeLabel,
                          style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                    ...days.map((d) => Container(
                          width: cellW, height: headH,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryDeep,
                            border: Border(
                                right:
                                    BorderSide(color: Colors.white24)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(dayFmt.format(d),
                                  style: GoogleFonts.nunito(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                              Text(DateFormat('EEE').format(d),
                                  style: GoogleFonts.nunito(
                                      fontSize: 9,
                                      color: Colors.white70)),
                            ],
                          ),
                        )),
                    Container(
                      width: totalW, height: headH,
                      alignment: Alignment.center,
                      color: AppColors.primaryMid,
                      child: Text(widget.l10n.reportsTotalHeader,
                          style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ),
                  ]),
                  const Divider(height: 1, color: Colors.grey),

                  ...types.asMap().entries.map((entry) {
                    final i    = entry.key;
                    final type = entry.value;
                    final data = pivot[type] ?? {};
                    return Container(
                      decoration: BoxDecoration(
                        color: i.isEven
                            ? Colors.white
                            : Colors.grey.shade50,
                        border: Border(
                            bottom: BorderSide(
                                color: Colors.grey.shade200)),
                      ),
                      child: Row(children: [
                        Container(
                          width: typeW, height: rowH,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12),
                          decoration: BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      color: Colors.grey.shade200))),
                          child: Text(
                              '${type.labelAr}\n${type.labelEn}',
                              style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ),
                        ...days.map((d) {
                          final val = data[_dayKey(d)] ?? 0;
                          return Container(
                            width: cellW, height: rowH,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: Colors.grey.shade200,
                                        width: 0.5))),
                            child: val > 0
                                ? Text(val.toStringAsFixed(0),
                                    style: cellStyle)
                                : Text('–',
                                    style: GoogleFonts.nunito(
                                        fontSize: 11,
                                        color: Colors.grey.shade300)),
                          );
                        }),
                        Container(
                          width: totalW, height: rowH,
                          alignment: Alignment.center,
                          color: AppColors.primaryMist,
                          child: Text(
                              rowTotal(type).toStringAsFixed(0),
                              style: totalStyle),
                        ),
                      ]),
                    );
                  }),

                  Container(
                    color: AppColors.primaryDeep.withValues(alpha: 0.9),
                    child: Row(children: [
                      Container(
                        width: typeW, height: rowH,
                        alignment: Alignment.centerLeft,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(widget.l10n.reportsTotal,
                            style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ),
                      ...days.map((d) {
                        final ct = colTotal(d);
                        return Container(
                          width: cellW, height: rowH,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      color: Colors.white24,
                                      width: 0.5))),
                          child: Text(
                              ct > 0 ? ct.toStringAsFixed(0) : '–',
                              style: grandStyle),
                        );
                      }),
                      Container(
                        width: totalW, height: rowH,
                        alignment: Alignment.center,
                        color: AppColors.primaryMid,
                        child: Text(grandTotal.toStringAsFixed(0),
                            style: grandStyle),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Expense row ───────────────────────────────────────────────────────────────

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({
    required this.l10n,
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });
  final AppLocalizations l10n;
  final ExpenseModel expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_outlined, size: 16, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.name,
                    style: GoogleFonts.nunito(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                Text(expense.type.labelAr,
                    style: GoogleFonts.nunito(
                        fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          Text('EGP ${expense.value.toStringAsFixed(2)}',
              style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange)),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 16),
            onPressed: onEdit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Colors.grey,
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 16),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(l10n.reportsDeleteExpense,
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
                content: Text('${l10n.reportsDeleteConfirm} "${expense.name}"?',
                    style: GoogleFonts.nunito()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.reportsCancel),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onDelete();
                    },
                    child: Text(l10n.reportsDelete,
                        style: GoogleFonts.nunito(color: Colors.red)),
                  ),
                ],
              ),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

// ── Shared helper widgets ─────────────────────────────────────────────────────

class _DateBar extends StatelessWidget {
  const _DateBar({
    required this.l10n,
    required this.date,
    required this.onPrev,
    required this.onNext,
    required this.onPick,
  });
  final AppLocalizations l10n;
  final DateTime date;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDeep.withValues(alpha: 0.7),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded,
                color: Colors.white70),
            onPressed: onPrev,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2024),
                lastDate:
                    DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) onPick(picked);
            },
            child: Text(
              DateFormat('dd MMM yyyy').format(date),
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.white),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded,
                color: Colors.white70),
            onPressed: onNext,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          TextButton(
            onPressed: () {
              final n = DateTime.now();
              onPick(DateTime(n.year, n.month, n.day));
            },
            child: Text(l10n.reportsToday,
                style: GoogleFonts.nunito(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _RangeBar extends StatelessWidget {
  const _RangeBar({
    required this.l10n,
    required this.label,
    required this.onTap,
  });
  final AppLocalizations l10n;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: AppColors.primaryDeep.withValues(alpha: 0.7),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.date_range_outlined,
                size: 14, color: Colors.white70),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white)),
            const Spacer(),
            Text(l10n.reportsChangeRange,
                style: GoogleFonts.nunito(
                    fontSize: 11, color: Colors.white60)),
          ],
        ),
      ),
    );
  }
}

class _BranchFilterBar extends StatelessWidget {
  const _BranchFilterBar({
    required this.branches,
    required this.selectedId,
    required this.onChanged,
  });
  final List<_BranchItem> branches;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      color: AppColors.primaryDeep.withValues(alpha: 0.6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            _chip('الكل · All', selectedId == null, () => onChanged(null)),
            ...branches.map((b) =>
                _chip(b.name, selectedId == b.id, () => onChanged(b.id))),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.primaryDeep : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.highlighted = false,
  });
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 165,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlighted ? color.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted
              ? color.withValues(alpha: 0.5)
              : Colors.grey.shade200,
          width: highlighted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: highlighted ? color : AppColors.textDark)),
          const SizedBox(height: 4),
          Text(label,
              style:
                  GoogleFonts.nunito(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(text,
      style: GoogleFonts.nunito(
          fontSize: 15, fontWeight: FontWeight.w800));
}

class _EmptyState extends StatelessWidget {
  const _EmptyState(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(text,
              style: GoogleFonts.nunito(color: Colors.grey)),
        ),
      );
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: GoogleFonts.nunito(
              fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.nunito(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600)),
          Text(value,
              style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color)),
        ],
      ),
    );
  }
}
