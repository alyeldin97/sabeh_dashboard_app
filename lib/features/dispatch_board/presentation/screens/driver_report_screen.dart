import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/styling/colors.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import '../../../orders/data/model/order_model.dart';
import '../../../staff_mgmt/data/model/staff_member.dart';
import '../../../auth/data/model/staff_user.dart';

// Minimal zone data for cost lookup
class _ZoneInfo {
  final String id;
  final String name;
  final double driverCost;
  const _ZoneInfo({required this.id, required this.name, required this.driverCost});
}


class DriverReportScreen extends StatefulWidget {
  const DriverReportScreen({
    super.key,
    required this.initialDate,
    this.branchId,
  });
  final DateTime initialDate;
  final String? branchId;

  @override
  State<DriverReportScreen> createState() => _DriverReportScreenState();
}

class _DriverReportScreenState extends State<DriverReportScreen> {
  late DateTime _date;
  bool _allDates = false;

  // Date range mode
  bool _isRangeMode = false;
  DateTime? _rangeFrom;
  DateTime? _rangeTo;

  List<StaffMember> _drivers = [];
  StaffMember? _selectedDriver;
  List<OrderModel> _orders = [];
  List<_ZoneInfo> _zones = [];
  bool _loading = false;
  String? _error;

  // Session-only per-order: mark as collected (handed back by driver)
  final Map<String, bool> _collected = {};

  @override
  void initState() {
    super.initState();
    _date = DateTime(widget.initialDate.year, widget.initialDate.month,
        widget.initialDate.day);
    _rangeFrom = _date;
    _rangeTo = _date;
    _loadDrivers();
    _loadZones();
  }

  Future<void> _loadZones() async {
    try {
      final rows = await Supabase.instance.client
          .from('delivery_zones')
          .select('id, name, delivery_fees_paid_to_driver')
          .eq('is_active', true) as List<dynamic>;
      if (mounted) {
        setState(() {
          _zones = rows.map((r) => _ZoneInfo(
            id:         r['id'] as String,
            name:       r['name'] as String,
            driverCost: (r['delivery_fees_paid_to_driver'] as num?)?.toDouble() ?? 0,
          )).toList();
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadDrivers() async {
    final repo = DependencyInjector().staffRepository;
    final members = await repo.getAll();
    if (!mounted) return;
    setState(() {
      _drivers = members
          .where((m) =>
              m.role == StaffRole.deliveryUser ||
              m.role == StaffRole.deliveryManager)
          .toList();
      if (_drivers.isNotEmpty) {
        _selectedDriver = _drivers.first;
        _loadOrders();
      }
    });
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
        _allDates = false;
        _rangeFrom = picked.start;
        _rangeTo   = picked.end;
      });
      _loadOrders();
    }
  }

  String get _dateLabel {
    final fmt = DateFormat('dd MMM yyyy');
    if (_allDates) return 'All Dates';
    if (_isRangeMode && _rangeFrom != null && _rangeTo != null) {
      if (_rangeFrom == _rangeTo) return fmt.format(_rangeFrom!);
      return '${fmt.format(_rangeFrom!)} – ${fmt.format(_rangeTo!)}';
    }
    return fmt.format(_date);
  }

  Future<void> _loadOrders() async {
    if (_selectedDriver == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = DependencyInjector().ordersRepository;
      List<OrderModel> orders;
      if (_allDates) {
        orders = await repo.getOrders(branchId: widget.branchId);
      } else if (_isRangeMode && _rangeFrom != null && _rangeTo != null) {
        orders = await repo.getOrdersByDateRange(
          from: _rangeFrom!,
          to: _rangeTo!,
          branchId: widget.branchId,
        );
      } else {
        orders = await repo.getOrdersByDate(
            date: _date, branchId: widget.branchId);
      }
      final filtered = orders
          .where((o) => o.driverId == _selectedDriver!.id)
          .toList();
      for (final o in filtered) {
        _collected.putIfAbsent(o.id, () => false);
      }
      setState(() {
        _orders = filtered;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ── Financial calculations ─────────────────────────────────────────────────

  List<OrderModel> get _nonCancelledOrders =>
      _orders.where((o) => o.status != OrderStatus.cancelled).toList();

  List<OrderModel> get _activeOrders =>
      _nonCancelledOrders.where((o) => !(_collected[o.id] ?? false)).toList();

  List<OrderModel> get _activeBillable => _activeOrders
      .where((o) => o.status != OrderStatus.cancelled)
      .toList();

  double _effectiveCost(OrderModel o) {
    if (o.zoneDeliveryFee > 0) return o.zoneDeliveryFee;
    final zd = _zones.where((z) => z.id == o.zoneId).firstOrNull
            ?? _zones.where((z) => z.name.toLowerCase() == (o.zoneName?.toLowerCase() ?? '')).firstOrNull;
    return zd?.driverCost ?? 0;
  }

  double _actualCostForOrder(OrderModel o) => _effectiveCost(o);

  // Driver collects cash for cash orders only (amountDue = totalPrice - deposit)
  double get _cashCollected => _activeBillable
      .where((o) => o.isCash)
      .fold(0.0, (s, o) => s + o.amountDue);

  // IP orders go directly to us; amountDue = totalPrice - deposit (deposit also goes directly to us)
  double get _instapayVal => _activeBillable
      .where((o) => !o.isCash)
      .fold(0.0, (s, o) => s + o.amountDue);

  // All deposits (cash + IP) are transferred directly to us, not through driver
  double get _totalDeposits => _activeBillable
      .fold(0.0, (s, o) => s + o.deposit);

  double get _totalActualCost =>
      _activeBillable.fold(0.0, (s, o) => s + _effectiveCost(o));

  double get _totalMaradia =>
      _activeBillable.fold(0.0, (s, o) => s + o.maradia);

  // What we owe the driver: actual delivery cost + مراضية
  double get _owedToDriver => _totalActualCost + _totalMaradia;

  // Net: cash collected by driver minus what we owe them
  double get _driverHandsBack => _cashCollected - _owedToDriver;

  int get _cashCount =>
      _activeBillable.where((o) => o.isCash).length;

  int get _instapayCount =>
      _activeBillable.where((o) => !o.isCash).length;

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFmt = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDeep,
        foregroundColor: Colors.white,
        title: Text(
          l10n.driverReportTitle,
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton.icon(
            onPressed: _pickRange,
            icon: const Icon(Icons.date_range_outlined, size: 16, color: Colors.white70),
            label: Text(
              l10n.driverReportFilterRange,
              style: GoogleFonts.nunito(color: Colors.white70, fontSize: 13),
            ),
          ),
          TextButton.icon(
            onPressed: () => setState(() {
              _allDates = !_allDates;
              if (_allDates) _isRangeMode = false;
              _loadOrders();
            }),
            icon: Icon(
              _allDates ? Icons.calendar_today : Icons.all_inclusive,
              size: 16,
              color: Colors.white70,
            ),
            label: Text(
              _allDates ? l10n.driverReportFilterByDate : l10n.driverReportFilterAll,
              style: GoogleFonts.nunito(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // ── Driver list sidebar ──────────────────────────────────────────
          Container(
            width: 160,
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    l10n.driverReportDrivers,
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _drivers.isEmpty
                      ? Center(
                          child: Text(l10n.driverReportNoDrivers,
                              style: GoogleFonts.nunito(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: _drivers.length,
                          itemBuilder: (_, i) {
                            final d = _drivers[i];
                            final selected = _selectedDriver?.id == d.id;
                            return ListTile(
                              dense: true,
                              selected: selected,
                              selectedTileColor:
                                  AppColors.primaryDeep.withValues(alpha: 0.08),
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: selected
                                    ? AppColors.primaryDeep
                                    : Colors.grey.shade200,
                                child: Text(
                                  d.name.isNotEmpty
                                      ? d.name[0].toUpperCase()
                                      : 'D',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              title: Text(
                                d.name,
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedDriver = d;
                                  _collected.clear();
                                });
                                _loadOrders();
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),

          // ── Main content ─────────────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                // Date navigation
                if (_allDates)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.all_inclusive, size: 16, color: AppColors.primaryDeep),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.driverReportAllDates,
                            style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_isRangeMode)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.date_range_outlined, size: 16, color: AppColors.primaryDeep),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: _pickRange,
                            child: Text(
                              _dateLabel,
                              style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isRangeMode = false;
                            });
                            _loadOrders();
                          },
                          child: Text(l10n.driverReportClear,
                              style: GoogleFonts.nunito(
                                  color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 12)),
                        ),
                      ],
                    ),
                  )
                else
                  _DateNav(
                    date: _date,
                    fmt: dateFmt,
                    onPrev: () {
                      setState(() {
                        _date = _date.subtract(const Duration(days: 1));
                      });
                      _loadOrders();
                    },
                    onNext: () {
                      setState(() {
                        _date = _date.add(const Duration(days: 1));
                      });
                      _loadOrders();
                    },
                    onPick: (d) {
                      setState(() => _date = d);
                      _loadOrders();
                    },
                  ),

                if (_loading)
                  const Expanded(
                      child: Center(child: CircularProgressIndicator()))
                else if (_error != null)
                  Expanded(
                    child: Center(
                      child: Text(_error!,
                          style: GoogleFonts.nunito(color: Colors.red)),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Summary cards
                          _SummaryCards(
                            totalOrders:    _activeOrders.length,
                            cashCount:      _cashCount,
                            instapayCount:  _instapayCount,
                            cashCollected:  _cashCollected,
                            instapayVal:    _instapayVal,
                            totalActualCost: _totalActualCost,
                            totalMaradia:   _totalMaradia,
                            owedToDriver:   _owedToDriver,
                            totalDeposits:  _totalDeposits,
                            driverHandsBack: _driverHandsBack,
                          ),
                          const SizedBox(height: 20),

                          Text(
                            '${l10n.navOrders} (${_nonCancelledOrders.length})',
                            style: GoogleFonts.nunito(
                                fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),

                          if (_nonCancelledOrders.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Text(
                                  'لا توجد طلبات مسجلة لهذا الطيار',
                                  style: GoogleFonts.cairo(
                                      color: Colors.grey, fontSize: 14),
                                ),
                              ),
                            )
                          else
                            ..._nonCancelledOrders.map((o) => _DriverOrderRow(
                                  order:      o,
                                  collected:  _collected[o.id] ?? false,
                                  actualCost: _actualCostForOrder(o),
                                  onCollectedChanged: (v) =>
                                      setState(() => _collected[o.id] = v),
                                )),
                        ],
                      ),
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

// ── Summary Cards ─────────────────────────────────────────────────────────────

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({
    required this.totalOrders,
    required this.cashCount,
    required this.instapayCount,
    required this.cashCollected,
    required this.instapayVal,
    required this.totalActualCost,
    required this.totalMaradia,
    required this.owedToDriver,
    required this.totalDeposits,
    required this.driverHandsBack,
  });
  final int totalOrders;
  final int cashCount;
  final int instapayCount;
  final double cashCollected;
  final double instapayVal;
  final double totalActualCost;
  final double totalMaradia;
  final double owedToDriver;
  final double totalDeposits;
  final double driverHandsBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final handsBackColor = driverHandsBack >= 0 ? Colors.green : Colors.red;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Driver Owes Us ───────────────────────────────────────────────
        _SectionLabel('يُسلّم الطيار · Driver Owes Us'),
        const SizedBox(height: 8),
        Wrap(spacing: 10, runSpacing: 10, children: [
          _SCard(
            label: l10n.driverReportTotalOrders,
            value: '$totalOrders',
            color: AppColors.primaryDeep,
            icon: Icons.receipt_long_outlined,
          ),
          _SCard(
            label: 'كاش ($cashCount طلب) · Cash Orders',
            value: 'EGP ${cashCollected.toStringAsFixed(2)}',
            color: Colors.green.shade700,
            icon: Icons.payments_outlined,
            highlighted: true,
          ),
        ]),
        const SizedBox(height: 16),

        // ── Goes Directly To Us ──────────────────────────────────────────
        _SectionLabel('مباشر لنا · Goes Directly To Us'),
        const SizedBox(height: 8),
        Wrap(spacing: 10, runSpacing: 10, children: [
          if (instapayVal > 0)
            _SCard(
              label: 'انستاباي ($instapayCount) · Instapay → Us',
              value: 'EGP ${instapayVal.toStringAsFixed(2)}',
              color: Colors.indigo,
              icon: Icons.account_balance_wallet_outlined,
            ),
          if (totalDeposits > 0)
            _SCard(
              label: 'عربون · Deposits → Us',
              value: 'EGP ${totalDeposits.toStringAsFixed(2)}',
              color: Colors.teal,
              icon: Icons.savings_outlined,
            ),
          if (instapayVal == 0 && totalDeposits == 0)
            _SCard(
              label: l10n.driverReportInstapay,
              value: '$instapayCount',
              color: Colors.indigo,
              icon: Icons.account_balance_wallet_outlined,
            ),
        ]),
        const SizedBox(height: 16),

        // ── We Owe Driver ────────────────────────────────────────────────
        _SectionLabel('مستحق للطيار · We Owe Driver'),
        const SizedBox(height: 8),
        Wrap(spacing: 10, runSpacing: 10, children: [
          if (totalActualCost > 0)
            _SCard(
              label: 'تكلفة توصيل فعلية · Actual Delivery',
              value: 'EGP ${totalActualCost.toStringAsFixed(2)}',
              color: Colors.red.shade400,
              icon: Icons.local_shipping_rounded,
            ),
          if (totalMaradia > 0)
            _SCard(
              label: 'مراضية · Maradia',
              value: 'EGP ${totalMaradia.toStringAsFixed(2)}',
              color: Colors.orange.shade700,
              icon: Icons.handshake_outlined,
            ),
          if (owedToDriver > 0)
            _SCard(
              label: 'إجمالي مستحق للطيار · Total Owed',
              value: 'EGP ${owedToDriver.toStringAsFixed(2)}',
              color: Colors.purple,
              icon: Icons.price_check_outlined,
            ),
          if (totalActualCost == 0 && totalMaradia == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('—', style: GoogleFonts.nunito(color: Colors.grey)),
            ),
        ]),
        const SizedBox(height: 16),

        // ── Net ──────────────────────────────────────────────────────────
        _SCard(
          label: driverHandsBack >= 0
              ? 'يُسلّم للمتجر · Driver Hands Back'
              : 'ملزوم للطيار · We Owe Driver',
          value: 'EGP ${driverHandsBack.abs().toStringAsFixed(2)}',
          color: handsBackColor,
          icon: Icons.account_balance_outlined,
          highlighted: true,
        ),
      ],
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
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Colors.grey.shade500,
        ),
      );
}

class _SCard extends StatelessWidget {
  const _SCard({
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
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlighted ? color.withValues(alpha: 0.12) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted ? color.withValues(alpha: 0.5) : Colors.grey.shade200,
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
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: highlighted ? color : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ── Per-order row ─────────────────────────────────────────────────────────────

class _DriverOrderRow extends StatelessWidget {
  const _DriverOrderRow({
    required this.order,
    required this.collected,
    required this.actualCost,
    required this.onCollectedChanged,
  });
  final OrderModel order;
  final bool collected;
  final double actualCost;
  final ValueChanged<bool> onCollectedChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCancelled = order.status == OrderStatus.cancelled;
    final dateFmt = DateFormat('dd MMM, hh:mm a');

    // Per-order net
    final cashCollected  = order.isCash ? order.amountDue : 0.0;
    final weOweDriver    = actualCost + order.maradia;
    final netPerOrder    = cashCollected - weOweDriver;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: collected ? Colors.green.withValues(alpha: 0.04) : Colors.white,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: collected ? Colors.green.shade200 : Colors.grey.shade200,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Row(
                children: [
                  Text(
                    '#${order.orderNumber}',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      decoration: collected ? TextDecoration.lineThrough : null,
                      color: collected ? Colors.grey : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _Badge(order.status.label, _statusColor(order.status)),
                  const SizedBox(width: 4),
                  if (isCancelled) _Badge('مرتجع', Colors.red),
                  _Badge(order.isCash ? 'Cash' : 'Instapay',
                      order.isCash ? Colors.green.shade700 : Colors.indigo),
                  const Spacer(),
                  Text(
                    dateFmt.format(order.createdAt.toLocal()),
                    style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  // Collected toggle
                  Text(l10n.driverReportCollected,
                      style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey)),
                  Switch(
                    value: collected,
                    onChanged: isCancelled ? null : onCollectedChanged,
                    activeThumbColor: Colors.green,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),

              if (order.zoneName != null) ...[
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.location_on_outlined, size: 12, color: Colors.grey.shade400),
                  const SizedBox(width: 3),
                  Text(order.zoneName!,
                      style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey.shade500)),
                ]),
              ],

              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // ── Financial breakdown ────────────────────────────────────────
              if (!isCancelled) ...[
                _BreakdownRow(
                  label: 'إجمالي الطلب · Order Total',
                  value: order.totalPrice,
                  color: AppColors.textDark,
                  bold: false,
                ),
                if (order.deposit > 0) ...[
                  const SizedBox(height: 4),
                  _BreakdownRow(
                    label: 'عربون → مباشر لنا · Deposit',
                    value: -order.deposit,
                    color: Colors.teal.shade700,
                    icon: Icons.savings_outlined,
                    note: '→ goes to us',
                  ),
                ],
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: order.isCash
                        ? Colors.green.withValues(alpha: 0.08)
                        : Colors.indigo.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        order.isCash ? Icons.payments_outlined : Icons.account_balance_wallet_outlined,
                        size: 14,
                        color: order.isCash ? Colors.green.shade700 : Colors.indigo,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.isCash
                              ? 'يُسلّم الطيار · Driver collects'
                              : 'انستاباي → مباشر لنا · Instapay → goes to us',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: order.isCash ? Colors.green.shade700 : Colors.indigo,
                          ),
                        ),
                      ),
                      Text(
                        'EGP ${(order.isCash ? order.amountDue : order.amountDue).toStringAsFixed(0)}',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: order.isCash ? Colors.green.shade700 : Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                ),
                if (actualCost > 0 || order.maradia > 0) ...[
                  const SizedBox(height: 8),
                  if (actualCost > 0)
                    _BreakdownRow(
                      label: 'تكلفة توصيل → للطيار · Delivery Cost',
                      value: -actualCost,
                      color: Colors.red.shade400,
                      icon: Icons.local_shipping_rounded,
                      note: '→ we owe driver',
                    ),
                  if (order.maradia > 0) ...[
                    const SizedBox(height: 4),
                    _BreakdownRow(
                      label: 'مراضية → للطيار · Maradia',
                      value: -order.maradia,
                      color: Colors.orange.shade700,
                      icon: Icons.handshake_outlined,
                      note: '→ we owe driver',
                    ),
                  ],
                ],
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: netPerOrder >= 0
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: netPerOrder >= 0
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_outlined,
                        size: 14,
                        color: netPerOrder >= 0 ? Colors.green.shade700 : Colors.red.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          netPerOrder >= 0
                              ? 'صافي يُسلّم للمتجر · Net hands back'
                              : 'صافي مستحق للطيار · Net owed to driver',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: netPerOrder >= 0 ? Colors.green.shade700 : Colors.red.shade600,
                          ),
                        ),
                      ),
                      Text(
                        'EGP ${netPerOrder.abs().toStringAsFixed(0)}',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: netPerOrder >= 0 ? Colors.green.shade700 : Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text('مرتجع · Cancelled',
                    style: GoogleFonts.nunito(color: Colors.red.shade400, fontSize: 12)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.delivered:      return Colors.green;
      case OrderStatus.outForDelivery: return Colors.blue;
      case OrderStatus.preparing:
      case OrderStatus.prepared:       return Colors.orange;
      case OrderStatus.confirmed:      return Colors.teal;
      case OrderStatus.cancelled:      return Colors.red;
      default:                         return Colors.grey;
    }
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.color,
    this.icon,
    this.note,
    this.bold = false,
  });
  final String label;
  final double value;
  final Color color;
  final IconData? icon;
  final String? note;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final sign = value >= 0 ? '' : '−';
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
        ] else
          const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ),
        Text(
          '$sign EGP ${value.abs().toStringAsFixed(0)}',
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

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
        ],
      ),
    );
  }
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
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
