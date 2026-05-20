import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/styling/colors.dart';
import '../../../auth/data/model/staff_user.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../orders/data/model/order_model.dart';
import '../../../staff_mgmt/data/model/staff_member.dart';
import '../cubits/dispatch_board_cubit.dart';

// ── Color helpers ─────────────────────────────────────────────────────────────

Color statusColor(OrderStatus s) {
  switch (s) {
    case OrderStatus.pending:        return Colors.amber;
    case OrderStatus.confirmed:      return Colors.blue;
    case OrderStatus.preparing:      return Colors.deepOrange;
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
    case OrderStatus.outForDelivery: return 'Out for Delivery · جاري التوصيل';
    case OrderStatus.delivered:      return 'Delivered · وصل';
    case OrderStatus.cancelled:      return 'Cancelled · ملغي';
  }
}

OrderStatus? _nextStatus(OrderStatus s) {
  switch (s) {
    case OrderStatus.pending:        return OrderStatus.confirmed;
    case OrderStatus.confirmed:      return OrderStatus.preparing;
    case OrderStatus.preparing:      return OrderStatus.outForDelivery;
    case OrderStatus.outForDelivery: return OrderStatus.delivered;
    default:                         return null;
  }
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
    final role = context.read<AuthCubit>().state.user?.role ?? StaffRole.customerService;
    final canAdvance = role != StaffRole.deliveryUser;
    final canAssign  = role == StaffRole.admin ||
        role == StaffRole.manager ||
        role == StaffRole.deliveryManager;

    final color  = statusColor(order.status);
    final next   = _nextStatus(order.status);
    final fmt    = DateFormat('hh:mm a');
    final shortId = '#${order.id.substring(0, 8).toUpperCase()}';

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color.withValues(alpha: 0.35), width: 1.5),
      ),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showDetailSheet(context, canAssign),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row ──────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      shortId,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppColors.textDark,
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
                    ? '${order.items.length} items'
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'EGP ${order.totalPrice.toStringAsFixed(0)}',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color.withValues(alpha: 1),
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Assign driver button
                  if (canAssign)
                    _IconBtn(
                      icon: order.driverName == null
                          ? Icons.person_add_outlined
                          : Icons.person_rounded,
                      color: order.driverName == null ? Colors.grey : Colors.purple,
                      tooltip: 'Assign Driver',
                      onTap: () => _showDriverSheet(context),
                    ),

                  // Move to next status
                  if (canAdvance && next != null) ...[
                    const SizedBox(width: 4),
                    _IconBtn(
                      icon: Icons.arrow_forward_ios_rounded,
                      color: statusColor(next),
                      tooltip: 'Move to ${next.label}',
                      onTap: () => context.read<DispatchBoardCubit>().moveToStatus(
                            orderId:   order.id,
                            newStatus: next,
                            branchId:  branchId,
                          ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext ctx, bool canAssign) {
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
        ),
      ),
    );
  }

  void _showDriverSheet(BuildContext ctx) {
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
        ),
      ),
    );
  }
}

// ── Detail Bottom Sheet ───────────────────────────────────────────────────────

class _OrderDetailSheet extends StatelessWidget {
  const _OrderDetailSheet({
    required this.order,
    required this.drivers,
    required this.canAssign,
    this.branchId,
  });
  final OrderModel order;
  final List<StaffMember> drivers;
  final bool canAssign;
  final String? branchId;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(order.status);
    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      builder: (_, sc) => SingleChildScrollView(
        controller: sc,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '#${order.id.substring(0, 8).toUpperCase()}',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
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
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              dateFmt.format(order.createdAt.toLocal()),
              style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey),
            ),
            const Divider(height: 24),

            _InfoRow(Icons.payments_outlined, 'Payment', order.paymentLabel),
            _InfoRow(Icons.attach_money_rounded, 'Total',
                'EGP ${order.totalPrice.toStringAsFixed(2)}'),
            if (order.deliveryFee > 0)
              _InfoRow(Icons.local_shipping_outlined, 'Delivery Fee',
                  'EGP ${order.deliveryFee.toStringAsFixed(2)}'),
            if (order.deliveryAddress != null)
              _InfoRow(Icons.location_on_outlined, 'Address', order.deliveryAddress!),
            if (order.notes != null)
              _InfoRow(Icons.note_outlined, 'Notes', order.notes!),
            if (order.driverName != null)
              _InfoRow(Icons.delivery_dining_rounded, 'Driver', order.driverName!),

            const Divider(height: 24),
            Text('Items', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14)),
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
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 16),

            // Status advance buttons
            _StatusActions(order: order, branchId: branchId),

            if (canAssign) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.person_rounded, size: 16),
                  label: Text(
                    order.driverName == null ? 'Assign Driver' : 'Change Driver',
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
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusActions extends StatelessWidget {
  const _StatusActions({required this.order, this.branchId});
  final OrderModel order;
  final String? branchId;

  @override
  Widget build(BuildContext context) {
    final next = _nextStatus(order.status);
    if (next == null) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        label: Text(
          'Move to ${next.label}',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: statusColor(next),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          Navigator.pop(context);
          context.read<DispatchBoardCubit>().moveToStatus(
                orderId:   order.id,
                newStatus: next,
                branchId:  branchId,
              );
        },
      ),
    );
  }
}

// ── Driver Picker Sheet ───────────────────────────────────────────────────────

class _DriverPickerSheet extends StatelessWidget {
  const _DriverPickerSheet({
    required this.order,
    required this.drivers,
    this.branchId,
  });
  final OrderModel order;
  final List<StaffMember> drivers;
  final String? branchId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Assign Driver',
              style: GoogleFonts.nunito(
                  fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (order.driverName != null)
            ListTile(
              leading: const Icon(Icons.person_off_outlined, color: Colors.red),
              title: Text('Unassign Driver',
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
                    );
              },
            ),
          if (drivers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No delivery staff found.',
                style: GoogleFonts.nunito(color: Colors.grey),
              ),
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
              title: Text(d.name,
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
              subtitle: Text(d.role.label,
                  style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey)),
              contentPadding: EdgeInsets.zero,
              selected: order.driverId == d.id,
              selectedColor: Colors.purple,
              onTap: () {
                Navigator.pop(context);
                context.read<DispatchBoardCubit>().assignDriver(
                      orderId:    order.id,
                      driverId:   d.id,
                      driverName: d.name,
                      branchId:   branchId,
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
            child: Text(
              label,
              style: GoogleFonts.nunito(
                  fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.nunito(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
