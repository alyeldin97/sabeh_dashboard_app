import 'package:flutter/material.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/styling/colors.dart';
import '../../../expenses/data/model/expense_model.dart';

class ExpenseReportScreen extends StatefulWidget {
  const ExpenseReportScreen({super.key, this.branchId});
  final String? branchId;

  @override
  State<ExpenseReportScreen> createState() => _ExpenseReportScreenState();
}

class _ExpenseReportScreenState extends State<ExpenseReportScreen> {
  // Default: current month
  late DateTime _from;
  late DateTime _to;

  List<ExpenseModel> _expenses = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _from = DateTime(now.year, now.month, 1);
    _to   = DateTime(now.year, now.month + 1, 0); // last day of month
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final repo = DependencyInjector().expensesRepo;
      final expenses = await repo.getExpensesByDateRange(
        from: _from,
        to:   _to,
        branchId: widget.branchId,
      );
      setState(() { _expenses = expenses; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _from, end: _to),
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
      setState(() { _from = picked.start; _to = picked.end; });
      _load();
    }
  }

  // ── Pivot computation ──────────────────────────────────────────────────────

  /// Returns sorted unique dates in the range that have any expense.
  List<DateTime> get _days {
    final days = _expenses
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b));
    return days;
  }

  /// Map: ExpenseType → { dateKey → total }
  Map<ExpenseType, Map<String, double>> get _pivot {
    final result = <ExpenseType, Map<String, double>>{};
    for (final e in _expenses) {
      result.putIfAbsent(e.type, () => <String, double>{});
      final key = _dayKey(e.date);
      result[e.type]![key] = (result[e.type]![key] ?? 0) + e.value;
    }
    return result;
  }

  double _rowTotal(ExpenseType type) =>
      _expenses.where((e) => e.type == type).fold(0.0, (s, e) => s + e.value);

  double _colTotal(DateTime day) {
    final key = _dayKey(day);
    return _expenses
        .where((e) => _dayKey(e.date) == key)
        .fold(0.0, (s, e) => s + e.value);
  }

  double get _grandTotal => _expenses.fold(0.0, (s, e) => s + e.value);

  static String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final rangeFmt = DateFormat('dd MMM yyyy');
    final dayFmt   = DateFormat('d/M');

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDeep,
        foregroundColor: Colors.white,
        title: Text('Expense Report · تقرير المصروفات',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 15)),
        actions: [
          TextButton.icon(
            onPressed: _pickRange,
            icon: const Icon(Icons.date_range_outlined, size: 16, color: Colors.white70),
            label: Text(
              '${rangeFmt.format(_from)} – ${rangeFmt.format(_to)}',
              style: GoogleFonts.nunito(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: GoogleFonts.nunito(color: Colors.red)))
              : _buildBody(dayFmt),
    );
  }

  Widget _buildBody(DateFormat dayFmt) {
    if (_expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No expenses in this period',
                style: GoogleFonts.nunito(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 8),
            TextButton(onPressed: _pickRange, child: Text('Change range',
                style: GoogleFonts.nunito(color: AppColors.primaryDeep))),
          ],
        ),
      );
    }

    final days   = _days;
    final pivot  = _pivot;
    // Show types that have at least one expense
    final types  = ExpenseType.values.where((t) => pivot.containsKey(t)).toList();

    return Column(
      children: [
        // ── Summary cards ────────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _SummaryChip(
                label: 'Total',
                value: 'EGP ${_grandTotal.toStringAsFixed(0)}',
                color: AppColors.primaryDeep,
              ),
              const SizedBox(width: 10),
              _SummaryChip(
                label: 'Types',
                value: '${types.length}',
                color: Colors.teal,
              ),
              const SizedBox(width: 10),
              _SummaryChip(
                label: 'Days',
                value: '${days.length}',
                color: Colors.amber.shade700,
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // ── Pivot table ──────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildTable(days, types, pivot, dayFmt),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTable(
    List<DateTime> days,
    List<ExpenseType> types,
    Map<ExpenseType, Map<String, double>> pivot,
    DateFormat dayFmt,
  ) {
    const rowH    = 40.0;
    const typeW   = 150.0;
    const cellW   = 72.0;
    const totalW  = 90.0;
    const headerH = 44.0;

    final cellStyle = GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600);
    final totalStyle = GoogleFonts.nunito(
        fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryDeep);
    final grandStyle = GoogleFonts.nunito(
        fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white);

    // Build column headers row
    final headerCells = <Widget>[
      // Type label column header
      Container(
        width: typeW,
        height: headerH,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryDeep,
          border: Border(right: BorderSide(color: Colors.white24)),
        ),
        child: Text('Type / النوع',
            style: GoogleFonts.nunito(
                fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      ...days.map((d) => Container(
            width: cellW,
            height: headerH,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryDeep,
              border: Border(right: BorderSide(color: Colors.white24)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(dayFmt.format(d),
                    style: GoogleFonts.nunito(
                        fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                Text(DateFormat('EEE').format(d),
                    style: GoogleFonts.nunito(fontSize: 9, color: Colors.white70)),
              ],
            ),
          )),
      // Total column header
      Container(
        width: totalW,
        height: headerH,
        alignment: Alignment.center,
        color: AppColors.primaryMid,
        child: Text('TOTAL', style: GoogleFonts.nunito(
            fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
      ),
    ];

    // Build data rows
    final dataRows = types.map((type) {
      final rowData = pivot[type] ?? {};
      final rowTotal = _rowTotal(type);

      return _buildDataRow(
        typeW: typeW,
        cellW: cellW,
        totalW: totalW,
        rowH: rowH,
        label: '${type.labelAr}\n${type.labelEn}',
        days: days,
        getValue: (d) => rowData[_dayKey(d)] ?? 0,
        rowTotal: rowTotal,
        cellStyle: cellStyle,
        totalStyle: totalStyle,
        isHighlighted: false,
      );
    }).toList();

    // Totals row
    final totalsRow = Container(
      decoration: BoxDecoration(
        color: AppColors.primaryDeep.withValues(alpha: 0.9),
      ),
      child: Row(
        children: [
          Container(
            width: typeW,
            height: rowH,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('المجموع · Total',
                style: GoogleFonts.nunito(
                    fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
          ...days.map((d) {
            final colTotal = _colTotal(d);
            return Container(
              width: cellW,
              height: rowH,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.white24, width: 0.5)),
              ),
              child: Text(
                colTotal > 0 ? colTotal.toStringAsFixed(0) : '–',
                style: grandStyle,
              ),
            );
          }),
          Container(
            width: totalW,
            height: rowH,
            alignment: Alignment.center,
            color: AppColors.primaryMid,
            child: Text(_grandTotal.toStringAsFixed(0), style: grandStyle),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(children: headerCells),
        const Divider(height: 1, color: Colors.grey),
        // Data rows
        ...dataRows.asMap().entries.map((e) => Container(
              decoration: BoxDecoration(
                color: e.key.isEven ? Colors.white : Colors.grey.shade50,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: e.value,
            )),
        // Totals
        totalsRow,
      ],
    );
  }

  Widget _buildDataRow({
    required double typeW,
    required double cellW,
    required double totalW,
    required double rowH,
    required String label,
    required List<DateTime> days,
    required double Function(DateTime) getValue,
    required double rowTotal,
    required TextStyle cellStyle,
    required TextStyle totalStyle,
    required bool isHighlighted,
  }) {
    return Row(
      children: [
        // Type label
        Container(
          width: typeW,
          height: rowH,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Text(
            label,
            style: GoogleFonts.nunito(
                fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Day cells
        ...days.map((d) {
          final val = getValue(d);
          return Container(
            width: cellW,
            height: rowH,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade200, width: 0.5)),
            ),
            child: val > 0
                ? Text(val.toStringAsFixed(0), style: cellStyle)
                : Text('–', style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey.shade300)),
          );
        }),
        // Row total
        Container(
          width: totalW,
          height: rowH,
          alignment: Alignment.center,
          color: AppColors.primaryMist,
          child: Text(
            rowTotal.toStringAsFixed(0),
            style: totalStyle,
          ),
        ),
      ],
    );
  }
}

// ── Summary chip ──────────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });
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
                  fontSize: 10, color: color, fontWeight: FontWeight.w600)),
          Text(value,
              style: GoogleFonts.nunito(
                  fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}
