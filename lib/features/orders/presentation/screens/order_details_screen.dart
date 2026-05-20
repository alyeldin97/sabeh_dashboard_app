import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import '../../data/model/order_model.dart';
import '../cubits/orders_cubit.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.order, this.branchId});
  final OrderModel order;
  final String? branchId;

  static const _nextStatus = {
    OrderStatus.pending:        OrderStatus.confirmed,
    OrderStatus.confirmed:      OrderStatus.preparing,
    OrderStatus.preparing:      OrderStatus.outForDelivery,
    OrderStatus.outForDelivery: OrderStatus.delivered,
  };

  static const _nextLabel = {
    OrderStatus.pending:        'Confirm Order',
    OrderStatus.confirmed:      'Start Preparing',
    OrderStatus.preparing:      'Send for Delivery',
    OrderStatus.outForDelivery: 'Mark Delivered',
  };

  @override
  Widget build(BuildContext context) {
    final canAdvance = _nextStatus.containsKey(order.status);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDeep,
        foregroundColor: AppColors.white,
        title: Text(
          'Order #${order.id.substring(0, 8).toUpperCase()}',
          style: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 18),
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        actions: [
          if (order.status != OrderStatus.cancelled &&
              order.status != OrderStatus.delivered)
            IconButton(
              icon: Icon(Icons.cancel_outlined, color: AppColors.white, size: 22.r),
              tooltip: 'Cancel Order',
              onPressed: () => _showCancelDialog(context),
            ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          _buildInfoCard(context),
          SizedBox(height: 12.h),
          _buildItemsCard(context),
          SizedBox(height: 12.h),
          _buildSummaryCard(context),
          if (_hasAnyReward) ...[
            SizedBox(height: 12.h),
            _buildRewardsCard(context),
          ],
          if (canAdvance) SizedBox(height: 80.h),
        ],
      ),
      bottomNavigationBar: canAdvance ? _buildAdvanceButton(context) : null,
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Order Info'),
          SizedBox(height: 12.h),
          _Row('Created',
              DateFormat('MMM d, yyyy hh:mm a').format(order.createdAt.toLocal())),
          _Row('Payment', order.paymentLabel),
          _Row('Status', order.status.label),
          if (order.deliveryAddress?.isNotEmpty == true)
            _Row('Address', order.deliveryAddress!),
          if (order.notes?.isNotEmpty == true) _Row('Notes', order.notes!),
          if (order.promoCodeUsed?.isNotEmpty == true)
            _Row('Promo Code', order.promoCodeUsed!),
          if (order.driverName?.isNotEmpty == true)
            _Row('Driver', order.driverName!),
        ],
      ),
    );
  }

  Widget _buildItemsCard(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Items (${order.items.length})'),
          SizedBox(height: 12.h),
          ...order.items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 14),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textCharcoal,
                          ),
                        ),
                        Text(
                          item.unitPrice == 0
                              ? 'x${item.quantity} · FREE reward'
                              : 'x${item.quantity} × EGP ${item.unitPrice.toStringAsFixed(2)}',
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 12),
                            color: item.unitPrice == 0
                                ? const Color(0xFF2E7D32)
                                : AppColors.textLight,
                            fontWeight: item.unitPrice == 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  item.unitPrice == 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'FREE',
                            style: GoogleFonts.nunito(
                              fontSize: Responsive.sp(context, 11),
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        )
                      : Text(
                          'EGP ${item.subtotal.toStringAsFixed(2)}',
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 14),
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          _SectionTitle('Summary'),
          SizedBox(height: 12.h),
          if (order.deliveryFee > 0) ...[
            _SummaryRow(
              label: 'Delivery Fee',
              value: 'EGP ${order.deliveryFee.toStringAsFixed(2)}',
            ),
            SizedBox(height: 6.h),
          ] else ...[
            _SummaryRow(
              label: 'Delivery',
              value: 'FREE',
              valueColor: const Color(0xFF2E7D32),
              valueSuffix: '🎉',
            ),
            SizedBox(height: 6.h),
          ],
          if (order.serviceFee > 0) ...[
            _SummaryRow(
              label: 'Service Fee',
              value: 'EGP ${order.serviceFee.toStringAsFixed(2)}',
            ),
            SizedBox(height: 6.h),
          ],
          if (order.loyaltyDiscount > 0) ...[
            _SummaryRow(
              label: 'Points (${order.pointsRedeemed} pts)',
              value: '- EGP ${order.loyaltyDiscount.toStringAsFixed(2)}',
              valueColor: const Color(0xFFE6A817),
            ),
            SizedBox(height: 6.h),
          ],
          if (order.promoDiscount > 0) ...[
            _SummaryRow(
              label: order.promoCodeUsed != null
                  ? 'Promo (${order.promoCodeUsed})'
                  : 'Promo Code',
              value: '- EGP ${order.promoDiscount.toStringAsFixed(2)}',
              valueColor: const Color(0xFF1565C0),
            ),
            SizedBox(height: 6.h),
          ],
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 16),
                      color: AppColors.textMid)),
              Text(
                'EGP ${order.totalPrice.toStringAsFixed(2)}',
                style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 18),
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDeep,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvanceButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12.h, 16, 28.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, -4)),
        ],
      ),
      child: SizedBox(
        height: 52.h,
        child: ElevatedButton.icon(
          onPressed: () async {
            final next = _nextStatus[order.status]!;
            await context.read<OrdersCubit>().updateStatus(
                  orderId: order.id,
                  newStatus: next,
                  branchId: branchId,
                );
            if (context.mounted) Navigator.of(context).pop();
          },
          icon: Icon(Icons.check_circle_outline_rounded, size: 20.r),
          label: Text(
            _nextLabel[order.status]!,
            style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDeep,
            foregroundColor: AppColors.white,
            shape:
                RoundedRectangleBorder(borderRadius: AppBorderRadius.r12),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  bool get _hasAnyReward =>
      order.loyaltyCatalogReward != null ||
      order.spendGoalReward != null ||
      order.pointsEarned > 0 ||
      order.pointsRedeemed > 0;

  Widget _buildRewardsCard(BuildContext context) {
    final spendReward = order.spendGoalReward ?? _rewardTypeLabel(order.loyaltyCatalogReward);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Rewards Applied'),
          SizedBox(height: 12.h),
          if (spendReward != null)
            _RewardRow(
              icon: '🏆',
              label: 'Spend Milestone',
              value: spendReward,
              color: const Color(0xFF1565C0),
            ),
          if (order.pointsRedeemed > 0)
            _RewardRow(
              icon: '⭐',
              label: 'Points Redeemed',
              value: '-${order.pointsRedeemed} pts',
              color: const Color(0xFFE6A817),
            ),
          if (order.pointsEarned > 0)
            _RewardRow(
              icon: '✨',
              label: 'Points Earned',
              value: '+${order.pointsEarned} pts',
              color: const Color(0xFF2E7D32),
            ),
        ],
      ),
    );
  }

  String? _rewardTypeLabel(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'free_delivery': return 'Free Delivery';
      case 'free_product':  return 'Free Product';
      case 'both':          return 'Free Delivery + Free Product';
      default:              return value;
    }
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r16),
        title: Text('Cancel Order',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to cancel this order?',
          style: GoogleFonts.nunito(color: AppColors.textMid),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No',
                style: GoogleFonts.nunito(color: AppColors.textLight)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<OrdersCubit>().updateStatus(
                    orderId: order.id,
                    newStatus: OrderStatus.cancelled,
                    branchId: branchId,
                  );
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(
              'Cancel Order',
              style: GoogleFonts.nunito(
                  color: AppColors.error, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared layout widgets ─────────────────────────────────────────────────────

class _RewardRow extends StatelessWidget {
  const _RewardRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final String icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(label,
              style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 13),
                  color: AppColors.textMid)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(value,
              style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 12),
                  fontWeight: FontWeight.w700,
                  color: color)),
        ),
      ]),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r12,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: Responsive.sp(context, 15),
        fontWeight: FontWeight.w700,
        color: AppColors.textCharcoal,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(
      {required this.label,
      required this.value,
      this.valueColor,
      this.valueSuffix});
  final String label;
  final String value;
  final Color? valueColor;
  final String? valueSuffix;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 13),
                color: AppColors.textLight)),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 13),
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textDark,
            ),
          ),
          if (valueSuffix != null) ...[
            const SizedBox(width: 4),
            Text(valueSuffix!, style: const TextStyle(fontSize: 13)),
          ],
        ]),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 13),
                  color: AppColors.textLight),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w600,
                color: AppColors.textCharcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
