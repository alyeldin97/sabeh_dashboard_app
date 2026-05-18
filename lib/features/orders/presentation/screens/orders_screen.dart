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
import 'order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, this.branchId});
  final String? branchId;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  static const _statuses = [
    null,
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
    OrderStatus.cancelled,
  ];
  static const _labels = [
    'All', 'Pending', 'Confirmed', 'Preparing', 'Delivery', 'Done', 'Cancelled'
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _statuses.length, vsync: this);
    context.read<OrdersCubit>().load(branchId: widget.branchId);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDeep,
        elevation: 0,
        title: Text(
          'Orders',
          style: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 20),
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppColors.white, size: 22.r),
            onPressed: () => context.read<OrdersCubit>().load(branchId: widget.branchId),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.primaryPale,
          indicatorColor: AppColors.white,
          indicatorWeight: 2.5,
          labelStyle: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13)),
          tabs: _labels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (_, state) {
          if (state.status == OrdersStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == OrdersStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 48.r, color: AppColors.textLight),
                  SizedBox(height: 12.h),
                  Text(state.errorMessage ?? 'Failed to load orders',
                      style: TextStyle(color: AppColors.textLight)),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<OrdersCubit>().load(branchId: widget.branchId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabs,
            children: _statuses.map((status) {
              final filtered = status == null
                  ? state.orders
                  : state.orders.where((o) => o.status == status).toList();
              return _OrdersList(
                orders: filtered,
                branchId: widget.branchId,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList({required this.orders, this.branchId});
  final List<OrderModel> orders;
  final String? branchId;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64.r, color: AppColors.primaryLight),
            SizedBox(height: 16.h),
            Text(
              'No orders here',
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 18),
                fontWeight: FontWeight.w700,
                color: AppColors.textCharcoal,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: orders.length,
      itemBuilder: (_, i) => _OrderCard(order: orders[i], branchId: branchId),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, this.branchId});
  final OrderModel order;
  final String? branchId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<OrdersCubit>(),
            child: OrderDetailsScreen(order: order, branchId: branchId),
          ),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppBorderRadius.r12,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(14.r),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id.substring(0, 8).toUpperCase()}',
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 14),
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          DateFormat('MMM d, hh:mm a').format(order.createdAt.toLocal()),
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 12),
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(status: order.status),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
                    style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 13),
                      color: AppColors.textMid,
                    ),
                  ),
                  Text(
                    'EGP ${order.totalPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 14),
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final OrderStatus status;

  Color get _bg {
    switch (status) {
      case OrderStatus.pending:        return const Color(0xFFFFF3E0);
      case OrderStatus.confirmed:      return const Color(0xFFE3F2FD);
      case OrderStatus.preparing:      return const Color(0xFFF3E5F5);
      case OrderStatus.outForDelivery: return const Color(0xFFE8F5E9);
      case OrderStatus.delivered:      return AppColors.primaryMist;
      case OrderStatus.cancelled:      return const Color(0xFFFFEBEE);
    }
  }

  Color get _fg {
    switch (status) {
      case OrderStatus.pending:        return const Color(0xFFE65100);
      case OrderStatus.confirmed:      return const Color(0xFF1565C0);
      case OrderStatus.preparing:      return const Color(0xFF6A1B9A);
      case OrderStatus.outForDelivery: return AppColors.primaryMid;
      case OrderStatus.delivered:      return AppColors.primaryDeep;
      case OrderStatus.cancelled:      return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: _bg, borderRadius: AppBorderRadius.r8),
      child: Text(
        status.label,
        style: GoogleFonts.nunito(
          fontSize: Responsive.sp(context, 11),
          fontWeight: FontWeight.w700,
          color: _fg,
        ),
      ),
    );
  }
}
