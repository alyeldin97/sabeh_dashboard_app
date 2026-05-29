import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/order_invoice_pdf.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import '../../data/model/order_model.dart';
import '../cubits/orders_cubit.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, required this.order, this.branchId});
  final OrderModel order;
  final String? branchId;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late OrderModel _order;

  static const _nextStatus = {
    OrderStatus.pending:        OrderStatus.confirmed,
    OrderStatus.confirmed:      OrderStatus.preparing,
    OrderStatus.preparing:      OrderStatus.outForDelivery,
    OrderStatus.outForDelivery: OrderStatus.delivered,
  };

  Map<OrderStatus, String> _nextLabel(AppLocalizations l10n) => {
    OrderStatus.pending:        l10n.orderDetailsConfirmOrder,
    OrderStatus.confirmed:      l10n.orderDetailsStartPreparing,
    OrderStatus.preparing:      l10n.orderDetailsSendForDelivery,
    OrderStatus.outForDelivery: l10n.orderDetailsMarkDelivered,
  };

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  Future<void> _refresh() =>
      context.read<OrdersCubit>().loadSingle(orderId: _order.id);

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canAdvance = _nextStatus.containsKey(_order.status);

    return BlocListener<OrdersCubit, OrdersState>(
      listenWhen: (p, c) =>
          c.detailStatus == OrdersStatus.success &&
          c.selectedOrder?.id == _order.id,
      listener: (_, state) {
        if (state.selectedOrder != null) {
          setState(() => _order = state.selectedOrder!);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColors.primaryDeep,
          foregroundColor: AppColors.white,
          title: Text(
            'Order #${_order.orderNumber}',
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 18),
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.print_outlined, color: AppColors.white, size: 22.r),
              tooltip: l10n.orderDetailsPrintInvoice,
              onPressed: () => OrderInvoicePdf.printInvoice(_order),
            ),
            if (_order.status != OrderStatus.cancelled &&
                _order.status != OrderStatus.delivered)
              IconButton(
                icon: Icon(Icons.cancel_outlined, color: AppColors.white, size: 22.r),
                tooltip: l10n.orderDetailsCancelOrder,
                onPressed: () => _showCancelDialog(context),
              ),
          ],
        ),
        body: ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            _buildInfoCard(context, l10n),
            SizedBox(height: 12.h),
            _buildItemsCard(context, l10n),
            SizedBox(height: 12.h),
            _buildSummaryCard(context, l10n),
            if (_hasAnyReward) ...[
              SizedBox(height: 12.h),
              _buildRewardsCard(context, l10n),
            ],
            if (canAdvance) SizedBox(height: 80.h),
          ],
        ),
        bottomNavigationBar: canAdvance ? _buildAdvanceButton(context, l10n) : null,
      ),
    );
  }

  // ── Info Card ──────────────────────────────────────────────────────────────

  Widget _buildInfoCard(BuildContext context, AppLocalizations l10n) {
    return _SectionCard(
      title: l10n.orderDetailsOrderInfo,
      onEdit: () => _showInfoSheet(context, l10n),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(l10n.orderDetailsCreated,
              DateFormat('MMM d, yyyy hh:mm a').format(_order.createdAt.toLocal())),
          _InfoRow(l10n.orderDetailsPayment, _order.paymentLabel),
          _InfoRow(l10n.orderDetailsStatus, _order.status.label),
          if (_order.customerPhone?.isNotEmpty == true)
            _InfoRow('Phone', _order.customerPhone!),
          if (_order.deliveryAddress?.isNotEmpty == true)
            _InfoRow(l10n.orderDetailsAddress, _order.deliveryAddress!),
          if (_order.notes?.isNotEmpty == true)
            _InfoRow(l10n.orderDetailsNotes, _order.notes!),
          if (_order.staffNote?.isNotEmpty == true)
            _InfoRow('Staff Note', _order.staffNote!),
          if (_order.promoCodeUsed?.isNotEmpty == true)
            _InfoRow(l10n.orderDetailsPromoCode, _order.promoCodeUsed!),
          if (_order.driverName?.isNotEmpty == true)
            _InfoRow(l10n.orderDetailsDriver, _order.driverName!),
        ],
      ),
    );
  }

  void _showInfoSheet(BuildContext context, AppLocalizations l10n) {
    final notesCtrl     = TextEditingController(text: _order.notes ?? '');
    final staffNoteCtrl = TextEditingController(text: _order.staffNote ?? '');
    final addressCtrl   = TextEditingController(text: _order.deliveryAddress ?? '');
    final phoneCtrl     = TextEditingController(text: _order.customerPhone ?? '');
    String payment      = _order.paymentMethod;
    final cubit         = context.read<OrdersCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, ss) => _SheetWrapper(
          title: 'Edit Info',
          onSave: () async {
            Navigator.pop(ctx);
            await cubit.editOrder(
              orderId: _order.id,
              notes: notesCtrl.text,
              deliveryAddress: addressCtrl.text,
              customerPhone: phoneCtrl.text,
              paymentMethod: payment,
              staffNote: staffNoteCtrl.text,
              branchId: widget.branchId,
            );
            await _refresh();
          },
          children: [
            _EditField(label: 'Customer Phone', controller: phoneCtrl,
                keyboardType: TextInputType.phone),
            SizedBox(height: 12.h),
            _EditField(label: l10n.orderDetailsAddress, controller: addressCtrl),
            SizedBox(height: 12.h),
            _EditField(label: l10n.orderDetailsNotes, controller: notesCtrl, maxLines: 3),
            SizedBox(height: 12.h),
            _EditField(label: 'Staff Note', controller: staffNoteCtrl, maxLines: 3),
            SizedBox(height: 14.h),
            Text('Payment Method',
                style: GoogleFonts.nunito(fontSize: Responsive.sp(ctx, 13),
                    fontWeight: FontWeight.w600, color: AppColors.textMid)),
            SizedBox(height: 8.h),
            Row(children: [
              _PaymentChip(
                label: 'Cash on Delivery',
                selected: payment == 'cash',
                onTap: () => ss(() => payment = 'cash'),
              ),
              SizedBox(width: 8.w),
              _PaymentChip(
                label: 'Instapay / Wallet',
                selected: payment == 'instapay',
                onTap: () => ss(() => payment = 'instapay'),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  // ── Items Card ─────────────────────────────────────────────────────────────

  bool get _hasLoyaltyFreeProduct {
    final reward = _order.loyaltyCatalogReward ?? _order.spendGoalReward ?? '';
    return reward == 'free_product' || reward == 'both';
  }

  Widget _buildItemsCard(BuildContext context, AppLocalizations l10n) {
    return _SectionCard(
      title: l10n.createOrderSummaryItems(_order.items.length),
      onEdit: () => _showItemsSheet(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _order.items.map((item) {
          final isFree = item.unitPrice == 0 && _hasLoyaltyFreeProduct;
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.productName,
                          style: GoogleFonts.nunito(
                              fontSize: Responsive.sp(context, 14),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textCharcoal)),
                      Text(
                        item.unitPrice == 0
                            ? isFree
                                ? 'x${item.quantity} · 🎁 ${l10n.loyaltyTypeFreeProduct}'
                                : 'x${item.quantity} · ${l10n.orderDetailsFree}'
                            : 'x${item.quantity} × EGP ${item.unitPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 12),
                            color: item.unitPrice == 0
                                ? const Color(0xFF2E7D32)
                                : AppColors.textLight,
                            fontWeight: item.unitPrice == 0
                                ? FontWeight.w600
                                : FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                item.unitPrice == 0
                    ? Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(l10n.orderDetailsFree,
                            style: GoogleFonts.nunito(
                                fontSize: Responsive.sp(context, 11),
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF2E7D32))))
                    : Text('EGP ${item.subtotal.toStringAsFixed(2)}',
                        style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 14),
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showItemsSheet(BuildContext context) {
    final items = _order.items
        .map((i) => _MutableItem(
              id: i.id,
              productName: i.productName,
              unitPrice: i.unitPrice,
              quantity: i.quantity,
            ))
        .toList();
    final cubit = context.read<OrdersCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, ss) {
          final itemsSubtotal = items.fold(0.0, (s, i) => s + i.subtotal);
          final newTotal = itemsSubtotal
              + _order.userPaidDeliveryFees
              + _order.serviceFee
              - _order.loyaltyDiscount
              - _order.promoDiscount;

          return _SheetWrapper(
            title: 'Edit Items',
            onSave: items.isEmpty
                ? null
                : () async {
                    Navigator.pop(ctx);
                    final originalIds =
                        _order.items.map((i) => i.id).toSet();
                    final remainingIds = items.map((i) => i.id).toSet();
                    final deletedIds =
                        originalIds.difference(remainingIds).toList();
                    await cubit.updateItems(
                      orderId: _order.id,
                      updatedItems: items
                          .map((i) => {
                                'id': i.id,
                                'quantity': i.quantity,
                                'subtotal': i.subtotal,
                              })
                          .toList(),
                      deletedItemIds: deletedIds,
                      newTotalPrice: newTotal,
                      branchId: widget.branchId,
                    );
                    await _refresh();
                  },
            children: [
              if (items.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Center(
                    child: Text(
                      'All items removed.\nAt least one item is required to save.',
                      style: GoogleFonts.nunito(
                          color: AppColors.error,
                          fontSize: Responsive.sp(ctx, 13)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...items.map((item) => Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBg,
                        borderRadius: AppBorderRadius.r8,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productName,
                                    style: GoogleFonts.nunito(
                                        fontSize: Responsive.sp(ctx, 13),
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark)),
                                if (item.unitPrice > 0)
                                  Text(
                                      'EGP ${item.unitPrice.toStringAsFixed(2)} each',
                                      style: GoogleFonts.nunito(
                                          fontSize: Responsive.sp(ctx, 11),
                                          color: AppColors.textLight)),
                              ],
                            ),
                          ),
                          if (item.unitPrice > 0) ...[
                            _QtyBtn(
                              icon: Icons.remove,
                              enabled: item.quantity > 1,
                              onTap: () => ss(() => item.quantity--),
                            ),
                            SizedBox(
                              width: 32.w,
                              child: Text('${item.quantity}',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(
                                      fontSize: Responsive.sp(ctx, 14),
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark)),
                            ),
                            _QtyBtn(
                              icon: Icons.add,
                              enabled: true,
                              onTap: () => ss(() => item.quantity++),
                            ),
                            SizedBox(width: 8.w),
                            Text('EGP ${item.subtotal.toStringAsFixed(2)}',
                                style: GoogleFonts.nunito(
                                    fontSize: Responsive.sp(ctx, 13),
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDeep)),
                            SizedBox(width: 4.w),
                          ],
                          IconButton(
                            icon: Icon(Icons.delete_outline_rounded,
                                size: 18.r, color: AppColors.error),
                            onPressed: () => ss(() => items.remove(item)),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    )),
              const Divider(height: 20),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('New Total',
                        style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(ctx, 14),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMid)),
                    Text('EGP ${newTotal.toStringAsFixed(2)}',
                        style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(ctx, 16),
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDeep)),
                  ]),
            ],
          );
        },
      ),
    );
  }

  // ── Summary Card ───────────────────────────────────────────────────────────

  Widget _buildSummaryCard(BuildContext context, AppLocalizations l10n) {
    return _SectionCard(
      title: l10n.orderDetailsSummary,
      onEdit: () => _showSummarySheet(context, l10n),
      child: Column(
        children: [
          if (_order.userPaidDeliveryFees > 0) ...[
            _SummaryRow(
                label: l10n.orderDetailsDeliveryFee,
                value: 'EGP ${_order.userPaidDeliveryFees.toStringAsFixed(2)}'),
            SizedBox(height: 6.h),
          ] else ...[
            _SummaryRow(
                label: l10n.orderDetailsDelivery,
                value: l10n.orderDetailsFree,
                valueColor: const Color(0xFF2E7D32),
                valueSuffix: '🎉'),
            SizedBox(height: 6.h),
          ],
          if (_order.serviceFee > 0) ...[
            _SummaryRow(
                label: l10n.orderDetailsServiceFee,
                value: 'EGP ${_order.serviceFee.toStringAsFixed(2)}'),
            SizedBox(height: 6.h),
          ],
          if (_order.loyaltyDiscount > 0) ...[
            _SummaryRow(
              label:
                  '${l10n.orderDetailsPointsRedeemed} (${_order.pointsRedeemed} pts)',
              value: '- EGP ${_order.loyaltyDiscount.toStringAsFixed(2)}',
              valueColor: const Color(0xFFE6A817),
            ),
            SizedBox(height: 6.h),
          ],
          if (_order.promoDiscount > 0) ...[
            _SummaryRow(
              label: _order.promoCodeUsed != null
                  ? '${l10n.orderDetailsPromoCode} (${_order.promoCodeUsed})'
                  : l10n.orderDetailsPromoCode,
              value: '- EGP ${_order.promoDiscount.toStringAsFixed(2)}',
              valueColor: const Color(0xFF1565C0),
            ),
            SizedBox(height: 6.h),
          ],
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.orderDetailsTotal,
                  style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 16),
                      color: AppColors.textMid)),
              Text('EGP ${_order.totalPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 18),
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDeep)),
            ],
          ),
          if (_order.deposit > 0) ...[
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.orderDetailsDeposit,
                    style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 13),
                        color: Colors.teal.shade700)),
                Text('- EGP ${_order.deposit.toStringAsFixed(2)}',
                    style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 13),
                        fontWeight: FontWeight.w700,
                        color: Colors.teal.shade700)),
              ],
            ),
            SizedBox(height: 6.h),
            const Divider(height: 1),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.orderDetailsAmountDue,
                    style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 15),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMid)),
                Text('EGP ${_order.amountDue.toStringAsFixed(2)}',
                    style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 17),
                        fontWeight: FontWeight.w800,
                        color: Colors.orange.shade700)),
              ],
            ),
          ],
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Payment Status',
                  style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 13),
                      color: AppColors.textLight)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _order.isPaid
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  borderRadius: AppBorderRadius.r8,
                ),
                child: Text(
                  _order.isPaid ? 'Paid' : 'Unpaid',
                  style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 12),
                      fontWeight: FontWeight.w700,
                      color: _order.isPaid
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFE65100)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSummarySheet(BuildContext context, AppLocalizations l10n) {
    final deliveryCtrl = TextEditingController(
        text: _order.userPaidDeliveryFees.toStringAsFixed(2));
    final depositCtrl =
        TextEditingController(text: _order.deposit.toStringAsFixed(2));
    final maradiaCtrl =
        TextEditingController(text: _order.maradia.toStringAsFixed(2));
    bool isPaid = _order.isPaid;
    final cubit = context.read<OrdersCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, ss) => _SheetWrapper(
          title: 'Edit Financial Details',
          onSave: () async {
            Navigator.pop(ctx);
            final newDelivery = double.tryParse(deliveryCtrl.text) ??
                _order.userPaidDeliveryFees;
            final newDeposit =
                double.tryParse(depositCtrl.text) ?? _order.deposit;
            final newMaradia =
                double.tryParse(maradiaCtrl.text) ?? _order.maradia;
            await cubit.editFinancials(
              orderId: _order.id,
              deliveryFee: newDelivery,
              deposit: newDeposit,
              maradia: newMaradia,
              isPaid: isPaid,
              oldDeliveryFee: _order.userPaidDeliveryFees,
              oldTotal: _order.totalPrice,
              isCashOrder: _order.isCash,
              branchId: widget.branchId,
            );
            await _refresh();
          },
          children: [
            _EditField(
              label: 'Delivery Fee (EGP)',
              controller: deliveryCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 12.h),
            _EditField(
              label: 'Deposit (EGP)',
              controller: depositCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 12.h),
            _EditField(
              label: 'Maradia (EGP)',
              controller: maradiaCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mark as Paid',
                    style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(ctx, 14),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                Switch(
                  value: isPaid,
                  onChanged: (v) => ss(() => isPaid = v),
                  activeThumbColor: AppColors.primaryDeep,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Rewards Card ───────────────────────────────────────────────────────────

  bool get _hasAnyReward =>
      _order.loyaltyCatalogReward != null ||
      _order.spendGoalReward != null ||
      _order.pointsEarned > 0 ||
      _order.pointsRedeemed > 0;

  String _buildRewardLabel() {
    final reward = _order.loyaltyCatalogReward ?? _order.spendGoalReward ?? '';
    final freeItems = _order.items.where((i) => i.unitPrice == 0).toList();
    final parts = <String>[];
    if (reward == 'free_delivery' || reward == 'both') parts.add('Free Delivery');
    if (freeItems.isNotEmpty) {
      parts.addAll(freeItems.map((i) => i.productName));
    } else if (reward == 'free_product' || reward == 'both') {
      parts.add('Free Product');
    }
    if (parts.isEmpty && reward.isNotEmpty) return reward;
    return parts.join(' + ');
  }

  Widget _buildRewardsCard(BuildContext context, AppLocalizations l10n) {
    final hasReward =
        _order.spendGoalReward != null || _order.loyaltyCatalogReward != null;
    return _SectionCard(
      title: l10n.orderDetailsRewardsApplied,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasReward)
            _RewardRow(
              icon: '🏆',
              label: l10n.orderDetailsSpendMilestone,
              value: _buildRewardLabel(),
              color: const Color(0xFF1565C0),
            ),
          if (_order.pointsRedeemed > 0)
            _RewardRow(
              icon: '⭐',
              label: l10n.orderDetailsPointsRedeemed,
              value: '-${_order.pointsRedeemed} pts',
              color: const Color(0xFFE6A817),
            ),
          if (_order.pointsEarned > 0)
            _RewardRow(
              icon: '✨',
              label: l10n.orderDetailsPointsEarned,
              value: '+${_order.pointsEarned} pts',
              color: const Color(0xFF2E7D32),
            ),
        ],
      ),
    );
  }

  // ── Advance Button ─────────────────────────────────────────────────────────

  Widget _buildAdvanceButton(BuildContext context, AppLocalizations l10n) {
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
            final next = _nextStatus[_order.status]!;
            await context.read<OrdersCubit>().updateStatus(
                  orderId: _order.id,
                  newStatus: next,
                  branchId: widget.branchId,
                );
            if (context.mounted) Navigator.of(context).pop();
          },
          icon: Icon(Icons.check_circle_outline_rounded, size: 20.r),
          label: Text(
            _nextLabel(l10n)[_order.status]!,
            style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 15),
                fontWeight: FontWeight.w700),
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

  // ── Cancel Dialog ──────────────────────────────────────────────────────────

  void _showCancelDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r16),
        title: Text(l10n.orderDetailsCancelOrder,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text(l10n.orderDetailsCancelConfirm,
            style: GoogleFonts.nunito(color: AppColors.textMid)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.orderDetailsNo,
                style: GoogleFonts.nunito(color: AppColors.textLight)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<OrdersCubit>().updateStatus(
                    orderId: _order.id,
                    newStatus: OrderStatus.cancelled,
                    branchId: widget.branchId,
                  );
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(l10n.orderDetailsCancelOrder,
                style: GoogleFonts.nunito(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── _MutableItem ───────────────────────────────────────────────────────────────

class _MutableItem {
  final String id;
  final String productName;
  final double unitPrice;
  int quantity;

  _MutableItem({
    required this.id,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  double get subtotal => unitPrice * quantity;
}

// ── _QtyBtn ────────────────────────────────────────────────────────────────────

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 28.r,
        height: 28.r,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primaryDeep : AppColors.border,
          borderRadius: AppBorderRadius.r8,
        ),
        child: Icon(icon, size: 16.r, color: Colors.white),
      ),
    );
  }
}

// ── _SheetWrapper ──────────────────────────────────────────────────────────────

class _SheetWrapper extends StatelessWidget {
  const _SheetWrapper({
    required this.title,
    required this.children,
    required this.onSave,
  });
  final String title;
  final List<Widget> children;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: AppBorderRadius.full,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(title,
                  style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
              SizedBox(height: 16.h),
              ...children,
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: onSave != null
                        ? AppColors.primaryDeep
                        : AppColors.border,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: AppBorderRadius.r12),
                    elevation: 0,
                  ),
                  child: Text('Save Changes',
                      style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 15),
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── _SectionCard ───────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.onEdit,
  });
  final String title;
  final Widget child;
  final VoidCallback? onEdit;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 15),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textCharcoal)),
              ),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMist,
                      borderRadius: AppBorderRadius.r8,
                    ),
                    child: Icon(Icons.edit_outlined,
                        size: 15.r, color: AppColors.primaryDeep),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

// ── Shared small widgets ───────────────────────────────────────────────────────

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
          Text(value,
              style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 13),
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textDark)),
          if (valueSuffix != null) ...[
            const SizedBox(width: 4),
            Text(valueSuffix!, style: const TextStyle(fontSize: 13)),
          ],
        ]),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
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
            child: Text(label,
                style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 13),
                    color: AppColors.textLight)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textCharcoal)),
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
  });
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w600,
                color: AppColors.textMid)),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 14),
              color: AppColors.textDark),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.scaffoldBg,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            border: OutlineInputBorder(
                borderRadius: AppBorderRadius.r8,
                borderSide: BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: AppBorderRadius.r8,
                borderSide: BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: AppBorderRadius.r8,
                borderSide:
                    BorderSide(color: AppColors.primaryDeep, width: 1.5)),
          ),
        ),
      ],
    );
  }
}

class _PaymentChip extends StatelessWidget {
  const _PaymentChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDeep : AppColors.scaffoldBg,
          borderRadius: AppBorderRadius.r8,
          border: Border.all(
            color: selected ? AppColors.primaryDeep : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(label,
            style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 12),
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.white : AppColors.textMid)),
      ),
    );
  }
}
