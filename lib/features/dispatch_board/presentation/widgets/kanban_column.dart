import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../orders/data/model/order_model.dart';
import '../../../staff_mgmt/data/model/staff_member.dart';
import 'order_dispatch_card.dart';

class KanbanColumn extends StatelessWidget {
  const KanbanColumn({
    super.key,
    required this.status,
    required this.orders,
    required this.drivers,
    this.branchId,
    this.isCompact = false,
  });

  final OrderStatus status;
  final List<OrderModel> orders;
  final List<StaffMember> drivers;
  final String? branchId;

  /// Compact mode = mobile tab body (no fixed width, no outer card border)
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ColumnHeader(status: status, count: orders.length, color: color),
        Expanded(
          child: orders.isEmpty
              ? _EmptyColumn(color: color)
              : ListView.separated(
                  padding: const EdgeInsets.all(10),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) => OrderDispatchCard(
                    order:    orders[i],
                    drivers:  drivers,
                    branchId: branchId,
                  ),
                ),
        ),
      ],
    );

    if (isCompact) return column;

    return Container(
      width: 290,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: column,
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader({
    required this.status,
    required this.count,
    required this.color,
  });
  final OrderStatus status;
  final int count;
  final Color color;

  static String _arabicLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:        return 'مطلوب التأكيد';
      case OrderStatus.confirmed:      return 'متأكد';
      case OrderStatus.preparing:      return 'جاري التجهيز';
      case OrderStatus.outForDelivery: return 'جاري التوصيل';
      case OrderStatus.delivered:      return 'وصل';
      case OrderStatus.cancelled:      return 'ملغي';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  status.label,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color.withValues(alpha: 0.9),
                  ),
                ),
                Text(
                  _arabicLabel(status),
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color.withValues(alpha: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyColumn extends StatelessWidget {
  const _EmptyColumn({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 32, color: color.withValues(alpha: 0.3)),
          const SizedBox(height: 8),
          Text(
            'No orders',
            style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
