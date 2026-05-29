import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/helpers/order_invoice_pdf.dart';
import '../../../../core/styling/colors.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import '../../../auth/data/model/staff_user.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../orders/data/model/order_history_model.dart';
import '../../../orders/data/model/order_model.dart';
import '../../../orders/data/repo/orders_repository.dart';
import '../../../staff_mgmt/data/model/staff_member.dart';
import '../cubits/dispatch_board_cubit.dart';

// ── Color helpers ─────────────────────────────────────────────────────────────

Color statusColor(OrderStatus s) {
  switch (s) {
    case OrderStatus.pending:        return Colors.amber;
    case OrderStatus.confirmed:      return Colors.blue;
    case OrderStatus.preparing:      return Colors.deepOrange;
    case OrderStatus.prepared:       return Colors.teal;
    case OrderStatus.outForDelivery: return Colors.purple;
    case OrderStatus.delivered:      return Colors.green;
    case OrderStatus.cancelled:      return Colors.red;
  }
}

String statusLabel(OrderStatus s) {
  switch (s) {
    case OrderStatus.pending:        return 'Pending · مطلوب التأكيد';
    case OrderStatus.confirmed:      return 'Confirmed · متأكد';
    case OrderStatus.preparing:      return 'Preparing · جاري التجهيز';
    case OrderStatus.prepared:       return 'Prepared · جاهز';
    case OrderStatus.outForDelivery: return 'Out for Delivery · جاري التوصيل';
    case OrderStatus.delivered:      return 'Delivered · وصل';
    case OrderStatus.cancelled:      return 'Cancelled · ملغي';
  }
}

OrderStatus? _nextStatus(OrderStatus s) {
  switch (s) {
    case OrderStatus.pending:        return OrderStatus.confirmed;
    case OrderStatus.confirmed:      return OrderStatus.preparing;
    case OrderStatus.preparing:      return OrderStatus.prepared;
    case OrderStatus.prepared:       return OrderStatus.outForDelivery;
    case OrderStatus.outForDelivery: return OrderStatus.delivered;
    default:                         return null;
  }
}

OrderStatus? _prevStatus(OrderStatus s) {
  switch (s) {
    case OrderStatus.confirmed:      return OrderStatus.pending;
    case OrderStatus.preparing:      return OrderStatus.confirmed;
    case OrderStatus.prepared:       return OrderStatus.preparing;
    case OrderStatus.outForDelivery: return OrderStatus.prepared;
    case OrderStatus.delivered:      return OrderStatus.outForDelivery;
    default:                         return null;
  }
}

Future<void> _launchPhone(String phone) async {
  final uri = Uri(scheme: 'tel', path: phone);
  if (await canLaunchUrl(uri)) await launchUrl(uri);
}

Future<void> _launchWhatsApp(String phone) async {
  // Strip non-digits, ensure leading + is preserved for international format
  final digits = phone.replaceAll(RegExp(r'[^\d+]'), '');
  final uri = Uri.parse('https://wa.me/$digits');
  if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> _launchMaps(double lat, double lng) async {
  final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
  if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
}

// ── Card ──────────────────────────────────────────────────────────────────────

class OrderDispatchCard extends StatelessWidget {
  const OrderDispatchCard({
    super.key,
    required this.order,
    required this.drivers,
    this.branchId,
  });

  final OrderModel order;
  final List<StaffMember> drivers;
  final String? branchId;

  @override
  Widget build(BuildContext context) {
    final role     = context.read<AuthCubit>().state.user?.role ?? StaffRole.customerService;
    final canAdvance = role != StaffRole.deliveryUser;
    final canAssign  = role == StaffRole.admin ||
        role == StaffRole.manager ||
        role == StaffRole.deliveryManager;
    final canDrag  = role != StaffRole.deliveryUser;

    final color   = order.isPaid ? const Color(0xFFB8860B) : statusColor(order.status);
    final bgColor = order.isPaid
        ? const Color(0xFFFFF8E1)
        : Theme.of(context).cardColor;
    final next    = _nextStatus(order.status);
    final prev    = _prevStatus(order.status);
    final fmt     = DateFormat('hh:mm a');
    final shortId = '#${order.orderNumber}';

    final card = Card(
      margin: EdgeInsets.zero,
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: order.isPaid
              ? const Color(0xFFFFD700).withValues(alpha: 0.8)
              : color.withValues(alpha: 0.35),
          width: order.isPaid ? 2 : 1.5,
        ),
      ),
      elevation: order.isPaid ? 3 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showDetailSheet(context, canAssign, role),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row ──────────────────────────────────────────────────
              Row(
                children: [
                  if (order.isPaid) ...[
                    const Icon(Icons.paid_rounded, size: 14, color: Color(0xFFB8860B)),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(
                      shortId,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: order.isPaid
                            ? const Color(0xFFB8860B)
                            : AppColors.textDark,
                      ),
                    ),
                  ),
                  _PayBadge(order.paymentMethod),
                  const SizedBox(width: 6),
                  Text(
                    fmt.format(order.createdAt.toLocal()),
                    style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // ── Items summary ────────────────────────────────────────────
              Text(
                order.items.isEmpty
                    ? '0 items'
                    : order.items.map((i) => '${i.quantity}× ${i.productName}').join(', '),
                style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey.shade700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              if (order.deliveryAddress != null && order.deliveryAddress!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 12, color: Colors.purple.shade400),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        order.deliveryAddress!,
                        style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // ── Driver row ───────────────────────────────────────────────
              if (order.driverName != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.delivery_dining_rounded, size: 12, color: Colors.purple.shade300),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        order.driverName!,
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 8),

              // ── Bottom row ───────────────────────────────────────────────
              Row(
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order.deposit > 0
                                  ? 'EGP ${order.amountDue.toStringAsFixed(0)} due'
                                  : 'EGP ${order.totalPrice.toStringAsFixed(0)}',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: color.withValues(alpha: 1),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (order.deposit > 0) ...[
                          const SizedBox(width: 4),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.teal.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'عربون ${order.deposit.toStringAsFixed(0)}',
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.teal.shade700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Call + WhatsApp customer
                  if (order.customerPhone != null) ...[
                    _IconBtn(
                      icon: Icons.phone_rounded,
                      color: Colors.green.shade600,
                      tooltip: 'Call ${order.customerPhone}',
                      onTap: () => _launchPhone(order.customerPhone!),
                    ),
                    const SizedBox(width: 4),
                    _IconBtn(
                      icon: Icons.chat_rounded,
                      color: const Color(0xFF25D366),
                      tooltip: 'WhatsApp ${order.customerPhone}',
                      onTap: () => _launchWhatsApp(order.customerPhone!),
                    ),
                    const SizedBox(width: 4),
                  ],

                  // Open in maps
                  if (order.hasLocation) ...[
                    _IconBtn(
                      icon: Icons.map_rounded,
                      color: Colors.blue.shade600,
                      tooltip: 'Open in Maps',
                      onTap: () => _launchMaps(order.deliveryLat!, order.deliveryLng!),
                    ),
                    const SizedBox(width: 4),
                  ],

                  // Assign driver
                  if (canAssign) ...[
                    _IconBtn(
                      icon: order.driverName == null
                          ? Icons.person_add_outlined
                          : Icons.person_rounded,
                      color: order.driverName == null ? Colors.grey : Colors.purple,
                      tooltip: 'Assign Driver',
                      onTap: () => _showDriverSheet(context, role),
                    ),
                    const SizedBox(width: 4),
                  ],

                  // Move to previous status
                  if (canAdvance && prev != null) ...[
                    _IconBtn(
                      icon: Icons.arrow_back_ios_rounded,
                      color: statusColor(prev),
                      tooltip: 'Back to ${prev.label}',
                      onTap: () {
                        final user = context.read<AuthCubit>().state.user;
                        context.read<DispatchBoardCubit>().moveToStatus(
                              orderId:   order.id,
                              newStatus: prev,
                              branchId:  branchId,
                              actorId:   user?.id,
                              actorName: user?.name,
                              actorRole: user?.role.value,
                            );
                      },
                    ),
                    const SizedBox(width: 4),
                  ],

                  // Move to next status
                  if (canAdvance && next != null)
                    _IconBtn(
                      icon: Icons.arrow_forward_ios_rounded,
                      color: statusColor(next),
                      tooltip: 'Move to ${next.label}',
                      onTap: () {
                        final user = context.read<AuthCubit>().state.user;
                        context.read<DispatchBoardCubit>().moveToStatus(
                              orderId:   order.id,
                              newStatus: next,
                              branchId:  branchId,
                              actorId:   user?.id,
                              actorName: user?.name,
                              actorRole: user?.role.value,
                            );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (!canDrag) return card;

    return LongPressDraggable<OrderModel>(
      data: order,
      delay: const Duration(milliseconds: 350),
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 230,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.drag_indicator_rounded, size: 14, color: color.withValues(alpha: 0.6)),
                    const SizedBox(width: 4),
                    Text(
                      shortId,
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    const Spacer(),
                    Text(
                      'EGP ${order.totalPrice.toStringAsFixed(0)}',
                      style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: color),
                    ),
                  ],
                ),
                if (order.items.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    order.items.map((i) => '${i.quantity}× ${i.productName}').join(', '),
                    style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey.shade700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: card),
      child: card,
    );
  }

  void _showDetailSheet(BuildContext ctx, bool canAssign, StaffRole role) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: ctx.read<DispatchBoardCubit>(),
        child: _OrderDetailSheet(
          order:     order,
          drivers:   drivers,
          branchId:  branchId,
          canAssign: canAssign,
          role:      role,
          repo:      ctx.read<DispatchBoardCubit>().ordersRepo,
        ),
      ),
    );
  }

  void _showDriverSheet(BuildContext ctx, StaffRole role) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: ctx.read<DispatchBoardCubit>(),
        child: _DriverPickerSheet(
          order:    order,
          drivers:  drivers,
          branchId: branchId,
          role:     role,
        ),
      ),
    );
  }
}

// ── Detail Bottom Sheet ───────────────────────────────────────────────────────

class _OrderDetailSheet extends StatefulWidget {
  const _OrderDetailSheet({
    required this.order,
    required this.drivers,
    required this.canAssign,
    required this.role,
    required this.repo,
    this.branchId,
  });
  final OrderModel order;
  final List<StaffMember> drivers;
  final bool canAssign;
  final StaffRole role;
  final String? branchId;
  final OrdersRepository repo;

  @override
  State<_OrderDetailSheet> createState() => _OrderDetailSheetState();
}

class _OrderDetailSheetState extends State<_OrderDetailSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  List<OrderHistoryModel> _history = [];
  bool _historyLoading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final h = await widget.repo.getOrderHistory(orderId: widget.order.id);
      if (mounted) setState(() { _history = h; _historyLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _historyLoading = false);
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order  = widget.order;
    final color  = statusColor(order.status);
    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (_, sc) => Column(
        children: [
          // Handle + header (fixed)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '#${order.orderNumber}',
                        style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (order.isPaid)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFD700)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.paid_rounded, size: 13, color: Color(0xFFB8860B)),
                            const SizedBox(width: 4),
                            Text(AppLocalizations.of(context)!.dispatchCardPaid, style: GoogleFonts.nunito(
                                fontSize: 12, fontWeight: FontWeight.w700,
                                color: const Color(0xFFB8860B))),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        order.status.label,
                        style: GoogleFonts.nunito(
                            fontSize: 12, fontWeight: FontWeight.w700, color: color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dateFmt.format(order.createdAt.toLocal()),
                  style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                // Quick action row: call + maps + paid toggle
                _QuickActions(
                  order:    order,
                  branchId: widget.branchId,
                  role:     widget.role,
                ),
                const SizedBox(height: 8),
                TabBar(
                  controller: _tabs,
                  labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13),
                  unselectedLabelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w500, fontSize: 13),
                  tabs: [Tab(text: AppLocalizations.of(context)!.dispatchCardDetails), Tab(text: AppLocalizations.of(context)!.dispatchCardHistory)],
                ),
              ],
            ),
          ),
          // Scrollable body
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _DetailsTab(
                  order:     order,
                  drivers:   widget.drivers,
                  branchId:  widget.branchId,
                  canAssign: widget.canAssign,
                  role:      widget.role,
                ),
                _HistoryTab(
                  history: _history,
                  loading: _historyLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick action row ──────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.order, required this.role, this.branchId});
  final OrderModel order;
  final StaffRole role;
  final String? branchId;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().state.user;
    final canMarkPaid = role != StaffRole.deliveryUser;

    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        if (order.customerPhone != null) ...[
          Expanded(
            child: _ActionBtn(
              icon: Icons.phone_rounded,
              label: l10n.dispatchCardCall,
              color: Colors.green.shade600,
              onTap: () => _launchPhone(order.customerPhone!),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionBtn(
              icon: Icons.chat_rounded,
              label: l10n.dispatchCardWhatsapp,
              color: const Color(0xFF25D366),
              onTap: () => _launchWhatsApp(order.customerPhone!),
            ),
          ),
        ],
        if (order.customerPhone != null && order.hasLocation)
          const SizedBox(width: 8),
        if (order.hasLocation)
          Expanded(
            child: _ActionBtn(
              icon: Icons.map_rounded,
              label: l10n.dispatchCardMaps,
              color: Colors.blue.shade600,
              onTap: () => _launchMaps(order.deliveryLat!, order.deliveryLng!),
            ),
          ),
        if ((order.customerPhone != null || order.hasLocation) && canMarkPaid)
          const SizedBox(width: 8),
        if (canMarkPaid)
          Expanded(
            child: _ActionBtn(
              icon: order.isPaid ? Icons.money_off_rounded : Icons.paid_rounded,
              label: order.isPaid ? l10n.dispatchCardUnpaid : l10n.dispatchCardMarkPaid,
              color: order.isPaid ? Colors.grey.shade600 : const Color(0xFFB8860B),
              onTap: () {
                Navigator.pop(context);
                context.read<DispatchBoardCubit>().markPaid(
                      orderId:      order.id,
                      isPaid:       !order.isPaid,
                      isCashOrder:  order.isCash,
                      branchId:     branchId,
                      actorId:      user?.id,
                      actorName:    user?.name,
                      actorRole:    user?.role.value,
                    );
              },
            ),
          ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 3),
            Text(label, style: GoogleFonts.nunito(
                fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}

// ── Details Tab ───────────────────────────────────────────────────────────────

class _DetailsTab extends StatelessWidget {
  const _DetailsTab({
    required this.order,
    required this.drivers,
    required this.canAssign,
    required this.role,
    this.branchId,
  });
  final OrderModel order;
  final List<StaffMember> drivers;
  final bool canAssign;
  final StaffRole role;
  final String? branchId;

  @override
  Widget build(BuildContext context) {
    final next = _nextStatus(order.status);
    final user = context.read<AuthCubit>().state.user;

    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(Icons.payments_outlined, l10n.dispatchCardPayment, order.paymentLabel),
          _InfoRow(Icons.attach_money_rounded, l10n.dispatchCardTotal,
              'EGP ${order.totalPrice.toStringAsFixed(2)}'),
          if (order.deposit > 0)
            _InfoRow(Icons.savings_outlined, 'Deposit (عربون)',
                'EGP ${order.deposit.toStringAsFixed(2)}'),
          if (order.deposit > 0)
            _InfoRow(Icons.request_quote_outlined, 'Amount Due',
                'EGP ${order.amountDue.toStringAsFixed(2)}'),
          _DepositEditor(order: order, branchId: branchId, role: role),
          _StaffNoteEditor(order: order, branchId: branchId, role: role),
          if (order.userPaidDeliveryFees > 0)
            _InfoRow(Icons.local_shipping_outlined, l10n.dispatchCardDeliveryFee,
                'EGP ${order.userPaidDeliveryFees.toStringAsFixed(2)}'),
          if (order.customerPhone != null)
            _InfoRow(Icons.phone_rounded, l10n.dispatchCardCustomer, order.customerPhone!),
          if (order.deliveryAddress != null)
            _InfoRow(Icons.location_on_outlined, l10n.dispatchCardAddress, order.deliveryAddress!),
          if (order.notes != null)
            _InfoRow(Icons.note_outlined, l10n.dispatchCardNotes, order.notes!),
          if (order.driverName != null)
            _InfoRow(Icons.delivery_dining_rounded, l10n.dispatchCardDriver, order.driverName!),

          const Divider(height: 24),
          Text(l10n.dispatchCardItems, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Text('${item.quantity}×',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700, color: Colors.grey)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(item.productName,
                            style: GoogleFonts.nunito(fontSize: 13))),
                    Text(
                      'EGP ${item.subtotal.toStringAsFixed(2)}',
                      style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.print_outlined, size: 16),
              label: Text(l10n.dispatchCardPrintInvoice,
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
              onPressed: () => OrderInvoicePdf.printInvoice(order),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: Text(l10n.dispatchCardCopyInvoice,
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
              onPressed: () => _copyInvoiceText(context, order),
            ),
          ),
          const SizedBox(height: 8),

          if (role != StaffRole.deliveryUser) ...[
            if (_prevStatus(order.status) != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
                  label: Text('Back to ${_prevStatus(order.status)!.label}',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: statusColor(_prevStatus(order.status)!),
                    side: BorderSide(color: statusColor(_prevStatus(order.status)!).withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final p = _prevStatus(order.status)!;
                    Navigator.pop(context);
                    context.read<DispatchBoardCubit>().moveToStatus(
                          orderId:   order.id,
                          newStatus: p,
                          branchId:  branchId,
                          actorId:   user?.id,
                          actorName: user?.name,
                          actorRole: user?.role.value,
                        );
                  },
                ),
              ),
            if (next != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  label: Text('Move to ${next.label}',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statusColor(next),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<DispatchBoardCubit>().moveToStatus(
                          orderId:   order.id,
                          newStatus: next,
                          branchId:  branchId,
                          actorId:   user?.id,
                          actorName: user?.name,
                          actorRole: user?.role.value,
                        );
                  },
                ),
              ),
            ],
          ],

          if (canAssign) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.person_rounded, size: 16),
                label: Text(
                  order.driverName == null ? l10n.dispatchCardAssignDriver : l10n.dispatchCardChangeDriver,
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => BlocProvider.value(
                      value: context.read<DispatchBoardCubit>(),
                      child: _DriverPickerSheet(
                        order:    order,
                        drivers:  drivers,
                        branchId: branchId,
                        role:     role,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── History Tab ───────────────────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.history, required this.loading});
  final List<OrderHistoryModel> history;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 36, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.dispatchCardNoHistory,
                style: GoogleFonts.nunito(color: Colors.grey.shade400, fontSize: 13)),
          ],
        ),
      );
    }

    final timeFmt = DateFormat('dd MMM, hh:mm a');
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      itemCount: history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 0),
      itemBuilder: (_, i) {
        final entry = history[i];
        final isLast = i == history.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline spine
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    Container(
                      width: 10, height: 10,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryMid,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: AppColors.primaryMid.withValues(alpha: 0.2),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.action,
                        style: GoogleFonts.nunito(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeFmt.format(entry.createdAt.toLocal()),
                        style: GoogleFonts.nunito(
                            fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Driver Picker Sheet ───────────────────────────────────────────────────────

class _DriverPickerSheet extends StatelessWidget {
  const _DriverPickerSheet({
    required this.order,
    required this.drivers,
    required this.role,
    this.branchId,
  });
  final OrderModel order;
  final List<StaffMember> drivers;
  final StaffRole role;
  final String? branchId;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().state.user;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.dispatchCardAssignDriver,
              style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (order.driverName != null)
            ListTile(
              leading: const Icon(Icons.person_off_outlined, color: Colors.red),
              title: Text(AppLocalizations.of(context)!.dispatchCardUnassignDriver,
                  style: GoogleFonts.nunito(
                      color: Colors.red, fontWeight: FontWeight.w600)),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Navigator.pop(context);
                context.read<DispatchBoardCubit>().assignDriver(
                      orderId:    order.id,
                      driverId:   null,
                      driverName: null,
                      branchId:   branchId,
                      actorId:    user?.id,
                      actorName:  user?.name,
                      actorRole:  user?.role.value,
                    );
              },
            ),
          if (drivers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(AppLocalizations.of(context)!.dispatchCardNoDrivers,
                  style: GoogleFonts.nunito(color: Colors.grey)),
            ),
          ...drivers.map(
            (d) => ListTile(
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.purple.withValues(alpha: 0.15),
                child: Text(
                  d.name.isNotEmpty ? d.name[0].toUpperCase() : 'D',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700, color: Colors.purple),
                ),
              ),
              title: Text(d.name, style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
              subtitle: Text(d.role.label,
                  style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey)),
              contentPadding: EdgeInsets.zero,
              selected:      order.driverId == d.id,
              selectedColor: Colors.purple,
              onTap: () {
                Navigator.pop(context);
                context.read<DispatchBoardCubit>().assignDriver(
                      orderId:    order.id,
                      driverId:   d.id,
                      driverName: d.name,
                      branchId:   branchId,
                      actorId:    user?.id,
                      actorName:  user?.name,
                      actorRole:  user?.role.value,
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _PayBadge extends StatelessWidget {
  const _PayBadge(this.method);
  final String method;

  @override
  Widget build(BuildContext context) {
    final isCash = method == 'cash';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isCash
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.indigo.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isCash ? 'Cash' : 'Instapay',
        style: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isCash ? Colors.green.shade700 : Colors.indigo.shade700,
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }
}

// ── Invoice text copy ─────────────────────────────────────────────────────────

void _copyInvoiceText(BuildContext context, OrderModel order) {
  final fmt = DateFormat('dd/MM/yyyy hh:mm a');
  final sb = StringBuffer();

  sb.writeln('🧾 INVOICE — صابح');
  sb.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  sb.writeln('Order #: ${order.orderNumber}');
  sb.writeln('Date: ${fmt.format(order.createdAt.toLocal())}');
  sb.writeln('Status: ${order.status.label}');
  sb.writeln('Payment: ${order.paymentLabel}');
  if (order.driverName != null) sb.writeln('Driver: ${order.driverName}');
  sb.writeln('');

  sb.writeln('📦 ITEMS');
  sb.writeln('─────────────────────────────');
  for (final item in order.items) {
    final subtotal = item.subtotal.toStringAsFixed(2);
    sb.writeln('${item.productName} x${item.quantity} = EGP $subtotal');
  }
  sb.writeln('');

  sb.writeln('💰 SUMMARY');
  sb.writeln('─────────────────────────────');
  if (order.userPaidDeliveryFees > 0 || order.zoneDeliveryFee > 0) {
    final fee = order.userPaidDeliveryFees + order.zoneDeliveryFee;
    sb.writeln('Delivery Fee: EGP ${fee.toStringAsFixed(2)}');
  }
  if (order.serviceFee > 0) sb.writeln('Service Fee: EGP ${order.serviceFee.toStringAsFixed(2)}');
  if (order.loyaltyDiscount > 0) sb.writeln('Loyalty Discount: -EGP ${order.loyaltyDiscount.toStringAsFixed(2)}');
  if (order.promoDiscount > 0) sb.writeln('Promo Discount: -EGP ${order.promoDiscount.toStringAsFixed(2)}');
  if (order.promoCodeUsed != null) sb.writeln('Promo Code: ${order.promoCodeUsed}');
  sb.writeln('TOTAL: EGP ${order.totalPrice.toStringAsFixed(2)}');
  if (order.deposit > 0) {
    sb.writeln('Deposit Paid: - EGP ${order.deposit.toStringAsFixed(2)}');
    sb.writeln('AMOUNT DUE: EGP ${order.amountDue.toStringAsFixed(2)}');
  }
  sb.writeln('');

  sb.writeln('📍 DELIVERY');
  sb.writeln('─────────────────────────────');
  if (order.deliveryAddress != null) sb.writeln(order.deliveryAddress!);
  if (order.customerPhone != null) sb.writeln('Phone: ${order.customerPhone}');
  if (order.hasLocation) {
    final lat = order.deliveryLat!.toStringAsFixed(6);
    final lng = order.deliveryLng!.toStringAsFixed(6);
    sb.writeln('Map: https://www.google.com/maps?q=$lat,$lng');
  }
  if (order.notes != null && order.notes!.isNotEmpty) {
    sb.writeln('');
    sb.writeln('📝 NOTES');
    sb.writeln(order.notes!);
  }
  sb.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  Clipboard.setData(ClipboardData(text: sb.toString()));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(AppLocalizations.of(context)!.dispatchCardInvoiceCopied),
      duration: const Duration(seconds: 2),
    ),
  );
}

// ── Deposit editor ────────────────────────────────────────────────────────────

class _DepositEditor extends StatefulWidget {
  const _DepositEditor({required this.order, required this.role, this.branchId});
  final OrderModel order;
  final StaffRole role;
  final String? branchId;

  @override
  State<_DepositEditor> createState() => _DepositEditorState();
}

class _DepositEditorState extends State<_DepositEditor> {
  bool _editing = false;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.order.deposit > 0 ? widget.order.deposit.toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.role == StaffRole.deliveryUser) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    if (!_editing) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            const Icon(Icons.savings_outlined, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            SizedBox(
              width: 90,
              child: Text(l10n.dispatchCardDeposit, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            Expanded(
              child: Text(
                widget.order.deposit > 0
                    ? 'EGP ${widget.order.deposit.toStringAsFixed(2)}'
                    : '—',
                style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _editing = true),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
              ),
              child: Text(
                widget.order.deposit > 0 ? l10n.dispatchCardDepositEdit : l10n.dispatchCardSetDeposit,
                style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.teal,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.savings_outlined, size: 16, color: Colors.teal),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 36,
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: l10n.dispatchCardDeposit,
                  prefixText: 'EGP ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                ),
                style: GoogleFonts.nunito(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 6),
          TextButton(
            onPressed: () {
              final value = double.tryParse(_ctrl.text) ?? 0;
              final user = context.read<AuthCubit>().state.user;
              context.read<DispatchBoardCubit>().updateDeposit(
                    orderId:   widget.order.id,
                    deposit:   value,
                    branchId:  widget.branchId,
                    actorId:   user?.id,
                    actorName: user?.name,
                    actorRole: user?.role.value,
                  );
              setState(() => _editing = false);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              backgroundColor: Colors.teal,
            ),
            child: Text(l10n.dispatchCardSave,
                style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => setState(() { _editing = false; _ctrl.text = widget.order.deposit > 0 ? widget.order.deposit.toStringAsFixed(2) : ''; }),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
            ),
            child: Text(l10n.dispatchCardCancel,
                style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

// ── Staff note editor ─────────────────────────────────────────────────────────

class _StaffNoteEditor extends StatefulWidget {
  const _StaffNoteEditor({required this.order, required this.role, this.branchId});
  final OrderModel order;
  final StaffRole role;
  final String? branchId;

  @override
  State<_StaffNoteEditor> createState() => _StaffNoteEditorState();
}

class _StaffNoteEditorState extends State<_StaffNoteEditor> {
  bool _editing = false;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.order.staffNote ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.role == StaffRole.deliveryUser) return const SizedBox.shrink();

    if (!_editing) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.sticky_note_2_outlined, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            SizedBox(
              width: 90,
              child: Text('Staff Note', style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey.shade600)),
            ),
            Expanded(
              child: Text(
                widget.order.staffNote?.isNotEmpty == true ? widget.order.staffNote! : '—',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.order.staffNote?.isNotEmpty == true ? null : Colors.grey.shade400,
                ),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _editing = true),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
              ),
              child: Text(
                widget.order.staffNote?.isNotEmpty == true ? 'Edit' : 'Add',
                style: GoogleFonts.nunito(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sticky_note_2_outlined, size: 16, color: Colors.indigo),
              const SizedBox(width: 8),
              Text('Staff Note', style: GoogleFonts.nunito(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _ctrl,
            autofocus: true,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add a note visible to staff only…',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            style: GoogleFonts.nunito(fontSize: 13),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() { _editing = false; _ctrl.text = widget.order.staffNote ?? ''; }),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero),
                child: Text('Cancel', style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey)),
              ),
              const SizedBox(width: 6),
              TextButton(
                onPressed: () {
                  final user = context.read<AuthCubit>().state.user;
                  context.read<DispatchBoardCubit>().updateStaffNote(
                        orderId:   widget.order.id,
                        staffNote: _ctrl.text,
                        branchId:  widget.branchId,
                        actorId:   user?.id,
                        actorName: user?.name,
                        actorRole: user?.role.value,
                      );
                  setState(() => _editing = false);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  backgroundColor: Colors.indigo,
                ),
                child: Text('Save', style: GoogleFonts.nunito(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(label,
                style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
