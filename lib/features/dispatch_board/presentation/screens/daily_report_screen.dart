import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/styling/colors.dart';
import '../../../expenses/data/model/expense_model.dart';
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
  late DateTime _date;
  List<OrderModel> _orders = [];
  List<StaffMember> _drivers = [];
  bool _loading = false;
  String? _error;

  late ExpensesCubit _expensesCubit;

  @override
  void initState() {
    super.initState();
    _date = DateTime(widget.initialDate.year, widget.initialDate.month,
        widget.initialDate.day);
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
    });
    try {
      final ordersRepo = DependencyInjector().ordersRepository;
      final staffRepo  = DependencyInjector().staffRepository;

      final results = await Future.wait([
        ordersRepo.getOrdersByDate(date: _date, branchId: widget.branchId),
        staffRepo.getAll(),
      ]);

      _orders  = results[0] as List<OrderModel>;
      _drivers = (results[1] as List<StaffMember>)
          .where((m) =>
              m.role == StaffRole.deliveryUser ||
              m.role == StaffRole.deliveryManager)
          .toList();

      await _expensesCubit.loadForDate(_date, branchId: widget.branchId);

      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
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
      final totalShipping =
          driverOrders.fold(0.0, (s, o) => s + o.deliveryFee);
      final cashValue = cashOrders.fold(0.0, (s, o) => s + o.totalPrice);
      final instapayValue =
          instapayOrders.fold(0.0, (s, o) => s + o.totalPrice);

      stats.add(_DriverStats(
        driver:        driver,
        totalOrders:   driverOrders.length,
        cashCount:     cashOrders.length,
        cashValue:     cashValue,
        instapayCount: instapayOrders.length,
        instapayValue: instapayValue,
        totalShipping: totalShipping,
        driverOwes:    cashValue - totalShipping,
      ));
    }
    return stats;
  }

  // Unassigned orders
  List<OrderModel> get _unassigned =>
      _orders.where((o) => o.driverId == null).toList();

  // ── Totals ─────────────────────────────────────────────────────────────────

  double get _totalCash =>
      _driverStats.fold(0.0, (s, d) => s + d.cashValue);
  double get _totalInstapay =>
      _driverStats.fold(0.0, (s, d) => s + d.instapayValue);
  double get _totalDriverOwes =>
      _driverStats.fold(0.0, (s, d) => s + d.driverOwes);

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
            'Daily Report',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          ),
        ),
        body: Column(
          children: [
            // Date navigation
            _DateNav(
              date: _date,
              fmt: dateFmt,
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
            ),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(_error!,
                              style:
                                  GoogleFonts.nunito(color: Colors.red)))
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
        final netTotal = _totalDriverOwes - totalExpenses;
        final netColor = netTotal >= 0 ? Colors.green : Colors.red;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top summary cards ──────────────────────────────────────
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
                    label: 'Net Profit\nالصافي',
                    value: 'EGP ${netTotal.abs().toStringAsFixed(2)}'
                        '${netTotal < 0 ? ' (loss)' : ''}',
                    color: netColor,
                    icon: Icons.trending_up_rounded,
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
                      'No assigned orders today',
                      style:
                          GoogleFonts.nunito(color: Colors.grey),
                    ),
                  ),
                )
              else
                _DriverTable(stats: _driverStats),

              if (_unassigned.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Unassigned Orders (${_unassigned.length})',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.orange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // ── Expenses section ────────────────────────────────────────
              Row(
                children: [
                  Text(
                    'Expenses · المصروفات',
                    style: GoogleFonts.nunito(
                        fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: Text('Add',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700)),
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
                      'لا توجد مصروفات مسجلة لهذا اليوم',
                      style: GoogleFonts.cairo(
                          color: Colors.grey, fontSize: 13),
                    ),
                  ),
                )
              else
                ...expState.expenses.map(
                  (e) => _ExpenseRow(
                    expense: e,
                    onEdit: () => _showExpenseDialog(ctx, e),
                    onDelete: () => ctx
                        .read<ExpensesCubit>()
                        .remove(e.id),
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
    final valCtrl = TextEditingController(
        text: existing != null
            ? existing.value.toStringAsFixed(2)
            : '');

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(
          existing == null ? 'Add Expense' : 'Edit Expense',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.nunito(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDeep,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final name = nameCtrl.text.trim();
              final value = double.tryParse(valCtrl.text) ?? 0;
              if (name.isEmpty || value <= 0) return;
              Navigator.pop(ctx);
              if (existing == null) {
                ctx.read<ExpensesCubit>().add(
                      name:     name,
                      value:    value,
                      date:     _date,
                      branchId: widget.branchId,
                    );
              } else {
                ctx.read<ExpensesCubit>().edit(
                      id:    existing.id,
                      name:  name,
                      value: value,
                      date:  _date,
                    );
              }
            },
            child: Text('Save',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
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
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
          const Icon(Icons.receipt_outlined,
              size: 16, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(expense.name,
                style: GoogleFonts.nunito(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          Text(
            'EGP ${expense.value.toStringAsFixed(2)}',
            style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.orange),
          ),
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
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Delete Expense',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800)),
                  content: Text(
                    'Delete "${expense.name}"?',
                    style: GoogleFonts.nunito(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onDelete();
                      },
                      child: Text('Delete',
                          style:
                              GoogleFonts.nunito(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Colors.red,
          ),
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
          // Today shortcut
          TextButton(
            onPressed: () {
              final now = DateTime.now();
              onPick(DateTime(now.year, now.month, now.day));
            },
            child: Text('Today',
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
  final double driverOwes;

  const _DriverStats({
    required this.driver,
    required this.totalOrders,
    required this.cashCount,
    required this.cashValue,
    required this.instapayCount,
    required this.instapayValue,
    required this.totalShipping,
    required this.driverOwes,
  });
}
