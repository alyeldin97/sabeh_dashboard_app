import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import '../../../app_settings/data/model/app_settings_model.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../orders/data/model/order_model.dart';
import '../../../staff_mgmt/data/model/staff_member.dart';
import '../cubits/dispatch_board_cubit.dart';
import 'order_dispatch_card.dart';

class KanbanColumn extends StatelessWidget {
  const KanbanColumn({
    super.key,
    required this.status,
    required this.orders,
    required this.drivers,
    this.branchId,
    this.isCompact = false,
    this.settings,
  });

  final OrderStatus status;
  final List<OrderModel> orders;
  final List<StaffMember> drivers;
  final String? branchId;
  final AppSettingsModel? settings;

  /// Compact mode = mobile tab body (no fixed width, no outer card border)
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);

    final column = DragTarget<OrderModel>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) {
        final order = details.data;
        final user = context.read<AuthCubit>().state.user;
        context.read<DispatchBoardCubit>().moveToStatus(
          orderId:   order.id,
          newStatus: status,
          branchId:  branchId,
          actorId:   user?.id,
          actorName: user?.name,
          actorRole: user?.role.value,
        );
      },
      builder: (context, candidateItems, _) {
        final isDragOver = candidateItems.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: isDragOver
              ? BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: color.withValues(alpha: 0.6),
                    width: 2,
                  ),
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ColumnHeader(
                status:     status,
                count:      orders.length,
                color:      color,
                isDragOver: isDragOver,
              ),
              Expanded(
                child: orders.isEmpty
                    ? _EmptyColumn(color: color, isDragOver: isDragOver)
                    : ListView.separated(
                        padding: const EdgeInsets.all(10),
                        itemCount: orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) => OrderDispatchCard(
                          order:    orders[i],
                          drivers:  drivers,
                          branchId: branchId,
                          settings: settings,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
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
    this.isDragOver = false,
  });
  final OrderStatus status;
  final int count;
  final Color color;
  final bool isDragOver;

  static String _arabicLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:        return 'مطلوب التأكيد';
      case OrderStatus.confirmed:      return 'متأكد';
      case OrderStatus.preparing:      return 'جاري التجهيز';
      case OrderStatus.prepared:       return 'جاهز';
      case OrderStatus.outForDelivery: return 'جاري التوصيل';
      case OrderStatus.delivered:      return 'وصل';
      case OrderStatus.cancelled:      return 'ملغي';
      case OrderStatus.rejected:       return 'مرفوض';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDragOver
            ? color.withValues(alpha: 0.22)
            : color.withValues(alpha: 0.12),
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
  const _EmptyColumn({required this.color, this.isDragOver = false});
  final Color color;
  final bool isDragOver;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDragOver ? Icons.add_circle_outline_rounded : Icons.inbox_outlined,
            size: 32,
            color: color.withValues(alpha: isDragOver ? 0.7 : 0.3),
          ),
          const SizedBox(height: 8),
          Text(
            isDragOver ? AppLocalizations.of(context)!.dispatchDropHere : AppLocalizations.of(context)!.dispatchNoOrders,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: isDragOver ? color : Colors.grey,
              fontWeight: isDragOver ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
