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
          if (order.status != OrderStatus.cancelled && order.status != OrderStatus.delivered)
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
          if (canAdvance) SizedBox(height: 80.h),
        ],
      ),
      bottomNavigationBar: canAdvance
          ? _buildAdvanceButton(context)
          : null,
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Order Info'),
          SizedBox(height: 12.h),
          _Row('Created', DateFormat('MMM d, yyyy hh:mm a').format(order.createdAt.toLocal())),
          _Row('Payment', order.paymentMethod.toUpperCase()),
          _Row('Status', order.status.label),
          if (order.notes?.isNotEmpty == true) _Row('Notes', order.notes!),
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
                          'x${item.quantity} × EGP ${item.unitPrice.toStringAsFixed(2)}',
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 12),
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 16), color: AppColors.textMid)),
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, -4)),
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
            style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDeep,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r12),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r16),
        title: Text('Cancel Order', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to cancel this order?',
          style: GoogleFonts.nunito(color: AppColors.textMid),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No', style: GoogleFonts.nunito(color: AppColors.textLight)),
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
              style: GoogleFonts.nunito(color: AppColors.error, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
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
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13), color: AppColors.textLight),
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
