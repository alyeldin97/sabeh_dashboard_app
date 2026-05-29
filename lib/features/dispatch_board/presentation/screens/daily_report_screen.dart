import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/styling/colors.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import '../../../expenses/data/model/expense_model.dart' show ExpenseModel, ExpenseType;
import '../../../expenses/presentation/cubits/expenses_cubit.dart';
import '../../../expenses/presentation/cubits/expenses_state.dart';
import '../../../orders/data/model/order_model.dart';
import '../../../staff_mgmt/data/model/staff_member.dart';
import '../../../auth/data/model/staff_user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({
    super.key,
    required this.initialDate,
    this.branchId,
  });
  final DateTime initialDate;
  final String? branchId;

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  // Date state – single-day mode
  late DateTime _date;

  // Range mode
  bool _isRangeMode = false;
  DateTime? _rangeFrom;
  DateTime? _rangeTo;

  List<OrderModel> _orders = [];
  List<StaffMember> _drivers = [];
  bool _loading = false;
  String? _error;
  double _totalCogs = 0;

  late ExpensesCubit _expensesCubit;

  @override
  void initState() {
    super.initState();
    _date = DateTime(widget.initialDate.year, widget.initialDate.month,
        widget.initialDate.day);
    _rangeFrom = _date;
    _rangeTo = _date;
    _expensesCubit = ExpensesCubit(DependencyInjector().expensesRepo);
    _loadAll();
  }

  @override
  void dispose() {
    _expensesCubit.close();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
      _totalCogs = 0;
    });
    try {
      final ordersRepo = DependencyInjector().ordersRepository;
      final staffRepo  = DependencyInjector().staffRepository;

      final List<OrderModel> orders;
      if (_isRangeMode && _rangeFrom != null && _rangeTo != null) {
        orders = await ordersRepo.getOrdersByDateRange(
          from: _rangeFrom!,
          to: _rangeTo!,
          branchId: widget.branchId,
        );
      } else {
        orders = await ordersRepo.getOrdersByDate(
          date: _date,
          branchId: widget.branchId,
        );
      }

      final allStaff = await staffRepo.getAll();
      _orders = orders;
      _drivers = allStaff
          .where((m) =>
              m.role == StaffRole.deliveryUser ||
              m.role == StaffRole.deliveryManager)
          .toList();

      // Load expenses
      if (_isRangeMode && _rangeFrom != null && _rangeTo != null) {
        await _expensesCubit.loadForDateRange(
          _rangeFrom!,
          _rangeTo!,
          branchId: widget.branchId,
        );
      } else {
        await _expensesCubit.loadForDate(_date, branchId: widget.branchId);
      }

      // Compute COGS
      _totalCogs = await _computeCogs(_orders);

      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<double> _computeCogs(List<OrderModel> orders) async {
    final productIds = orders
        .where((o) => o.status != OrderStatus.cancelled)
        .expand((o) => o.items)
        .where((i) => i.productId != null)
        .map((i) => i.productId!)
        .toSet()
        .toList();
    if (productIds.isEmpty) return 0;

    try {
      final rows = await Supabase.instance.client
          .from('products')
          .select('id, cogs_percent')
          .inFilter('id', productIds);

      final cogsMap = <String, double>{};
      for (final r in (rows as List)) {
        final id  = r['id'] as String;
        final pct = (r['cogs_percent'] as num?)?.toDouble();
        if (pct != null) cogsMap[id] = pct;
      }

      double total = 0;
      for (final order in orders.where((o) => o.status != OrderStatus.cancelled)) {
        for (final item in order.items) {
          if (item.productId != null) {
            final pct = cogsMap[item.productId];
            if (pct != null) total += item.subtotal * pct / 100;
          }
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  // ── Per-driver stats ───────────────────────────────────────────────────────

  List<_DriverStats> get _driverStats {
    final stats = <_DriverStats>[];
    for (final driver in _drivers) {
      final driverOrders = _orders.where((o) => o.driverId == driver.id).toList();
      if (driverOrders.isEmpty) continue;

      final cashOrders = driverOrders
          .where((o) => o.status != OrderStatus.cancelled && o.isCash)
          .toList();
      final instapayOrders = driverOrders
          .where((o) => o.status != OrderStatus.cancelled && !o.isCash)
          .toList();
      final totalShipping  = driverOrders.fold(0.0, (s, o) => s + o.userPaidDeliveryFees);
      final totalDeposits  = cashOrders.fold(0.0, (s, o) => s + o.deposit);
      final cashValue      = cashOrders.fold(0.0, (s, o) => s + o.amountDue);
      final instapayValue  = instapayOrders.fold(0.0, (s, o) => s + o.totalPrice);

      stats.add(_DriverStats(
        driver:        driver,
        totalOrders:   driverOrders.length,
        cashCount:     cashOrders.length,
        cashValue:     cashValue,
        instapayCount: instapayOrders.length,
        instapayValue: instapayValue,
        totalShipping: totalShipping,
        totalDeposits: totalDeposits,
        driverOwes:    cashValue - totalShipping,
      ));
    }
    return stats;
  }

  List<OrderModel> get _unassigned =>
      _orders.where((o) => o.driverId == null).toList();

  // ── Totals ─────────────────────────────────────────────────────────────────

  List<OrderModel> get _activeOrders =>
      _orders.where((o) => o.status != OrderStatus.cancelled).toList();

  double get _totalSales =>
      _activeOrders.fold(0.0, (s, o) => s + o.totalPrice);

  double get _totalDeliveryFees =>
      _activeOrders.fold(0.0, (s, o) => s + o.userPaidDeliveryFees);

  double get _netSales => _totalSales - _totalDeliveryFees;

  double get _totalCash =>
      _driverStats.fold(0.0, (s, d) => s + d.cashValue);
  double get _totalInstapay =>
      _driverStats.fold(0.0, (s, d) => s + d.instapayValue);
  double get _totalDeposits =>
      _driverStats.fold(0.0, (s, d) => s + d.totalDeposits);
  double get _totalDriverOwes =>
      _driverStats.fold(0.0, (s, d) => s + d.driverOwes);

  // ── Helpers ────────────────────────────────────────────────────────────────

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
            primary: AppColors.primaryDeep,
            onPrimary: Colors.white,
          ),
        ),
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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy');

    return BlocProvider.value(
      value: _expensesCubit,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColors.primaryDeep,
          foregroundColor: Colors.white,
          title: Text(
            AppLocalizations.of(context)!.dailyReportTitle,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          ),
          actions: [
            Builder(builder: (ctx) {
              final l10n = AppLocalizations.of(ctx)!;
              return TextButton.icon(
                onPressed: () {
                  if (_isRangeMode) {
                    setState(() {
                      _isRangeMode = false;
                      _date = DateTime.now();
                      _date = DateTime(_date.year, _date.month, _date.day);
                    });
                    _loadAll();
                  } else {
                    _pickRange();
                  }
                },
                icon: Icon(
                  _isRangeMode ? Icons.today_outlined : Icons.date_range_outlined,
                  size: 16,
                  color: Colors.white70,
                ),
                label: Text(
                  _isRangeMode ? l10n.dailyReportSingleDay : l10n.dailyReportDateRange,
                  style: GoogleFonts.nunito(
                      color: Colors.white70, fontSize: 13),
                ),
              );
            }),
          ],
        ),
        body: Column(
          children: [
            // Date navigation
            if (!_isRangeMode)
              _DateNav(
                date: _date,
                fmt: dateFmt,
                onPrev: () {
                  setState(() =>
                      _date = _date.subtract(const Duration(days: 1)));
                  _loadAll();
                },
                onNext: () {
                  setState(() => _date = _date.add(const Duration(days: 1)));
                  _loadAll();
                },
                onPick: (d) {
                  setState(() => _date = d);
                  _loadAll();
                },
              )
            else
              _RangeBar(
                label: _dateLabel,
                onTap: _pickRange,
                onClear: () {
                  setState(() {
                    _isRangeMode = false;
                    _date = DateTime.now();
                    _date = DateTime(_date.year, _date.month, _date.day);
                  });
                  _loadAll();
                },
              ),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(_error!,
                              style: GoogleFonts.nunito(color: Colors.red)))
                      : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<ExpensesCubit, ExpensesState>(
      builder: (ctx, expState) {
        final totalExpenses = expState.total;
        final netCash       = _totalDriverOwes - totalExpenses;
        final grossProfit   = _netSales - _totalCogs;
        final netCashColor  = netCash >= 0 ? Colors.green : Colors.red;
        final grossColor    = grossProfit >= 0 ? Colors.green : Colors.red;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Income Summary Section ─────────────────────────────────
              Text(
                'Income Summary · ملخص الإيرادات',
                style: GoogleFonts.nunito(
                    fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _SummaryCard(
                    label: 'Total Sales\nإجمالي المبيعات',
                    value: 'EGP ${_totalSales.toStringAsFixed(2)}',
                    color: AppColors.primaryDeep,
                    icon: Icons.bar_chart_rounded,
                  ),
                  _SummaryCard(
                    label: 'Delivery Fees\nرسوم التوصيل',
                    value: 'EGP ${_totalDeliveryFees.toStringAsFixed(2)}',
                    color: Colors.amber.shade700,
                    icon: Icons.local_shipping_outlined,
                  ),
                  _SummaryCard(
                    label: 'Net Sales\nصافي المبيعات',
                    value: 'EGP ${_netSales.toStringAsFixed(2)}',
                    color: Colors.teal,
                    icon: Icons.trending_up_rounded,
                  ),
                  _SummaryCard(
                    label: 'Total COGS\nتكلفة البضاعة',
                    value: 'EGP ${_totalCogs.toStringAsFixed(2)}',
                    color: Colors.deepOrange,
                    icon: Icons.inventory_2_outlined,
                  ),
                  _SummaryCard(
                    label: 'Gross Profit\nالربح الإجمالي',
                    value: 'EGP ${grossProfit.abs().toStringAsFixed(2)}'
                        '${grossProfit < 0 ? ' (loss)' : ''}',
                    color: grossColor,
                    icon: Icons.account_balance_outlined,
                    highlighted: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Cash Flow Section ──────────────────────────────────────
              Text(
                'Cash Flow · التدفق النقدي',
                style: GoogleFonts.nunito(
                    fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _SummaryCard(
                    label: 'Total Cash Sales\nإجمالي مبيعات كاش',
                    value: 'EGP ${_totalCash.toStringAsFixed(2)}',
                    color: Colors.green,
                    icon: Icons.payments_outlined,
                  ),
                  _SummaryCard(
                    label: 'Total Instapay\nإجمالي إنستاباي',
                    value: 'EGP ${_totalInstapay.toStringAsFixed(2)}',
                    color: Colors.indigo,
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  if (_totalDeposits > 0)
                    _SummaryCard(
                      label: 'Deposits Paid\nمدفوع مقدم',
                      value: 'EGP ${_totalDeposits.toStringAsFixed(2)}',
                      color: Colors.teal,
                      icon: Icons.savings_outlined,
                    ),
                  _SummaryCard(
                    label: 'Drivers Owe\nالمستحق من الطيارين',
                    value: 'EGP ${_totalDriverOwes.toStringAsFixed(2)}',
                    color: Colors.amber.shade700,
                    icon: Icons.people_outlined,
                  ),
                  _SummaryCard(
                    label: 'Total Expenses\nإجمالي المصروفات',
                    value: 'EGP ${totalExpenses.toStringAsFixed(2)}',
                    color: Colors.orange,
                    icon: Icons.receipt_outlined,
                  ),
                  _SummaryCard(
                    label: 'Net Cash\nالصافي النقدي',
                    value: 'EGP ${netCash.abs().toStringAsFixed(2)}'
                        '${netCash < 0 ? ' (loss)' : ''}',
                    color: netCashColor,
                    icon: Icons.savings_outlined,
                    highlighted: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Driver accounts table ──────────────────────────────────
              Text(
                'Driver Accounts · حسابات الطيارين',
                style: GoogleFonts.nunito(
                    fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),

              if (_driverStats.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      AppLocalizations.of(context)!.dailyReportNoAssigned,
                      style: GoogleFonts.nunito(color: Colors.grey),
                    ),
                  ),
                )
              else
                _DriverTable(stats: _driverStats),

              if (_unassigned.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.dailyReportUnassigned(_unassigned.length),
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.orange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // ── Expenses section (with add button only in single-day mode) ─
              Row(
                children: [
                  Text(
                    'Expenses · المصروفات',
                    style: GoogleFonts.nunito(
                        fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  if (!_isRangeMode)
                    TextButton.icon(
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: Text(AppLocalizations.of(context)!.dailyReportAdd,
                          style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                      onPressed: () => _showExpenseDialog(ctx, null),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              if (expState.status == ExpensesStatus.loading)
                const Center(child: CircularProgressIndicator())
              else if (expState.expenses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'لا توجد مصروفات',
                      style: GoogleFonts.cairo(
                          color: Colors.grey, fontSize: 13),
                    ),
                  ),
                )
              else
                ...expState.expenses.map(
                  (e) => _ExpenseRow(
                    expense: e,
                    onEdit:   !_isRangeMode ? () => _showExpenseDialog(ctx, e) : null,
                    onDelete: !_isRangeMode
                        ? () => ctx.read<ExpensesCubit>().remove(e.id)
                        : null,
                  ),
                ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  void _showExpenseDialog(BuildContext ctx, ExpenseModel? existing) {
    final nameCtrl = TextEditingController(text: existing?.name);
    final valCtrl  = TextEditingController(
        text: existing != null ? existing.value.toStringAsFixed(2) : '');
    ExpenseType selectedType = existing?.type ?? ExpenseType.miscellaneous;

    showDialog(
      context: ctx,
      builder: (_) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          final l10n = AppLocalizations.of(dialogCtx)!;
          return AlertDialog(
          title: Text(
            existing == null ? l10n.dailyReportAddExpense : l10n.dailyReportEditExpense,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Type dropdown
              DropdownButtonFormField<ExpenseType>(
                value: selectedType,
                decoration: InputDecoration(
                  labelText: 'Type (النوع)',
                  labelStyle: GoogleFonts.nunito(),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                style: GoogleFonts.nunito(fontSize: 13, color: Colors.black87),
                items: ExpenseType.values.map((t) => DropdownMenuItem(
                  value: t,
                  child: Text('${t.labelAr} · ${t.labelEn}',
                      style: GoogleFonts.nunito(fontSize: 12)),
                )).toList(),
                onChanged: (v) {
                  if (v != null) setDialogState(() => selectedType = v);
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              child: Text(l10n.dailyReportCancel, style: GoogleFonts.nunito(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDeep,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final name  = nameCtrl.text.trim();
                final value = double.tryParse(valCtrl.text) ?? 0;
                if (name.isEmpty || value <= 0) return;
                Navigator.pop(dialogCtx);
                if (existing == null) {
                  ctx.read<ExpensesCubit>().add(
                        name:     name,
                        value:    value,
                        date:     _date,
                        type:     selectedType,
                        branchId: widget.branchId,
                      );
                } else {
                  ctx.read<ExpensesCubit>().edit(
                        id:    existing.id,
                        name:  name,
                        value: value,
                        date:  _date,
                        type:  selectedType,
                      );
                }
              },
              child: Text(l10n.dailyReportSave,
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
            ),
          ],
        );
        },
      ),
    );
  }
}

// ── Range mode bar ─────────────────────────────────────────────────────────────

class _RangeBar extends StatelessWidget {
  const _RangeBar({
    required this.label,
    required this.onTap,
    required this.onClear,
  });
  final String label;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.date_range_outlined,
              size: 18, color: AppColors.primaryDeep),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                label,
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
          TextButton(
            onPressed: onTap,
            child: Text(AppLocalizations.of(context)!.dailyReportChange,
                style: GoogleFonts.nunito(
                    color: AppColors.primaryDeep,
                    fontWeight: FontWeight.w700,
                    fontSize: 12)),
          ),
          TextButton(
            onPressed: onClear,
            child: Text(AppLocalizations.of(context)!.dailyReportToday,
                style: GoogleFonts.nunito(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ── Driver table ──────────────────────────────────────────────────────────────

class _DriverTable extends StatelessWidget {
  const _DriverTable({required this.stats});
  final List<_DriverStats> stats;

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
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
          dataTextStyle: GoogleFonts.nunito(fontSize: 12),
          columnSpacing: 16,
          columns: const [
            DataColumn(label: Text('الطيار\nDriver')),
            DataColumn(label: Text('الطلبات\nOrders'), numeric: true),
            DataColumn(label: Text('توصيل\nShipping'), numeric: true),
            DataColumn(label: Text('كاش\nCash'), numeric: true),
            DataColumn(label: Text('قيمة كاش\nCash Val'), numeric: true),
            DataColumn(label: Text('عربون\nDeposit'), numeric: true),
            DataColumn(label: Text('انستاباي\nInstapay'), numeric: true),
            DataColumn(label: Text('قيمة انستاباي\nIP Val'), numeric: true),
            DataColumn(label: Text('المستحق\nOwes'), numeric: true),
          ],
          rows: stats.map((d) {
            final owesColor = d.driverOwes >= 0 ? Colors.green : Colors.red;
            return DataRow(
              cells: [
                DataCell(Text(d.driver.name,
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700))),
                DataCell(Text(d.totalOrders.toString())),
                DataCell(Text(d.totalShipping.toStringAsFixed(0))),
                DataCell(Text(d.cashCount.toString())),
                DataCell(Text(d.cashValue.toStringAsFixed(0))),
                DataCell(Text(
                  d.totalDeposits > 0 ? d.totalDeposits.toStringAsFixed(0) : '—',
                  style: GoogleFonts.nunito(
                    color: d.totalDeposits > 0 ? Colors.teal : Colors.grey.shade400,
                  ),
                )),
                DataCell(Text(d.instapayCount.toString())),
                DataCell(Text(d.instapayValue.toStringAsFixed(0))),
                DataCell(Text(
                  d.driverOwes.toStringAsFixed(0),
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    color: owesColor,
                  ),
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Expense row ───────────────────────────────────────────────────────────────

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });
  final ExpenseModel expense;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
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
          Text(
            'EGP ${expense.value.toStringAsFixed(2)}',
            style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.orange),
          ),
          if (onEdit != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 16),
              onPressed: onEdit,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: Colors.grey,
            ),
          ],
          if (onDelete != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 16),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx2) {
                    final l10n = AppLocalizations.of(ctx2)!;
                    return AlertDialog(
                    title: Text(l10n.dailyReportDeleteExpense,
                        style:
                            GoogleFonts.nunito(fontWeight: FontWeight.w800)),
                    content: Text('Delete "${expense.name}"?',
                        style: GoogleFonts.nunito()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx2),
                        child: Text(l10n.dailyReportCancel),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx2);
                          onDelete!();
                        },
                        child: Text(l10n.dailyReportDeleteExpense,
                            style: GoogleFonts.nunito(color: Colors.red)),
                      ),
                    ],
                  );
                  },
                );
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: Colors.red,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Summary card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
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
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: highlighted ? color : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.nunito(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ── Date nav ──────────────────────────────────────────────────────────────────

class _DateNav extends StatelessWidget {
  const _DateNav({
    required this.date,
    required this.fmt,
    required this.onPrev,
    required this.onNext,
    required this.onPick,
  });
  final DateTime date;
  final DateFormat fmt;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: onPrev,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2024),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) onPick(picked);
            },
            child: Text(
              fmt.format(date),
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: onNext,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              final now = DateTime.now();
              onPick(DateTime(now.year, now.month, now.day));
            },
            child: Text(AppLocalizations.of(context)!.dailyReportToday,
                style: GoogleFonts.nunito(
                    color: AppColors.primaryDeep,
                    fontWeight: FontWeight.w700,
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _DriverStats {
  final StaffMember driver;
  final int totalOrders;
  final int cashCount;
  final double cashValue;
  final int instapayCount;
  final double instapayValue;
  final double totalShipping;
  final double totalDeposits;
  final double driverOwes;

  const _DriverStats({
    required this.driver,
    required this.totalOrders,
    required this.cashCount,
    required this.cashValue,
    required this.instapayCount,
    required this.instapayValue,
    required this.totalShipping,
    required this.totalDeposits,
    required this.driverOwes,
  });
}
