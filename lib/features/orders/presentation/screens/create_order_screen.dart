import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../branches/data/model/branch_model.dart';
import '../../../branches/presentation/cubits/branches_cubit.dart';
import '../../../customers/data/model/customer.dart';
import '../../../customers/data/model/customer_address.dart';
import '../../../customers/presentation/cubits/customers_cubit.dart';
import '../../../delivery_zones/data/model/delivery_zone_model.dart';
import '../../../delivery_zones/presentation/cubits/delivery_zones_cubit.dart';
import '../../../products/data/model/product.dart';
import '../../../products/data/model/product_variant.dart';
import '../../../products/presentation/cubits/products_cubit.dart';
import '../cubits/orders_cubit.dart';
import '../../data/model/order_model.dart';

// Holds a selected product entry in the cart
class _CartEntry {
  final Product product;
  ProductVariant? variant;
  int quantity;

  _CartEntry(this.product) : variant = null, quantity = 1;

  double get effectivePrice => variant?.price ?? product.price;
  double get subtotal => effectivePrice * quantity;
}

// Holds a custom (non-catalogue) item added to the cart
class _CustomItem {
  final String key;
  String name;
  double price;
  int quantity;

  _CustomItem({required this.key, required this.name, required this.price})
      : quantity = 1;

  double get subtotal => price * quantity;
}

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key, this.preselectedCustomer});
  final Customer? preselectedCustomer;

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  static const _tag = 'CreateOrderScreen';

  int _step = 0;

  // Step 0
  Customer? _selectedCustomer;
  final _newNameCtrl = TextEditingController();
  final _newPhoneCtrl = TextEditingController();
  final _customerSearchCtrl = TextEditingController();

  // Step 1
  final Map<String, _CartEntry> _cart = {};
  final List<_CustomItem> _customItems = [];
  int _customItemCounter = 0;
  final _productSearchCtrl = TextEditingController();
  String _productFilter = '';

  // Step 2
  DeliveryZoneModel? _selectedZone;
  BranchModel? _selectedBranch;
  CustomerAddress? _selectedAddress;
  double _discount = 0;
  final _discountCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();
  String _paymentMethod = 'cash';
  OrderType _orderType = OrderType.normal;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedCustomer != null) {
      _selectedCustomer = widget.preselectedCustomer;
      _step = 1;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productsCubit = context.read<ProductsCubit>();
      if (productsCubit.state.status == ProductsStatus.initial) {
        productsCubit.load();
      }
      context.read<DeliveryZonesCubit>().load();
      context.read<BranchesCubit>().load();
      if (widget.preselectedCustomer == null) {
        context.read<CustomersCubit>().load();
      }
    });
  }

  @override
  void dispose() {
    _newNameCtrl.dispose();
    _newPhoneCtrl.dispose();
    _customerSearchCtrl.dispose();
    _productSearchCtrl.dispose();
    _discountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _subtotal =>
      _cart.values.fold(0.0, (sum, e) => sum + e.subtotal) +
      _customItems.fold(0.0, (sum, e) => sum + e.subtotal);

  double get _deliveryFee => _selectedZone?.userPaidDeliveryFees ?? 0;

  double get _total => (_subtotal + _deliveryFee - _discount).clamp(0, double.infinity);

  void _advance() {
    if (_step == 0 && _selectedCustomer != null) {
      context.read<CustomersCubit>().loadCustomerAddresses(_selectedCustomer!.id);
    }
    if (_step < 3) setState(() => _step++);
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.of(context).pop();
    }
  }

  bool get _canAdvance {
    switch (_step) {
      case 0: return _selectedCustomer != null;
      case 1: return _cart.isNotEmpty || _customItems.isNotEmpty;
      case 2: return _selectedBranch != null;
      case 3: return true;
      default: return false;
    }
  }

  void _placeOrder(BuildContext context) {
    AppLogger.i(_tag, 'placeOrder customer=${_selectedCustomer?.id} items=${_cart.length}');
    final orderData = {
      'branch_id':        _selectedBranch!.id,
      'customer_id':      _selectedCustomer?.id,
      'status':           'confirmed',
      'total_price':      _total,
      'user_paid_delivery_fees': _deliveryFee,
      'driver_delivery_cost':    _selectedZone?.deliveryFeesPaidToDriver ?? 0,
      if (_selectedZone != null) 'zone_name': _selectedZone!.name,
      if (_selectedZone != null) 'zone_id':   _selectedZone!.id,
      'service_fee':             0,
      'promo_discount':   _discount,
      'loyalty_discount': 0,
      'delivery_address': _selectedAddress?.fullAddress ?? 'Manual Order',
      'notes':            _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      'payment_method':   _paymentMethod,
      'points_earned':    0,
      'points_redeemed':  0,
      'order_type':       _orderType.value,
    };

    final items = [
      ..._cart.values.map((e) => {
        'product_id':   e.product.id,
        'product_name': e.product.name,
        'quantity':     e.quantity,
        'unit_price':   e.effectivePrice,
        'subtotal':     e.subtotal,
        if (e.variant != null) 'variant_id': e.variant!.id,
      }),
      ..._customItems.map((e) => {
        'product_id':   null,
        'product_name': e.name,
        'quantity':     e.quantity,
        'unit_price':   e.price,
        'subtotal':     e.subtotal,
      }),
    ];

    context.read<OrdersCubit>().createOrder(
      orderData: orderData,
      items: items,
      branchId: _selectedBranch!.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrdersCubit, OrdersState>(
      listenWhen: (p, c) => c.createStatus != p.createStatus,
      listener: (context, state) {
        if (state.createStatus == OrdersCreateStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'Order placed successfully!',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
            ),
            backgroundColor: AppColors.primaryMid,
          ));
          Navigator.of(context).pop();
        } else if (state.createStatus == OrdersCreateStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              state.createError ?? 'Failed to place order',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
            ),
            backgroundColor: AppColors.error,
          ));
        }
      },
      child: PopScope(
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && _step > 0) {
            setState(() => _step--);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDeep,
            foregroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, size: 22.r),
              onPressed: _back,
            ),
            title: Text(
              'New Order',
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 18),
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(6),
              child: LinearProgressIndicator(
                value: (_step + 1) / 4,
                backgroundColor: AppColors.primaryMid,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.white),
                minHeight: 4,
              ),
            ),
          ),
          body: Column(
            children: [
              _StepLabel(step: _step),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: _buildStep(context),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _BottomBar(
            step: _step,
            canAdvance: _canAdvance,
            onBack: _back,
            onNext: _step == 3
                ? () => _placeOrder(context)
                : _advance,
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_step) {
      case 0: return _Step0SelectCustomer(
          selectedCustomer: _selectedCustomer,
          searchCtrl: _customerSearchCtrl,
          newNameCtrl: _newNameCtrl,
          newPhoneCtrl: _newPhoneCtrl,
          onSelect: (c) => setState(() => _selectedCustomer = c),
          onCreateNew: () async {
            final name = _newNameCtrl.text.trim();
            if (name.isEmpty) return;
            final cubit = context.read<CustomersCubit>();
            final customer = await cubit.createCustomer(
              name: name,
              phone: _newPhoneCtrl.text.trim().isEmpty
                  ? null
                  : _newPhoneCtrl.text.trim(),
            );
            setState(() => _selectedCustomer = customer);
          },
        );
      case 1: return _Step1SelectProducts(
          cart: _cart,
          customItems: _customItems,
          filterText: _productFilter,
          searchCtrl: _productSearchCtrl,
          onFilterChanged: (v) => setState(() => _productFilter = v),
          onCartChanged: () => setState(() {}),
          onAddCustomItem: (name, price) {
            setState(() {
              _customItems.add(_CustomItem(
                key: 'custom_${_customItemCounter++}',
                name: name,
                price: price,
              ));
            });
          },
          onRemoveCustomItem: (key) {
            setState(() => _customItems.removeWhere((e) => e.key == key));
          },
          onCustomItemQtyChanged: (key, delta) {
            setState(() {
              final item = _customItems.firstWhere((e) => e.key == key);
              final newQty = item.quantity + delta;
              if (newQty <= 0) {
                _customItems.removeWhere((e) => e.key == key);
              } else {
                item.quantity = newQty;
              }
            });
          },
        );
      case 2: return _Step2OrderDetails(
          selectedZone: _selectedZone,
          selectedBranch: _selectedBranch,
          selectedAddress: _selectedAddress,
          discount: _discount,
          discountCtrl: _discountCtrl,
          notesCtrl: _notesCtrl,
          paymentMethod: _paymentMethod,
          orderType: _orderType,
          subtotal: _subtotal,
          customerId: _selectedCustomer?.id,
          onZoneChanged: (z) => setState(() => _selectedZone = z),
          onBranchChanged: (b) => setState(() => _selectedBranch = b),
          onAddressChanged: (a) => setState(() => _selectedAddress = a),
          onDiscountChanged: (v) => setState(() => _discount = v),
          onPaymentChanged: (v) => setState(() => _paymentMethod = v),
          onOrderTypeChanged: (t) => setState(() => _orderType = t),
        );
      case 3: return _Step3Confirm(
          customer: _selectedCustomer,
          cart: _cart,
          customItems: _customItems,
          zone: _selectedZone,
          branch: _selectedBranch,
          address: _selectedAddress,
          discount: _discount,
          notes: _notesCtrl.text.trim(),
          paymentMethod: _paymentMethod,
          subtotal: _subtotal,
          deliveryFee: _deliveryFee,
          total: _total,
        );
      default: return const SizedBox.shrink();
    }
  }
}

// ── Step label bar ────────────────────────────────────────────────────────────

class _StepLabel extends StatelessWidget {
  const _StepLabel({required this.step});
  final int step;

  static const _labels = [
    'Customer',
    'Products',
    'Details',
    'Confirm',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: List.generate(_labels.length, (i) {
          final active = i == step;
          final done = i < step;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 28.r,
                        height: 28.r,
                        decoration: BoxDecoration(
                          color: done
                              ? AppColors.primaryMid
                              : active
                                  ? AppColors.primaryDeep
                                  : AppColors.scaffoldBg,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: done || active
                                ? AppColors.primaryDeep
                                : AppColors.border,
                          ),
                        ),
                        child: Center(
                          child: done
                              ? Icon(Icons.check_rounded,
                                  size: 14.r, color: AppColors.white)
                              : Text(
                                  '${i + 1}',
                                  style: GoogleFonts.nunito(
                                    fontSize: Responsive.sp(context, 12),
                                    fontWeight: FontWeight.w700,
                                    color: active
                                        ? AppColors.white
                                        : AppColors.textLight,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _labels[i],
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 10),
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: active
                              ? AppColors.primaryDeep
                              : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < _labels.length - 1)
                  Container(
                    width: 16.w,
                    height: 1,
                    color: i < step ? AppColors.primaryMid : AppColors.border,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Bottom navigation bar ────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.step,
    required this.canAdvance,
    required this.onBack,
    required this.onNext,
  });
  final int step;
  final bool canAdvance;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        final loading = state.createStatus == OrdersCreateStatus.loading;
        return Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 28.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              if (step > 0) ...[
                OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textMid,
                    side: BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: AppBorderRadius.r12),
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 14.h),
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 14),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: SizedBox(
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: (canAdvance && !loading) ? onNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDeep,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.border,
                      shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.r12),
                      elevation: 0,
                    ),
                    child: loading
                        ? SizedBox(
                            width: 22.r,
                            height: 22.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            step == 3 ? 'Place Order' : 'Next',
                            style: GoogleFonts.nunito(
                              fontSize: Responsive.sp(context, 15),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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

// ═══════════════════════════════════════════════════════════════════════════════
// STEP 0 — Select Customer
// ═══════════════════════════════════════════════════════════════════════════════

class _Step0SelectCustomer extends StatelessWidget {
  const _Step0SelectCustomer({
    required this.selectedCustomer,
    required this.searchCtrl,
    required this.newNameCtrl,
    required this.newPhoneCtrl,
    required this.onSelect,
    required this.onCreateNew,
  });
  final Customer? selectedCustomer;
  final TextEditingController searchCtrl;
  final TextEditingController newNameCtrl;
  final TextEditingController newPhoneCtrl;
  final void Function(Customer) onSelect;
  final VoidCallback onCreateNew;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        if (selectedCustomer != null) ...[
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.primaryMist,
              borderRadius: AppBorderRadius.r12,
              border: Border.all(color: AppColors.primaryLight),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: AppColors.primaryMid, size: 20.r),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    '${selectedCustomer!.displayName}${selectedCustomer!.phone != null ? " · ${selectedCustomer!.phone}" : ""}',
                    style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 14),
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => onSelect(selectedCustomer!),
                  child: Icon(Icons.close_rounded,
                      size: 18.r, color: AppColors.textLight),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
        ],
        _FormField(
          controller: searchCtrl,
          label: 'Search Existing Customer',
          hint: 'Name, phone, or email…',
          prefixIcon: Icons.search_rounded,
          onChanged: (q) => context.read<CustomersCubit>().search(q),
        ),
        SizedBox(height: 8.h),
        BlocBuilder<CustomersCubit, CustomersState>(
          builder: (context, state) {
            if (state.status == CustomersStatus.loading) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                    color: AppColors.primaryDeep),
              ));
            }
            if (state.customers.isEmpty) return const SizedBox.shrink();
            return Column(
              children: state.customers.take(8).map((c) {
                final selected = selectedCustomer?.id == c.id;
                return GestureDetector(
                  onTap: () => onSelect(c),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 6.h),
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryMist
                          : AppColors.white,
                      borderRadius: AppBorderRadius.r12,
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryMid
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36.r,
                          height: 36.r,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryMist,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              c.initials,
                              style: GoogleFonts.nunito(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDeep,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.displayName,
                                style: GoogleFonts.nunito(
                                  fontSize: Responsive.sp(context, 13),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              if (c.phone != null)
                                Text(
                                  c.phone!,
                                  style: GoogleFonts.nunito(
                                    fontSize: Responsive.sp(context, 12),
                                    color: AppColors.textLight,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (selected)
                          Icon(Icons.check_circle_rounded,
                              size: 18.r, color: AppColors.primaryMid),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        SizedBox(height: 20.h),
        Divider(color: AppColors.border),
        SizedBox(height: 12.h),
        Text(
          'Or Create New Customer',
          style: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 14),
            fontWeight: FontWeight.w700,
            color: AppColors.textCharcoal,
          ),
        ),
        SizedBox(height: 12.h),
        _FormField(
          controller: newNameCtrl,
          label: 'Full Name',
          hint: 'Customer full name',
        ),
        SizedBox(height: 10.h),
        _FormField(
          controller: newPhoneCtrl,
          label: 'Phone (optional)',
          hint: '01XXXXXXXXX',
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 46.h,
          child: OutlinedButton(
            onPressed: onCreateNew,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryDeep,
              side: BorderSide(color: AppColors.primaryMid),
              shape: RoundedRectangleBorder(
                  borderRadius: AppBorderRadius.r12),
            ),
            child: Text(
              'Use as Customer',
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 14),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STEP 1 — Select Products
// ═══════════════════════════════════════════════════════════════════════════════

class _Step1SelectProducts extends StatelessWidget {
  const _Step1SelectProducts({
    required this.cart,
    required this.customItems,
    required this.filterText,
    required this.searchCtrl,
    required this.onFilterChanged,
    required this.onCartChanged,
    required this.onAddCustomItem,
    required this.onRemoveCustomItem,
    required this.onCustomItemQtyChanged,
  });
  final Map<String, _CartEntry> cart;
  final List<_CustomItem> customItems;
  final String filterText;
  final TextEditingController searchCtrl;
  final void Function(String) onFilterChanged;
  final VoidCallback onCartChanged;
  final void Function(String name, double price) onAddCustomItem;
  final void Function(String key) onRemoveCustomItem;
  final void Function(String key, int delta) onCustomItemQtyChanged;

  static String _variantLabel(Product product, ProductVariant variant) {
    final allValues = product.options.expand((o) => o.values).toList();
    final labels = variant.optionValueIds.map((id) {
      try { return allValues.firstWhere((v) => v.id == id).value; } catch (_) { return null; }
    }).whereType<String>().toList();
    return labels.isEmpty
        ? 'EGP ${variant.price.toStringAsFixed(0)}'
        : '${labels.join(' / ')} — EGP ${variant.price.toStringAsFixed(0)}';
  }

  void _showAddCustomItemSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 20, 16, MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Custom Item',
                style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark)),
            SizedBox(height: 16.h),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textDark),
              decoration: InputDecoration(
                labelText: 'Item Name *',
                hintText: 'e.g. Special Tray',
                labelStyle: GoogleFonts.nunito(color: AppColors.textLight),
                filled: true,
                fillColor: AppColors.scaffoldBg,
                border: OutlineInputBorder(
                    borderRadius: AppBorderRadius.r12,
                    borderSide: BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: AppBorderRadius.r12,
                    borderSide: BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: AppBorderRadius.r12,
                    borderSide:
                        BorderSide(color: AppColors.primaryMid, width: 2)),
              ),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: priceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textDark),
              decoration: InputDecoration(
                labelText: 'Price (EGP) *',
                hintText: '0.00',
                labelStyle: GoogleFonts.nunito(color: AppColors.textLight),
                filled: true,
                fillColor: AppColors.scaffoldBg,
                border: OutlineInputBorder(
                    borderRadius: AppBorderRadius.r12,
                    borderSide: BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: AppBorderRadius.r12,
                    borderSide: BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: AppBorderRadius.r12,
                    borderSide:
                        BorderSide(color: AppColors.primaryMid, width: 2)),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: StatefulBuilder(builder: (ctx, setSt) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDeep,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: AppBorderRadius.r12),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final price =
                        double.tryParse(priceCtrl.text.trim()) ?? 0;
                    if (name.isEmpty || price <= 0) return;
                    onAddCustomItem(name, price);
                    Navigator.of(sheetCtx).pop();
                  },
                  child: Text('Add to Order',
                      style: GoogleFonts.nunito(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        final allProducts =
            state.products.where((p) => p.isActive).toList();
        final filtered = filterText.isEmpty
            ? allProducts
            : allProducts
                .where((p) => p.name
                    .toLowerCase()
                    .contains(filterText.toLowerCase()))
                .toList();

        final hasSelected = cart.isNotEmpty || customItems.isNotEmpty;
        final subtotal =
            cart.values.fold(0.0, (s, e) => s + e.subtotal) +
                customItems.fold(0.0, (s, e) => s + e.subtotal);

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: _FormField(
                controller: searchCtrl,
                label: '',
                hint: 'Search products…',
                prefixIcon: Icons.search_rounded,
                onChanged: onFilterChanged,
              ),
            ),
            if (state.status == ProductsStatus.loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryDeep),
                ),
              )
            else
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                      16.w, 8.h, 16.w, hasSelected ? 120.h : 16.h),
                  children: [
                    // ── Selected items section ────────────────────────────
                    if (hasSelected) ...[
                      _SectionHeader(
                        label: 'Selected Items',
                        trailing: GestureDetector(
                          onTap: () => _showAddCustomItemSheet(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_circle_outline_rounded,
                                  size: 16.r, color: AppColors.primaryDeep),
                              SizedBox(width: 4.w),
                              Text('Custom Item',
                                  style: GoogleFonts.nunito(
                                    fontSize: Responsive.sp(context, 12),
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDeep,
                                  )),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      ...cart.values.map((entry) => _SelectedProductRow(
                            entry: entry,
                            variantLabel: entry.variant != null
                                ? _variantLabel(
                                    entry.product, entry.variant!)
                                : null,
                            onAdd: () {
                              entry.quantity++;
                              onCartChanged();
                            },
                            onRemove: () {
                              if (entry.quantity <= 1) {
                                cart.remove(entry.product.id);
                              } else {
                                entry.quantity--;
                              }
                              onCartChanged();
                            },
                            onVariantChanged: (v) {
                              entry.variant = v;
                              onCartChanged();
                            },
                          )),
                      ...customItems.map((item) => _CustomItemRow(
                            item: item,
                            onAdd: () =>
                                onCustomItemQtyChanged(item.key, 1),
                            onRemove: () =>
                                onCustomItemQtyChanged(item.key, -1),
                            onDelete: () => onRemoveCustomItem(item.key),
                          )),
                      SizedBox(height: 10.h),
                      Divider(color: AppColors.border),
                      SizedBox(height: 2.h),
                    ] else ...[
                      GestureDetector(
                        onTap: () => _showAddCustomItemSheet(context),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10.h),
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: AppBorderRadius.r12,
                            border: Border.all(color: AppColors.primaryLight),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.add_rounded,
                                  size: 18.r, color: AppColors.primaryDeep),
                              SizedBox(width: 8.w),
                              Text('Add Custom Item',
                                  style: GoogleFonts.nunito(
                                    fontSize: Responsive.sp(context, 13),
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDeep,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                    // ── All products ───────────────────────────────────────
                    if (hasSelected) ...[
                      _SectionHeader(label: 'All Products'),
                      SizedBox(height: 6.h),
                    ],
                    ...filtered.map((product) {
                      final entry = cart[product.id];
                      return _ProductRow(
                        product: product,
                        entry: entry,
                        variantLabelFn: (v) => _variantLabel(product, v),
                        onAdd: () {
                          if (!cart.containsKey(product.id)) {
                            cart[product.id] = _CartEntry(product);
                          } else {
                            cart[product.id]!.quantity++;
                          }
                          onCartChanged();
                        },
                        onRemove: () {
                          if (cart.containsKey(product.id)) {
                            if (cart[product.id]!.quantity <= 1) {
                              cart.remove(product.id);
                            } else {
                              cart[product.id]!.quantity--;
                            }
                            onCartChanged();
                          }
                        },
                        onVariantChanged: (v) {
                          if (cart.containsKey(product.id)) {
                            cart[product.id]!.variant = v;
                            onCartChanged();
                          }
                        },
                      );
                    }),
                  ],
                ),
              ),
            if (hasSelected)
              _CartSummaryBar(
                  cart: cart, customItems: customItems, subtotal: subtotal),
          ],
        );
      },
    );
  }
}

// Compact row for a product already in the selected section (top)
class _SelectedProductRow extends StatelessWidget {
  const _SelectedProductRow({
    required this.entry,
    required this.variantLabel,
    required this.onAdd,
    required this.onRemove,
    required this.onVariantChanged,
  });
  final _CartEntry entry;
  final String? variantLabel;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final void Function(ProductVariant?) onVariantChanged;

  @override
  Widget build(BuildContext context) {
    final activeVariants =
        entry.product.variants.where((v) => v.isActive).toList();
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.primaryMist,
        borderRadius: AppBorderRadius.r12,
        border: Border.all(color: AppColors.primaryLight, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.product.name,
                      style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 13),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                    Text(
                      variantLabel != null
                          ? '$variantLabel'
                          : 'EGP ${entry.effectivePrice.toStringAsFixed(2)}',
                      style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 11),
                        color: AppColors.primaryMid,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _QtyControl(
                quantity: entry.quantity,
                onAdd: onAdd,
                onRemove: onRemove,
              ),
            ],
          ),
          if (activeVariants.isNotEmpty) ...[
            SizedBox(height: 8.h),
            SizedBox(
              height: 32.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: activeVariants.map((v) {
                  final selected = entry.variant?.id == v.id;
                  return GestureDetector(
                    onTap: () => onVariantChanged(selected ? null : v),
                    child: Container(
                      margin: EdgeInsets.only(right: 6.w),
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primaryDeep
                            : AppColors.white,
                        borderRadius: AppBorderRadius.r8,
                        border: Border.all(
                          color: selected
                              ? AppColors.primaryDeep
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        _Step1SelectProducts._variantLabel(
                            entry.product, v),
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 11),
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppColors.white
                              : AppColors.textMid,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Row for a custom (non-catalogue) item in the selected section
class _CustomItemRow extends StatelessWidget {
  const _CustomItemRow({
    required this.item,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
  });
  final _CustomItem item;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r12,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: AppColors.scaffoldBg,
              borderRadius: AppBorderRadius.r8,
            ),
            child: Icon(Icons.edit_note_rounded,
                size: 18.r, color: AppColors.textLight),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 13),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'EGP ${item.price.toStringAsFixed(2)} — custom',
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 11),
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          _QtyControl(
            quantity: item.quantity,
            onAdd: onAdd,
            onRemove: onRemove,
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.delete_outline_rounded,
                size: 20.r, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.entry,
    required this.variantLabelFn,
    required this.onAdd,
    required this.onRemove,
    required this.onVariantChanged,
  });
  final Product product;
  final _CartEntry? entry;
  final String Function(ProductVariant) variantLabelFn;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final void Function(ProductVariant?) onVariantChanged;

  @override
  Widget build(BuildContext context) {
    final inCart = entry != null;
    final activeVariants =
        product.variants.where((v) => v.isActive).toList();

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r12,
        border: Border.all(
          color: inCart ? AppColors.primaryLight : AppColors.border,
          width: inCart ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: AppColors.primaryMist,
                  borderRadius: AppBorderRadius.r8,
                  image: product.primaryImage != null
                      ? DecorationImage(
                          image: NetworkImage(product.primaryImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: product.primaryImage == null
                    ? Icon(Icons.fastfood_rounded,
                        size: 22.r, color: AppColors.primaryLight)
                    : null,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 13),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'EGP ${(entry?.effectivePrice ?? product.price).toStringAsFixed(2)}',
                      style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 12),
                        color: AppColors.primaryMid,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (!inCart)
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDeep,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add_rounded,
                        size: 18.r, color: AppColors.white),
                  ),
                )
              else
                _QtyControl(
                  quantity: entry!.quantity,
                  onAdd: onAdd,
                  onRemove: onRemove,
                ),
            ],
          ),
          if (inCart && activeVariants.isNotEmpty) ...[
            SizedBox(height: 8.h),
            SizedBox(
              height: 32.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: activeVariants.map((v) {
                  final selected = entry!.variant?.id == v.id;
                  return GestureDetector(
                    onTap: () => onVariantChanged(selected ? null : v),
                    child: Container(
                      margin: EdgeInsets.only(right: 6.w),
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primaryDeep
                            : AppColors.scaffoldBg,
                        borderRadius: AppBorderRadius.r8,
                        border: Border.all(
                          color: selected
                              ? AppColors.primaryDeep
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        variantLabelFn(v),
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 11),
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppColors.white
                              : AppColors.textMid,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Shared qty +/- control
class _QtyControl extends StatelessWidget {
  const _QtyControl({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onRemove,
          child: Container(
            width: 30.r,
            height: 30.r,
            decoration: BoxDecoration(
              color: AppColors.scaffoldBg,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(Icons.remove_rounded,
                size: 16.r, color: AppColors.textMid),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '$quantity',
          style: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 15),
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            width: 30.r,
            height: 30.r,
            decoration: const BoxDecoration(
              color: AppColors.primaryDeep,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add_rounded,
                size: 16.r, color: AppColors.white),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, this.trailing});
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 11),
            fontWeight: FontWeight.w800,
            color: AppColors.textLight,
            letterSpacing: 0.8,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _CartSummaryBar extends StatelessWidget {
  const _CartSummaryBar({
    required this.cart,
    required this.customItems,
    required this.subtotal,
  });
  final Map<String, _CartEntry> cart;
  final List<_CustomItem> customItems;
  final double subtotal;

  @override
  Widget build(BuildContext context) {
    final itemCount = cart.values.fold(0, (s, e) => s + e.quantity) +
        customItems.fold(0, (s, e) => s + e.quantity);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primaryDeep,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeep.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28.r,
            height: 28.r,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$itemCount',
                style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 12),
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDeep,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Cart: $itemCount item${itemCount == 1 ? '' : 's'}',
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 13),
                color: AppColors.primaryPale,
              ),
            ),
          ),
          Text(
            'Subtotal: EGP ${subtotal.toStringAsFixed(2)}',
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 14),
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STEP 2 — Order Details
// ═══════════════════════════════════════════════════════════════════════════════

class _Step2OrderDetails extends StatefulWidget {
  const _Step2OrderDetails({
    required this.selectedZone,
    required this.selectedBranch,
    required this.selectedAddress,
    required this.discount,
    required this.discountCtrl,
    required this.notesCtrl,
    required this.paymentMethod,
    required this.orderType,
    required this.subtotal,
    required this.customerId,
    required this.onZoneChanged,
    required this.onBranchChanged,
    required this.onAddressChanged,
    required this.onDiscountChanged,
    required this.onPaymentChanged,
    required this.onOrderTypeChanged,
  });
  final DeliveryZoneModel? selectedZone;
  final BranchModel? selectedBranch;
  final CustomerAddress? selectedAddress;
  final double discount;
  final TextEditingController discountCtrl;
  final TextEditingController notesCtrl;
  final String paymentMethod;
  final OrderType orderType;
  final double subtotal;
  final String? customerId;
  final void Function(DeliveryZoneModel?) onZoneChanged;
  final void Function(BranchModel?) onBranchChanged;
  final void Function(CustomerAddress?) onAddressChanged;
  final void Function(double) onDiscountChanged;
  final void Function(String) onPaymentChanged;
  final void Function(OrderType) onOrderTypeChanged;

  @override
  State<_Step2OrderDetails> createState() => _Step2OrderDetailsState();
}

class _Step2OrderDetailsState extends State<_Step2OrderDetails> {
  bool _showAddressForm = false;
  bool _savingAddress = false;
  final _addrLabelCtrl = TextEditingController();
  final _addrStreetCtrl = TextEditingController();
  final _addrBuildingCtrl = TextEditingController();
  final _addrFloorCtrl = TextEditingController();
  final _addrAptCtrl = TextEditingController();
  final _addrLandmarkCtrl = TextEditingController();

  @override
  void dispose() {
    _addrLabelCtrl.dispose();
    _addrStreetCtrl.dispose();
    _addrBuildingCtrl.dispose();
    _addrFloorCtrl.dispose();
    _addrAptCtrl.dispose();
    _addrLandmarkCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAddress(BuildContext context) async {
    final street = _addrStreetCtrl.text.trim();
    if (street.isEmpty || widget.customerId == null) return;
    setState(() => _savingAddress = true);
    final addr = await context.read<CustomersCubit>().createAddress(
          customerId: widget.customerId!,
          label: _addrLabelCtrl.text.trim().isEmpty
              ? null
              : _addrLabelCtrl.text.trim(),
          street: street,
          building: _addrBuildingCtrl.text.trim().isEmpty
              ? null
              : _addrBuildingCtrl.text.trim(),
          floor: _addrFloorCtrl.text.trim().isEmpty
              ? null
              : _addrFloorCtrl.text.trim(),
          apartment: _addrAptCtrl.text.trim().isEmpty
              ? null
              : _addrAptCtrl.text.trim(),
          landmark: _addrLandmarkCtrl.text.trim().isEmpty
              ? null
              : _addrLandmarkCtrl.text.trim(),
        );
    if (addr != null) {
      widget.onAddressChanged(addr);
      for (final c in [
        _addrLabelCtrl, _addrStreetCtrl, _addrBuildingCtrl,
        _addrFloorCtrl, _addrAptCtrl, _addrLandmarkCtrl,
      ]) { c.clear(); }
      setState(() { _showAddressForm = false; _savingAddress = false; });
    } else {
      setState(() => _savingAddress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliveryFee = widget.selectedZone?.userPaidDeliveryFees ?? 0;
    final total =
        (widget.subtotal + deliveryFee - widget.discount).clamp(0, double.infinity);

    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        // Branch selector
        Text('Branch *',
            style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w700,
                color: AppColors.textMid)),
        SizedBox(height: 6.h),
        BlocBuilder<BranchesCubit, BranchesState>(
          builder: (context, state) {
            final branches =
                state.branches.where((b) => b.isActive).toList();
            return Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: AppBorderRadius.r12,
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<BranchModel>(
                  value: widget.selectedBranch,
                  isExpanded: true,
                  hint: Text('Select branch',
                      style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 13),
                          color: AppColors.textLight)),
                  items: branches
                      .map((b) => DropdownMenuItem(
                            value: b,
                            child: Text(b.name,
                                style: GoogleFonts.nunito(
                                    fontSize: Responsive.sp(context, 13),
                                    color: AppColors.textDark)),
                          ))
                      .toList(),
                  onChanged: widget.onBranchChanged,
                ),
              ),
            );
          },
        ),
        SizedBox(height: 14.h),
        // Customer address picker
        BlocBuilder<CustomersCubit, CustomersState>(
          builder: (context, cusState) {
            final addresses = cusState.customerAddresses;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Delivery Address',
                        style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 13),
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMid)),
                    const Spacer(),
                    if (widget.customerId != null)
                      GestureDetector(
                        onTap: () => setState(
                            () => _showAddressForm = !_showAddressForm),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showAddressForm
                                  ? Icons.close_rounded
                                  : Icons.add_rounded,
                              size: 16.r,
                              color: AppColors.primaryDeep,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _showAddressForm ? 'Cancel' : 'New Address',
                              style: GoogleFonts.nunito(
                                  fontSize: Responsive.sp(context, 12),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDeep),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 6.h),
                // Existing addresses
                ...addresses.map((addr) {
                  final selected = widget.selectedAddress?.id == addr.id;
                  return GestureDetector(
                    onTap: () =>
                        widget.onAddressChanged(selected ? null : addr),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 6.h),
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primaryMist
                            : AppColors.white,
                        borderRadius: AppBorderRadius.r12,
                        border: Border.all(
                          color: selected
                              ? AppColors.primaryMid
                              : AppColors.border,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            addr.isDefault
                                ? Icons.home_rounded
                                : Icons.location_on_outlined,
                            size: 18.r,
                            color: selected
                                ? AppColors.primaryDeep
                                : AppColors.textLight,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(addr.displayTitle,
                                    style: GoogleFonts.nunito(
                                        fontSize:
                                            Responsive.sp(context, 13),
                                        fontWeight: FontWeight.w700,
                                        color: selected
                                            ? AppColors.primaryDeep
                                            : AppColors.textDark)),
                                if (addr.displaySubtitle.isNotEmpty)
                                  Text(addr.displaySubtitle,
                                      style: GoogleFonts.nunito(
                                          fontSize:
                                              Responsive.sp(context, 11),
                                          color: AppColors.textLight)),
                              ],
                            ),
                          ),
                          if (selected)
                            Icon(Icons.check_circle_rounded,
                                size: 18.r, color: AppColors.primaryMid),
                        ],
                      ),
                    ),
                  );
                }),
                // New address form
                if (_showAddressForm) ...[
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppBorderRadius.r12,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('New Address',
                            style: GoogleFonts.nunito(
                                fontSize: Responsive.sp(context, 13),
                                fontWeight: FontWeight.w700,
                                color: AppColors.textCharcoal)),
                        SizedBox(height: 10.h),
                        _AddrField(ctrl: _addrLabelCtrl, label: 'Label', hint: 'e.g. Home, Work'),
                        SizedBox(height: 8.h),
                        _AddrField(ctrl: _addrStreetCtrl, label: 'Street *', hint: 'Street name / area'),
                        SizedBox(height: 8.h),
                        Row(children: [
                          Expanded(child: _AddrField(ctrl: _addrBuildingCtrl, label: 'Building', hint: 'No.')),
                          SizedBox(width: 8.w),
                          Expanded(child: _AddrField(ctrl: _addrFloorCtrl, label: 'Floor', hint: 'No.')),
                          SizedBox(width: 8.w),
                          Expanded(child: _AddrField(ctrl: _addrAptCtrl, label: 'Apt', hint: 'No.')),
                        ]),
                        SizedBox(height: 8.h),
                        _AddrField(ctrl: _addrLandmarkCtrl, label: 'Landmark', hint: 'Near…'),
                        SizedBox(height: 12.h),
                        SizedBox(
                          width: double.infinity,
                          height: 44.h,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDeep,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: AppBorderRadius.r12),
                              elevation: 0,
                            ),
                            onPressed: _savingAddress
                                ? null
                                : () => _saveAddress(context),
                            child: _savingAddress
                                ? SizedBox(
                                    width: 18.r,
                                    height: 18.r,
                                    child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.white))
                                : Text('Save & Use Address',
                                    style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 8.h),
              ],
            );
          },
        ),
        // Delivery zone
        Text('Delivery Zone',
            style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w700,
                color: AppColors.textMid)),
        SizedBox(height: 6.h),
        BlocBuilder<DeliveryZonesCubit, DeliveryZonesState>(
          builder: (context, zoneState) {
            // Show zones belonging to the selected branch, plus unassigned zones.
            // If no branch is selected yet, show all active zones.
            final allActive = zoneState.zones.where((z) => z.isActive).toList();
            final zones = widget.selectedBranch == null
                ? allActive
                : allActive
                    .where((z) =>
                        z.branchId == null ||
                        z.branchId == widget.selectedBranch!.id)
                    .toList();

            // If the currently selected zone is no longer valid, clear it.
            final currentZoneValid =
                widget.selectedZone == null || zones.any((z) => z.id == widget.selectedZone!.id);

            return Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: AppBorderRadius.r12,
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<DeliveryZoneModel>(
                  value: currentZoneValid ? widget.selectedZone : null,
                  isExpanded: true,
                  hint: Text('Select delivery zone',
                      style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 13),
                          color: AppColors.textLight)),
                  items: [
                    DropdownMenuItem<DeliveryZoneModel>(
                      value: null,
                      child: Text('No delivery zone',
                          style: GoogleFonts.nunito(
                              fontSize: Responsive.sp(context, 13),
                              color: AppColors.textLight)),
                    ),
                    ...zones.map((z) => DropdownMenuItem(
                          value: z,
                          child: Text(
                              '${z.name} — EGP ${z.userPaidDeliveryFees.toStringAsFixed(0)}',
                              style: GoogleFonts.nunito(
                                  fontSize: Responsive.sp(context, 13),
                                  color: AppColors.textDark)),
                        )),
                  ],
                  onChanged: (zone) {
                    widget.onZoneChanged(zone);
                    // Auto-set branch from zone when the zone has a branch assignment.
                    if (zone?.branchId != null) {
                      final branch = context
                          .read<BranchesCubit>()
                          .state
                          .branches
                          .firstWhere(
                            (b) => b.id == zone!.branchId,
                            orElse: () => widget.selectedBranch!,
                          );
                      widget.onBranchChanged(branch);
                    }
                  },
                ),
              ),
            );
          },
        ),
        SizedBox(height: 14.h),
        _FormField(
          controller: widget.discountCtrl,
          label: 'Discount (EGP)',
          hint: '0',
          keyboardType: TextInputType.number,
          onChanged: (v) {
            final parsed = double.tryParse(v) ?? 0;
            widget.onDiscountChanged(parsed);
          },
        ),
        SizedBox(height: 14.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Notes',
                style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 13),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMid)),
            SizedBox(height: 6.h),
            TextField(
              controller: widget.notesCtrl,
              maxLines: 3,
              style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 13),
                  color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Any special instructions…',
                hintStyle: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 13),
                    color: AppColors.textLight),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                    borderRadius: AppBorderRadius.r12,
                    borderSide: BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: AppBorderRadius.r12,
                    borderSide: BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: AppBorderRadius.r12,
                    borderSide:
                        BorderSide(color: AppColors.primaryMid, width: 2)),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        Text('Order Type',
            style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w700,
                color: AppColors.textMid)),
        SizedBox(height: 6.h),
        Row(
          children: [
            _PaymentOption(
              label: 'Normal',
              icon: Icons.receipt_long_outlined,
              value: 'normal',
              selected: widget.orderType == OrderType.normal,
              onTap: () => widget.onOrderTypeChanged(OrderType.normal),
            ),
            SizedBox(width: 10.w),
            _PaymentOption(
              label: 'Compensation',
              icon: Icons.volunteer_activism_outlined,
              value: 'compensation',
              selected: widget.orderType == OrderType.compensation,
              onTap: () => widget.onOrderTypeChanged(OrderType.compensation),
              activeColor: Colors.orange.shade700,
            ),
          ],
        ),
        if (widget.orderType == OrderType.compensation) ...[
          SizedBox(height: 6.h),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: AppBorderRadius.r8,
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.orange.shade700),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Compensation: only shipping fees are charged to the driver. Cart/service fees are zero.',
                    style: GoogleFonts.nunito(fontSize: 11, color: Colors.orange.shade800),
                  ),
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: 14.h),
        Text('Payment Method',
            style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w700,
                color: AppColors.textMid)),
        SizedBox(height: 6.h),
        Row(
          children: [
            _PaymentOption(
              label: 'Cash',
              icon: Icons.money_rounded,
              value: 'cash',
              selected: widget.paymentMethod == 'cash',
              onTap: () => widget.onPaymentChanged('cash'),
            ),
            SizedBox(width: 10.w),
            _PaymentOption(
              label: 'Instapay',
              icon: Icons.mobile_friendly_rounded,
              value: 'instapay',
              selected: widget.paymentMethod == 'instapay',
              onTap: () => widget.onPaymentChanged('instapay'),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppBorderRadius.r12,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _SummaryRow(
                  'Subtotal', 'EGP ${widget.subtotal.toStringAsFixed(2)}'),
              _SummaryRow(
                  'Delivery Fee', 'EGP ${deliveryFee.toStringAsFixed(2)}'),
              if (widget.discount > 0)
                _SummaryRow('Discount',
                    '- EGP ${widget.discount.toStringAsFixed(2)}',
                    valueColor: AppColors.error),
              Divider(color: AppColors.border, height: 16.h),
              _SummaryRow(
                'Total',
                'EGP ${(total as double).toStringAsFixed(2)}',
                labelBold: true,
                valueBold: true,
                valueColor: AppColors.primaryDeep,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Compact text field used inside the new-address form
class _AddrField extends StatelessWidget {
  const _AddrField(
      {required this.ctrl, required this.label, required this.hint});
  final TextEditingController ctrl;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      style: GoogleFonts.nunito(
          fontSize: Responsive.sp(context, 13), color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 12), color: AppColors.textLight),
        isDense: true,
        filled: true,
        fillColor: AppColors.scaffoldBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: AppBorderRadius.r8,
            borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: AppBorderRadius.r8,
            borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: AppBorderRadius.r8,
            borderSide: BorderSide(color: AppColors.primaryMid, width: 2)),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
    this.activeColor,
  });
  final String label;
  final IconData icon;
  final String value;
  final bool selected;
  final VoidCallback onTap;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final selColor = activeColor ?? AppColors.primaryDeep;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: selected ? selColor : AppColors.white,
            borderRadius: AppBorderRadius.r12,
            border: Border.all(
              color: selected ? selColor : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 20.r,
                  color:
                      selected ? AppColors.white : AppColors.textMid),
              SizedBox(height: 4.h),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 13),
                  fontWeight: FontWeight.w700,
                  color:
                      selected ? AppColors.white : AppColors.textMid,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STEP 3 — Confirm
// ═══════════════════════════════════════════════════════════════════════════════

class _Step3Confirm extends StatelessWidget {
  const _Step3Confirm({
    required this.customer,
    required this.cart,
    required this.customItems,
    required this.zone,
    required this.branch,
    required this.address,
    required this.discount,
    required this.notes,
    required this.paymentMethod,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });
  final Customer? customer;
  final Map<String, _CartEntry> cart;
  final List<_CustomItem> customItems;
  final DeliveryZoneModel? zone;
  final BranchModel? branch;
  final CustomerAddress? address;
  final double discount;
  final String notes;
  final String paymentMethod;
  final double subtotal;
  final double deliveryFee;
  final double total;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        Text(
          'Order Summary',
          style: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 18),
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 14.h),
        // Customer
        _ConfirmCard(
          title: 'Customer',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customer?.displayName ?? 'Unknown',
                style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 14),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              if (customer?.phone != null)
                Text(
                  customer!.phone!,
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 13),
                    color: AppColors.textMid,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        // Branch & zone
        _ConfirmCard(
          title: 'Delivery Info',
          child: Column(
            children: [
              _SummaryRow('Branch', branch?.name ?? '—'),
              _SummaryRow('Zone', zone?.name ?? 'No zone'),
              if (address != null)
                _SummaryRow('Address', address!.displayTitle),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        // Items
        _ConfirmCard(
          title: 'Items (${cart.length + customItems.length})',
          child: Column(
            children: [
              ...cart.values.map((e) {
                final variantLabel = e.variant != null
                    ? _Step1SelectProducts._variantLabel(e.product, e.variant!)
                    : null;
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          variantLabel != null
                              ? '${e.product.name} ($variantLabel)'
                              : e.product.name,
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 13),
                            color: AppColors.textCharcoal,
                          ),
                        ),
                      ),
                      Text(
                        '×${e.quantity}  EGP ${e.subtotal.toStringAsFixed(2)}',
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 13),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              ...customItems.map((e) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                e.name,
                                style: GoogleFonts.nunito(
                                  fontSize: Responsive.sp(context, 13),
                                  color: AppColors.textCharcoal,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: AppColors.scaffoldBg,
                                  borderRadius: AppBorderRadius.r8,
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  'custom',
                                  style: GoogleFonts.nunito(
                                    fontSize: Responsive.sp(context, 10),
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '×${e.quantity}  EGP ${e.subtotal.toStringAsFixed(2)}',
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 13),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        // Totals
        _ConfirmCard(
          title: 'Payment',
          child: Column(
            children: [
              _SummaryRow('Method', paymentMethod.toUpperCase()),
              _SummaryRow('Subtotal', 'EGP ${subtotal.toStringAsFixed(2)}'),
              _SummaryRow('Delivery', 'EGP ${deliveryFee.toStringAsFixed(2)}'),
              if (discount > 0)
                _SummaryRow(
                  'Discount',
                  '- EGP ${discount.toStringAsFixed(2)}',
                  valueColor: AppColors.error,
                ),
              Divider(color: AppColors.border, height: 12.h),
              _SummaryRow(
                'Total',
                'EGP ${total.toStringAsFixed(2)}',
                labelBold: true,
                valueBold: true,
                valueColor: AppColors.primaryDeep,
              ),
            ],
          ),
        ),
        if (notes.isNotEmpty) ...[
          SizedBox(height: 10.h),
          _ConfirmCard(
            title: 'Notes',
            child: Text(
              notes,
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 13),
                color: AppColors.textMid,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ConfirmCard extends StatelessWidget {
  const _ConfirmCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 12),
              fontWeight: FontWeight.w700,
              color: AppColors.textLight,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(
    this.label,
    this.value, {
    this.labelBold = false,
    this.valueBold = false,
    this.valueColor,
  });
  final String label;
  final String value;
  final bool labelBold;
  final bool valueBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 13),
              fontWeight: labelBold ? FontWeight.w700 : FontWeight.w500,
              color: AppColors.textMid,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 13),
              fontWeight: valueBold ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ?? AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.keyboardType,
    this.onChanged,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 13),
              fontWeight: FontWeight.w700,
              color: AppColors.textMid,
            ),
          ),
          SizedBox(height: 6.h),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
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
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18.r, color: AppColors.textLight)
                : null,
            filled: true,
            fillColor: AppColors.white,
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
