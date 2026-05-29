import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import '../../../orders/data/model/order_model.dart';
import '../../../orders/presentation/cubits/orders_cubit.dart';
import '../../../orders/presentation/screens/order_details_screen.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key, this.branchId});
  final String? branchId;

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrdersCubit>().load(branchId: widget.branchId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDeep,
        foregroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context)!.deliveryTitle,
          style: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 18),
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, size: 22.r),
            onPressed: () =>
                context.read<OrdersCubit>().load(branchId: widget.branchId),
          ),
        ],
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state.status == OrdersStatus.loading && state.orders.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryDeep));
          }

          final active = state.orders.where((o) =>
              o.status == OrderStatus.confirmed ||
              o.status == OrderStatus.preparing ||
              o.status == OrderStatus.outForDelivery).toList();

          final delivered = state.orders
              .where((o) => o.status == OrderStatus.delivered)
              .take(10)
              .toList();

          if (active.isEmpty && delivered.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delivery_dining_outlined,
                      size: 64.r, color: AppColors.primaryLight),
                  SizedBox(height: 16.h),
                  Text(
                    AppLocalizations.of(context)!.deliveryEmpty,
                    style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 18),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textCharcoal,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    AppLocalizations.of(context)!.deliveryAllSettled,
                    style: GoogleFonts.nunito(color: AppColors.textLight),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              if (active.isNotEmpty) ...[
                _SectionLabel(AppLocalizations.of(context)!.deliveryActive(active.length)),
                SizedBox(height: 10.h),
                ...active.map((o) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _DeliveryCard(
                        order: o,
                        branchId: widget.branchId,
                      ),
                    )),
                SizedBox(height: 16.h),
              ],
              if (delivered.isNotEmpty) ...[
                _SectionLabel(AppLocalizations.of(context)!.deliveryRecentlyDelivered),
                SizedBox(height: 10.h),
                ...delivered.map((o) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _DeliveryCard(
                        order: o,
                        branchId: widget.branchId,
                      ),
                    )),
              ],
              SizedBox(height: 16.h),
            ],
          );
        },
      ),
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
          fontSize: Responsive.sp(context, 11),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppColors.textLight,
        ),
      );
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.order, required this.branchId});
  final OrderModel order;
  final String? branchId;

  static const _statusColors = {
    OrderStatus.confirmed:      Color(0xFF1565C0),
    OrderStatus.preparing:      Color(0xFF6A1B9A),
    OrderStatus.outForDelivery: Color(0xFFC8A96E),
    OrderStatus.delivered:      Color(0xFF2E7D32),
    OrderStatus.cancelled:      Color(0xFFE57373),
    OrderStatus.pending:        Color(0xFFE65100),
  };

  Color get _color => _statusColors[order.status] ?? AppColors.textLight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<OrdersCubit>(),
          child: OrderDetailsScreen(order: order, branchId: branchId),
        ),
      )),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppBorderRadius.r16,
          border: Border.all(
            color: order.status == OrderStatus.outForDelivery
                ? AppColors.accentGold.withValues(alpha: 0.5)
                : AppColors.border,
            width: order.status == OrderStatus.outForDelivery ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconFor(order.status),
                color: _color,
                size: 22.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '#${order.id.substring(0, 8).toUpperCase()}',
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 14),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'EGP ${order.totalPrice.toStringAsFixed(0)}',
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 14),
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDeep,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _color.withValues(alpha: 0.1),
                          borderRadius: AppBorderRadius.full,
                        ),
                        child: Text(
                          order.status.label,
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 11),
                            fontWeight: FontWeight.w700,
                            color: _color,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 12),
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            _QuickStatusButton(order: order, branchId: branchId),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(OrderStatus s) {
    switch (s) {
      case OrderStatus.confirmed:      return Icons.thumb_up_alt_outlined;
      case OrderStatus.preparing:      return Icons.local_fire_department_outlined;
      case OrderStatus.outForDelivery: return Icons.delivery_dining_outlined;
      case OrderStatus.delivered:      return Icons.check_circle_outline_rounded;
      default:                         return Icons.receipt_long_outlined;
    }
  }
}

class _QuickStatusButton extends StatelessWidget {
  const _QuickStatusButton({required this.order, required this.branchId});
  final OrderModel order;
  final String? branchId;

  OrderStatus? get _nextStatus {
    switch (order.status) {
      case OrderStatus.confirmed:      return OrderStatus.preparing;
      case OrderStatus.preparing:      return OrderStatus.outForDelivery;
      case OrderStatus.outForDelivery: return OrderStatus.delivered;
      default:                         return null;
    }
  }

  String _label(OrderStatus s, AppLocalizations l10n) {
    switch (s) {
      case OrderStatus.preparing:      return l10n.deliveryPrepare;
      case OrderStatus.outForDelivery: return l10n.deliveryDispatch;
      case OrderStatus.delivered:      return l10n.deliveryDelivered;
      default:                         return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final next = _nextStatus;
    if (next == null) return const SizedBox.shrink();

    return ElevatedButton(
      onPressed: () => context.read<OrdersCubit>().updateStatus(
            orderId: order.id,
            newStatus: next,
            branchId: branchId,
          ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDeep,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r8),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        elevation: 0,
        minimumSize: Size(0, 32.h),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        _label(next, l10n),
        style: GoogleFonts.nunito(
          fontSize: Responsive.sp(context, 11),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
