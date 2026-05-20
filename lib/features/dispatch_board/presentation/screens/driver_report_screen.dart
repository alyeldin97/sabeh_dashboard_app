import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/styling/colors.dart';
import '../../../orders/data/model/order_model.dart';
import '../../../staff_mgmt/data/model/staff_member.dart';
import '../../../auth/data/model/staff_user.dart';

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

  List<StaffMember> _drivers = [];
  StaffMember? _selectedDriver;
  List<OrderModel> _orders = [];
  bool _loading = false;
  String? _error;

  // Session-only per-order state: collected + custom fee
  final Map<String, bool> _collected = {};
  final Map<String, double> _customFee = {};
  final Map<String, TextEditingController> _feeCtrl = {};

  @override
  void initState() {
    super.initState();
    _date = DateTime(widget.initialDate.year, widget.initialDate.month,
        widget.initialDate.day);
    _loadDrivers();
  }

  @override
  void dispose() {
    for (final c in _feeCtrl.values) {
      c.dispose();
    }
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
      } else {
        orders = await repo.getOrdersByDate(
            date: _date, branchId: widget.branchId);
      }
      final filtered = orders
          .where((o) => o.driverId == _selectedDriver!.id)
          .toList();
      // init session state for new orders
      for (final o in filtered) {
        _collected.putIfAbsent(o.id, () => false);
        _customFee.putIfAbsent(o.id, () => 0);
        _feeCtrl.putIfAbsent(o.id, () => TextEditingController());
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

  List<OrderModel> get _activeOrders =>
      _orders.where((o) => !(_collected[o.id] ?? false)).toList();

  double _shippingFee(OrderModel o) {
    final custom = _customFee[o.id] ?? 0;
    return custom > 0 ? custom : o.deliveryFee;
  }

  double get _totalShipping =>
      _activeOrders.fold(0.0, (s, o) => s + _shippingFee(o));

  double get _cashValue => _activeOrders
      .where((o) => o.status != OrderStatus.cancelled && o.isCash)
      .fold(0.0, (s, o) => s + o.totalPrice);

  double get _driverOwes => _cashValue - _totalShipping;

  int get _cashCount => _activeOrders
      .where((o) => o.status != OrderStatus.cancelled && o.isCash)
      .length;

  int get _instapayCount => _activeOrders
      .where((o) => o.status != OrderStatus.cancelled && !o.isCash)
      .length;

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDeep,
        foregroundColor: Colors.white,
        title: Text(
          'Driver Report',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() {
              _allDates = !_allDates;
              _loadOrders();
            }),
            icon: Icon(
              _allDates ? Icons.calendar_today : Icons.all_inclusive,
              size: 16,
              color: Colors.white70,
            ),
            label: Text(
              _allDates ? 'By Date' : 'All Dates',
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
                    'Drivers',
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _drivers.isEmpty
                      ? Center(
                          child: Text('No drivers',
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
                                  _customFee.clear();
                                  for (final c in _feeCtrl.values) {
                                    c.dispose();
                                  }
                                  _feeCtrl.clear();
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
                // Date navigation (only when not all-dates)
                if (!_allDates)
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
                            totalOrders:   _activeOrders.length,
                            cashCount:     _cashCount,
                            instapayCount: _instapayCount,
                            totalShipping: _totalShipping,
                            driverOwes:    _driverOwes,
                          ),
                          const SizedBox(height: 20),

                          Text(
                            'Orders (${_orders.length})',
                            style: GoogleFonts.nunito(
                                fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),

                          if (_orders.isEmpty)
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
                            ..._orders.map((o) => _DriverOrderRow(
                                  order:      o,
                                  collected:  _collected[o.id] ?? false,
                                  customFee:  _customFee[o.id] ?? 0,
                                  feeCtrl:    _feeCtrl[o.id]!,
                                  shippingFee: _shippingFee(o),
                                  onCollectedChanged: (v) =>
                                      setState(() => _collected[o.id] = v),
                                  onFeeChanged: (v) =>
                                      setState(() => _customFee[o.id] = v),
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
    required this.totalShipping,
    required this.driverOwes,
  });
  final int totalOrders;
  final int cashCount;
  final int instapayCount;
  final double totalShipping;
  final double driverOwes;

  @override
  Widget build(BuildContext context) {
    final owesColor = driverOwes >= 0 ? Colors.green : Colors.red;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _SCard(
          label: 'Total Orders',
          value: '$totalOrders',
          color: AppColors.primaryDeep,
          icon: Icons.receipt_long_outlined,
        ),
        _SCard(
          label: 'Cash Orders',
          value: '$cashCount',
          color: Colors.green,
          icon: Icons.payments_outlined,
        ),
        _SCard(
          label: 'Instapay',
          value: '$instapayCount',
          color: Colors.indigo,
          icon: Icons.account_balance_wallet_outlined,
        ),
        _SCard(
          label: 'Total Shipping\nرسوم التوصيل',
          value: 'EGP ${totalShipping.toStringAsFixed(2)}',
          color: Colors.amber.shade700,
          icon: Icons.local_shipping_outlined,
        ),
        _SCard(
          label: 'Driver Owes\nالمستحق من الطيار',
          value: 'EGP ${driverOwes.abs().toStringAsFixed(2)}'
              '${driverOwes < 0 ? ' (owed to driver)' : ''}',
          color: owesColor,
          icon: Icons.account_balance_outlined,
          highlighted: true,
        ),
      ],
    );
  }
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
    required this.customFee,
    required this.feeCtrl,
    required this.shippingFee,
    required this.onCollectedChanged,
    required this.onFeeChanged,
  });
  final OrderModel order;
  final bool collected;
  final double customFee;
  final TextEditingController feeCtrl;
  final double shippingFee;
  final ValueChanged<bool> onCollectedChanged;
  final ValueChanged<double> onFeeChanged;

  @override
  Widget build(BuildContext context) {
    final isCancelled = order.status == OrderStatus.cancelled;
    final dateFmt = DateFormat('dd MMM');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: collected ? Colors.green.withValues(alpha: 0.05) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '#${order.id.substring(0, 8).toUpperCase()}',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      decoration:
                          collected ? TextDecoration.lineThrough : null,
                      color: collected ? Colors.grey : AppColors.textDark,
                    ),
                  ),
                ),
                if (isCancelled)
                  _Badge('مرتجع', Colors.red),
                const SizedBox(width: 4),
                _Badge(order.isCash ? 'Cash' : 'Instapay',
                    order.isCash ? Colors.green : Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  dateFmt.format(order.createdAt.toLocal()),
                  style:
                      GoogleFonts.nunito(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EGP ${order.totalPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color:
                              collected ? Colors.grey : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.local_shipping_outlined,
                              size: 12, color: Colors.amber),
                          const SizedBox(width: 3),
                          Text(
                            'EGP ${shippingFee.toStringAsFixed(2)}',
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              color: Colors.amber.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Collected',
                        style: GoogleFonts.nunito(
                            fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 4),
                    Switch(
                      value: collected,
                      onChanged: onCollectedChanged,
                      activeThumbColor: Colors.green,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ],
            ),
            if (!collected) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextField(
                        controller: feeCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          hintText: 'Custom shipping fee',
                          hintStyle: GoogleFonts.nunito(
                              fontSize: 12, color: Colors.grey),
                          prefixText: 'EGP ',
                          prefixStyle: GoogleFonts.nunito(fontSize: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 0),
                        ),
                        onChanged: (v) {
                          final parsed = double.tryParse(v) ?? 0;
                          onFeeChanged(parsed);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
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
