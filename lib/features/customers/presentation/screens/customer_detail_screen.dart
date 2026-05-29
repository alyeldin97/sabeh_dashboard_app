import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import '../../../orders/data/model/order_model.dart';
import '../../../branches/presentation/cubits/branches_cubit.dart';
import '../../../delivery_zones/presentation/cubits/delivery_zones_cubit.dart';
import '../../../orders/presentation/cubits/orders_cubit.dart';
import '../../../orders/presentation/screens/order_details_screen.dart';
import '../../../orders/presentation/screens/create_order_screen.dart';
import '../../../products/presentation/cubits/products_cubit.dart';
import '../../data/model/customer.dart';
import '../cubits/customers_cubit.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key, required this.customer});
  final Customer customer;

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  bool _editingNotes = false;
  late final TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController(
      text: widget.customer.internalNotes ?? '',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomersCubit>().loadCustomerDetail(widget.customer.id);
    });
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _openCreateOrder(BuildContext context, Customer customer) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<OrdersCubit>()),
          BlocProvider.value(value: context.read<CustomersCubit>()),
          BlocProvider.value(value: context.read<ProductsCubit>()),
          BlocProvider.value(value: context.read<DeliveryZonesCubit>()),
          BlocProvider.value(value: context.read<BranchesCubit>()),
        ],
        child: CreateOrderScreen(preselectedCustomer: customer),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomersCubit, CustomersState>(
      builder: (context, state) {
        final customer = state.selectedCustomer ?? widget.customer;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDeep,
            foregroundColor: AppColors.white,
            elevation: 0,
            title: Text(
              customer.displayName,
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 18),
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () => _openCreateOrder(context, customer),
                icon: Icon(Icons.add_shopping_cart_rounded,
                    color: AppColors.white, size: 18.r),
                label: Text(
                  AppLocalizations.of(context)!.customerDetailCreateOrder,
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 13),
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              _ProfileCard(customer: customer),
              SizedBox(height: 12.h),
              _LoyaltyCard(
                customer: customer,
                onAdjust: (delta, desc) =>
                    context.read<CustomersCubit>().adjustPoints(
                          customer.id,
                          delta,
                          desc,
                        ),
              ),
              SizedBox(height: 12.h),
              _NotesCard(
                customer: customer,
                editingNotes: _editingNotes,
                notesCtrl: _notesCtrl,
                onEditToggle: () {
                  setState(() {
                    _editingNotes = !_editingNotes;
                    if (_editingNotes) {
                      _notesCtrl.text = customer.internalNotes ?? '';
                    }
                  });
                },
                onSave: () {
                  context.read<CustomersCubit>().updateNotes(
                        customer.id,
                        _notesCtrl.text.trim(),
                      );
                  setState(() => _editingNotes = false);
                },
              ),
              SizedBox(height: 12.h),
              _OrdersSection(
                state: state,
                customer: customer,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openCreateOrder(context, customer),
            backgroundColor: AppColors.primaryDeep,
            icon: Icon(Icons.add_rounded, color: AppColors.white, size: 20.r),
            label: Text(
              AppLocalizations.of(context)!.customerDetailCreateOrder,
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Profile Card ─────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.customer});
  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64.r,
            height: 64.r,
            decoration: const BoxDecoration(
              color: AppColors.primaryMist,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                customer.initials,
                style: GoogleFonts.nunito(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDeep,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        customer.displayName,
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 17),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    if (customer.isBlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          borderRadius: AppBorderRadius.r8,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.customerDetailBlocked,
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 11),
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                  ],
                ),
                if (customer.email != null) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.email_outlined,
                          size: 13.r, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(
                        customer.email!,
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 13),
                          color: AppColors.textMid,
                        ),
                      ),
                    ],
                  ),
                ],
                if (customer.phone != null) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined,
                          size: 13.r, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(
                        customer.phone!,
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 13),
                          color: AppColors.textMid,
                        ),
                      ),
                    ],
                  ),
                ],
                if (customer.createdAt != null) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 13.r, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)!.customerDetailJoined(DateFormat('MMM d, yyyy').format(customer.createdAt!.toLocal())),
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 12),
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
                if (customer.referralCode != null) ...[
                  SizedBox(height: 8.h),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMist,
                      borderRadius: AppBorderRadius.r8,
                      border: Border.all(color: AppColors.primaryLight),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.card_giftcard_rounded,
                            size: 13.r, color: AppColors.primaryMid),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context)!.customerDetailRef(customer.referralCode!),
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 12),
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryMid,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loyalty Card ─────────────────────────────────────────────────────────────

class _LoyaltyCard extends StatelessWidget {
  const _LoyaltyCard({required this.customer, required this.onAdjust});
  final Customer customer;
  final void Function(int delta, String description) onAdjust;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDeep, AppColors.primaryMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppBorderRadius.r16,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeep.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.customerDetailLoyaltyPoints,
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 13),
                    color: AppColors.primaryPale,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${customer.loyaltyPoints}',
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 34),
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                    height: 1,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.customerDetailPoints,
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 13),
                    color: AppColors.primaryPale,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showAdjustSheet(context),
            icon: Icon(Icons.tune_rounded, size: 16.r),
            label: Text(
              AppLocalizations.of(context)!.customerDetailAdjust,
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.primaryDeep,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: AppBorderRadius.r12),
              padding: EdgeInsets.symmetric(
                  horizontal: 16.w, vertical: 10.h),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdjustSheet(BuildContext context) {
    bool isAdd = true;
    final amountCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.customerDetailAdjustTitle,
                    style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 17),
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setSheetState(() => isAdd = true),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(
                              color: isAdd
                                  ? AppColors.primaryDeep
                                  : AppColors.scaffoldBg,
                              borderRadius: AppBorderRadius.r12,
                              border: Border.all(
                                color: isAdd
                                    ? AppColors.primaryDeep
                                    : AppColors.border,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.customerDetailAddPoints,
                                style: GoogleFonts.nunito(
                                  fontSize: Responsive.sp(context, 14),
                                  fontWeight: FontWeight.w700,
                                  color: isAdd
                                      ? AppColors.white
                                      : AppColors.textMid,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setSheetState(() => isAdd = false),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(
                              color: !isAdd
                                  ? AppColors.error
                                  : AppColors.scaffoldBg,
                              borderRadius: AppBorderRadius.r12,
                              border: Border.all(
                                color: !isAdd
                                    ? AppColors.error
                                    : AppColors.border,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.customerDetailDeductPoints,
                                style: GoogleFonts.nunito(
                                  fontSize: Responsive.sp(context, 14),
                                  fontWeight: FontWeight.w700,
                                  color: !isAdd
                                      ? AppColors.white
                                      : AppColors.textMid,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _SheetField(
                    controller: amountCtrl,
                    label: AppLocalizations.of(context)!.customerDetailAmount,
                    hint: 'e.g. 50',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 12.h),
                  _SheetField(
                    controller: reasonCtrl,
                    label: AppLocalizations.of(context)!.customerDetailReason,
                    hint: 'e.g. Compensation for delay',
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () {
                        final amount = int.tryParse(amountCtrl.text.trim());
                        if (amount == null || amount <= 0) return;
                        final delta = isAdd ? amount : -amount;
                        final desc = reasonCtrl.text.trim().isEmpty
                            ? (isAdd ? 'Manual addition' : 'Manual deduction')
                            : reasonCtrl.text.trim();
                        Navigator.of(sheetCtx).pop();
                        onAdjust(delta, desc);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDeep,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: AppBorderRadius.r12),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.customerDetailConfirm,
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 15),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Notes Card ───────────────────────────────────────────────────────────────

class _NotesCard extends StatelessWidget {
  const _NotesCard({
    required this.customer,
    required this.editingNotes,
    required this.notesCtrl,
    required this.onEditToggle,
    required this.onSave,
  });
  final Customer customer;
  final bool editingNotes;
  final TextEditingController notesCtrl;
  final VoidCallback onEditToggle;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.customerDetailInternalNotes,
                style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 15),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textCharcoal,
                ),
              ),
              IconButton(
                onPressed: onEditToggle,
                icon: Icon(
                  editingNotes ? Icons.close_rounded : Icons.edit_outlined,
                  size: 18.r,
                  color: AppColors.textLight,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (editingNotes) ...[
            TextField(
              controller: notesCtrl,
              maxLines: 4,
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 13),
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.customerDetailNotesHint,
                hintStyle: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 13),
                  color: AppColors.textLight,
                ),
                filled: true,
                fillColor: AppColors.scaffoldBg,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: AppBorderRadius.r12,
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppBorderRadius.r12,
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppBorderRadius.r12,
                  borderSide:
                      BorderSide(color: AppColors.primaryMid, width: 2),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              height: 40.h,
              child: ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDeep,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: AppBorderRadius.r12),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.of(context)!.customerDetailSaveNotes,
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 13),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ] else ...[
            Text(
              customer.internalNotes?.isNotEmpty == true
                  ? customer.internalNotes!
                  : AppLocalizations.of(context)!.customerDetailNoNotes,
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 13),
                color: customer.internalNotes?.isNotEmpty == true
                    ? AppColors.textMid
                    : AppColors.textLight,
                fontStyle: customer.internalNotes?.isNotEmpty == true
                    ? FontStyle.normal
                    : FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Orders Section ───────────────────────────────────────────────────────────

class _OrdersSection extends StatelessWidget {
  const _OrdersSection({required this.state, required this.customer});
  final CustomersState state;
  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final orders = state.customerOrders.take(20).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.customerDetailPastOrders,
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 16),
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryMist,
                borderRadius: AppBorderRadius.r8,
              ),
              child: Text(
                '${state.customerOrders.length}',
                style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 12),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryMid,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        if (state.detailStatus == CustomersStatus.loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColors.primaryDeep),
            ),
          )
        else if (orders.isEmpty)
          _SectionCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 40.r, color: AppColors.primaryLight),
                    SizedBox(height: 8.h),
                    Text(
                      AppLocalizations.of(context)!.customerDetailNoOrders,
                      style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 14),
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...orders.map((order) => _OrderRow(order: order)),
      ],
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});
  final OrderModel order;

  Color get _statusBg {
    switch (order.status) {
      case OrderStatus.pending:        return const Color(0xFFFFF3E0);
      case OrderStatus.confirmed:      return const Color(0xFFE3F2FD);
      case OrderStatus.preparing:      return const Color(0xFFF3E5F5);
      case OrderStatus.prepared:       return const Color(0xFFE0F2F1);
      case OrderStatus.outForDelivery: return const Color(0xFFE8F5E9);
      case OrderStatus.delivered:      return AppColors.primaryMist;
      case OrderStatus.cancelled:      return const Color(0xFFFFEBEE);
    }
  }

  Color get _statusFg {
    switch (order.status) {
      case OrderStatus.pending:        return const Color(0xFFE65100);
      case OrderStatus.confirmed:      return const Color(0xFF1565C0);
      case OrderStatus.preparing:      return const Color(0xFF6A1B9A);
      case OrderStatus.prepared:       return const Color(0xFF00695C);
      case OrderStatus.outForDelivery: return AppColors.primaryMid;
      case OrderStatus.delivered:      return AppColors.primaryDeep;
      case OrderStatus.cancelled:      return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final ordersCubit = DependencyInjector().ordersCubit;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ordersCubit,
            child: OrderDetailsScreen(order: order),
          ),
        ));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppBorderRadius.r12,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${order.orderNumber}',
                    style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 13),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(order.createdAt.toLocal()),
                    style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 12),
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _statusBg,
                borderRadius: AppBorderRadius.r8,
              ),
              child: Text(
                order.status.label,
                style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 11),
                  fontWeight: FontWeight.w700,
                  color: _statusFg,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'EGP ${order.totalPrice.toStringAsFixed(0)}',
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDeep,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.chevron_right_rounded,
                size: 16.r, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r16,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 13),
            fontWeight: FontWeight.w700,
            color: AppColors.textMid,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 14),
            color: AppColors.textDark,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 13),
              color: AppColors.textLight,
            ),
            filled: true,
            fillColor: AppColors.scaffoldBg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: AppBorderRadius.r12,
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppBorderRadius.r12,
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppBorderRadius.r12,
              borderSide: BorderSide(color: AppColors.primaryMid, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
