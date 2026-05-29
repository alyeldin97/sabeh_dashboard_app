import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import '../../../branches/presentation/cubits/branches_cubit.dart';
import '../../../categories/presentation/cubits/categories_cubit.dart';
import '../../data/model/product.dart';
import '../cubits/products_cubit.dart';

// ── Draft models for form state ───────────────────────────────────────────────

class _ValueDraft {
  final String tempId;
  final TextEditingController ctrl;
  _ValueDraft(this.tempId, [String text = '']) : ctrl = TextEditingController(text: text);
  void dispose() => ctrl.dispose();
}

class _OptionDraft {
  final String tempId;
  final TextEditingController nameCtrl;
  final List<_ValueDraft> values;
  _OptionDraft(this.tempId, [String name = ''])
      : nameCtrl = TextEditingController(text: name),
        values = [];
  void dispose() {
    nameCtrl.dispose();
    for (final v in values) { v.dispose(); }
  }
}

class _VariantDraft {
  final String tempId;
  final List<String> valueTempIds;
  final TextEditingController priceCtrl;
  final TextEditingController compareAtCtrl;
  bool isActive;
  final Map<String, TextEditingController> inventoryCtrl;

  _VariantDraft({
    required this.tempId,
    required this.valueTempIds,
    String basePrice = '',
    String compareAt = '',
    this.isActive = true,
    List<String> branchIds = const [],
    Map<String, int> existingInventory = const {},
  })  : priceCtrl = TextEditingController(text: basePrice),
        compareAtCtrl = TextEditingController(text: compareAt),
        inventoryCtrl = {
          for (final bId in branchIds)
            bId: TextEditingController(text: '${existingInventory[bId] ?? 0}'),
        };

  void dispose() {
    priceCtrl.dispose();
    compareAtCtrl.dispose();
    for (final c in inventoryCtrl.values) { c.dispose(); }
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product, this.branchId});
  final Product? product;
  final String? branchId;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  static int _tidCounter = 0;
  static String _nextTid() => 'T${++_tidCounter}';

  final _formKey = GlobalKey<FormState>();

  // Basic fields
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _compareAt;
  late final TextEditingController _sortOrder;
  late final TextEditingController _loyaltyPts;
  late ProductType _type;
  late bool _isActive;
  late bool _trackInventory;
  late bool _isBestSeller;

  // Weight config
  late final TextEditingController _minWeight;
  late final TextEditingController _maxWeight;
  late final TextEditingController _weightStep;
  late final TextEditingController _bulkDiscount;

  // COGS
  late final TextEditingController _cogsPercent;

  // Related products
  late List<String> _relatedProductIds;

  // Branches & categories
  late List<String> _selectedBranchIds;
  String? _selectedCategoryId;

  // Images
  late List<TextEditingController> _imageCtrls;

  // Product-level inventory (no-variant products)
  Map<String, TextEditingController> _productInventoryCtrls = {};

  // Options and variants
  final List<_OptionDraft> _options = [];
  final List<_VariantDraft> _variants = [];

  bool _saving = false;
  bool get _isEdit => widget.product != null;
  bool get _showBranchPicker => widget.branchId == null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    _name        = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _price       = TextEditingController(text: p != null ? p.price.toStringAsFixed(2) : '');
    _compareAt   = TextEditingController(text: p?.compareAtPrice != null ? p!.compareAtPrice!.toStringAsFixed(2) : '');
    _sortOrder   = TextEditingController(text: '${p?.sortOrder ?? 0}');
    _loyaltyPts  = TextEditingController(text: '${p?.loyaltyPoints ?? 0}');
    _type        = p?.type ?? ProductType.fixed;
    _isActive    = p?.isActive ?? true;
    _trackInventory = p?.trackInventory ?? false;
    _isBestSeller = p?.isBestSeller ?? false;

    _minWeight    = TextEditingController(text: '${p?.minWeightGrams ?? 250}');
    _maxWeight    = TextEditingController(text: '${p?.maxWeightGrams ?? 5000}');
    _weightStep   = TextEditingController(text: '${p?.weightStepGrams ?? 250}');
    _bulkDiscount = TextEditingController(text: p != null ? p.bulkDiscountPct.toStringAsFixed(1) : '0.0');
    _cogsPercent  = TextEditingController(text: p?.cogsPercent != null ? p!.cogsPercent!.toStringAsFixed(1) : '');
    _relatedProductIds = List<String>.from(p?.relatedProductIds ?? []);

    _selectedBranchIds  = widget.branchId != null ? [widget.branchId!] : List.of(p?.branchIds ?? []);
    _selectedCategoryId = p?.categoryIds.isNotEmpty == true ? p!.categoryIds.first : null;

    // Images
    if (p != null && p.images.isNotEmpty) {
      _imageCtrls = p.images.map((url) => TextEditingController(text: url)).toList();
    } else {
      _imageCtrls = [TextEditingController()];
    }

    // Load existing options, variants, and inventory (when editing)
    if (p != null) {
      if (p.options.isNotEmpty) {
        _loadExistingVariants(p);
      } else {
        // No variants — still need to populate product-level inventory
        _initProductInventoryCtrls(p.inventoryByBranch);
      }
    }
  }

  void _loadExistingVariants(Product p) {
    // Build option + value drafts with tempIds
    final valTempIdMap = <String, String>{}; // dbValueId → tempId

    for (final opt in p.options) {
      final optDraft = _OptionDraft(_nextTid(), opt.name);
      for (final val in opt.values) {
        final tid = _nextTid();
        valTempIdMap[val.id] = tid;
        optDraft.values.add(_ValueDraft(tid, val.value));
      }
      _options.add(optDraft);
    }

    // Load variant drafts
    final branchIds = _getAvailableBranchIds();
    for (final v in p.variants) {
      final valueTempIds = v.optionValueIds
          .map((dbId) => valTempIdMap[dbId] ?? '')
          .where((t) => t.isNotEmpty)
          .toList();

      _variants.add(_VariantDraft(
        tempId:          _nextTid(),
        valueTempIds:    valueTempIds,
        basePrice:       v.price.toStringAsFixed(2),
        compareAt:       v.compareAtPrice?.toStringAsFixed(2) ?? '',
        isActive:        v.isActive,
        branchIds:       branchIds,
        existingInventory: v.inventoryByBranch,
      ));
    }

    // Product-level inventory
    _initProductInventoryCtrls(p.inventoryByBranch);
  }

  List<String> _getAvailableBranchIds() {
    return context.read<BranchesCubit>().state.branches.map((b) => b.id).toList();
  }

  void _initProductInventoryCtrls([Map<String, int> existing = const {}]) {
    final branchIds = _getAvailableBranchIds();
    _productInventoryCtrls = {
      for (final bId in branchIds)
        bId: TextEditingController(text: '${existing[bId] ?? 0}'),
    };
  }

  @override
  void dispose() {
    _name.dispose(); _description.dispose(); _price.dispose();
    _compareAt.dispose(); _sortOrder.dispose(); _loyaltyPts.dispose();
    _minWeight.dispose(); _maxWeight.dispose(); _weightStep.dispose();
    _bulkDiscount.dispose(); _cogsPercent.dispose();
    for (final c in _imageCtrls) { c.dispose(); }
    for (final o in _options) { o.dispose(); }
    for (final v in _variants) { v.dispose(); }
    for (final c in _productInventoryCtrls.values) { c.dispose(); }
    super.dispose();
  }

  // ── Options ─────────────────────────────────────────────────────────────

  void _addOption() {
    setState(() {
      _options.add(_OptionDraft(_nextTid()));
      _regenerateVariants();
    });
  }

  void _removeOption(int optIdx) {
    setState(() {
      _options[optIdx].dispose();
      _options.removeAt(optIdx);
      _regenerateVariants();
    });
  }

  void _addValue(int optIdx) {
    setState(() {
      _options[optIdx].values.add(_ValueDraft(_nextTid()));
      _regenerateVariants();
    });
  }

  void _removeValue(int optIdx, int valIdx) {
    setState(() {
      _options[optIdx].values[valIdx].dispose();
      _options[optIdx].values.removeAt(valIdx);
      _regenerateVariants();
    });
  }

  void _regenerateVariants() {
    if (_options.isEmpty || _options.any((o) => o.values.isEmpty)) {
      for (final v in _variants) { v.dispose(); }
      _variants.clear();
      return;
    }

    // Cartesian product of tempIds
    List<List<String>> combos = [[]];
    for (final opt in _options) {
      combos = combos
          .expand((combo) => opt.values.map((v) => [...combo, v.tempId]))
          .toList();
    }

    final basePrice = _price.text;
    final branchIds = _getAvailableBranchIds();
    final newVariants = combos.map((tempIds) {
      // Preserve existing draft if same set of tempIds
      try {
        return _variants.firstWhere((v) => _listEq(v.valueTempIds, tempIds));
      } catch (_) {
        return _VariantDraft(
          tempId:       _nextTid(),
          valueTempIds: tempIds,
          basePrice:    basePrice,
          branchIds:    branchIds,
        );
      }
    }).toList();

    // Dispose removed
    for (final v in _variants) {
      if (!newVariants.any((nv) => nv.tempId == v.tempId)) v.dispose();
    }

    _variants.clear();
    _variants.addAll(newVariants);
  }

  bool _listEq(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  String _variantLabel(_VariantDraft v) {
    final parts = <String>[];
    for (var optIdx = 0; optIdx < _options.length; optIdx++) {
      if (optIdx < v.valueTempIds.length) {
        final tid = v.valueTempIds[optIdx];
        try {
          final val = _options[optIdx].values.firstWhere((vd) => vd.tempId == tid);
          final text = val.ctrl.text.trim();
          if (text.isNotEmpty) parts.add(text);
        } catch (_) {}
      }
    }
    return parts.join(' / ');
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBranchIds.isEmpty) {
      _snack('Select at least one branch.');
      return;
    }
    if (_type == ProductType.fixed && _options.isNotEmpty && _variants.any((v) => v.priceCtrl.text.trim().isEmpty)) {
      _snack('Set a price for every variant.');
      return;
    }

    setState(() => _saving = true);

    final fields = {
      'name':               _name.text.trim(),
      'description':        _description.text.trim().isEmpty ? null : _description.text.trim(),
      'price':              double.tryParse(_price.text) ?? 0,
      'compare_at_price':   _compareAt.text.trim().isEmpty ? null : double.tryParse(_compareAt.text),
      'product_type':       _type.value,
      'is_active':          _isActive,
      'track_inventory':    _trackInventory,
      'is_best_seller':     _isBestSeller,
      'sort_order':         int.tryParse(_sortOrder.text) ?? 0,
      'images':             _imageCtrls.map((c) => c.text.trim()).where((u) => u.isNotEmpty).toList(),
      'loyalty_points':     int.tryParse(_loyaltyPts.text) ?? 0,
      'min_weight_grams':   int.tryParse(_minWeight.text) ?? 250,
      'max_weight_grams':   int.tryParse(_maxWeight.text) ?? 5000,
      'weight_step_grams':  int.tryParse(_weightStep.text) ?? 250,
      'bulk_discount_pct':  double.tryParse(_bulkDiscount.text) ?? 0,
      'cogs_percent':       _cogsPercent.text.trim().isEmpty ? null : double.tryParse(_cogsPercent.text),
    };

    // Build options payload: [{name, values: [text]}]
    final optionsPayload = _options
        .where((o) => o.nameCtrl.text.trim().isNotEmpty && o.values.isNotEmpty)
        .map((o) => {
              'name': o.nameCtrl.text.trim(),
              'values': o.values.map((v) => v.ctrl.text.trim()).where((t) => t.isNotEmpty).toList(),
            })
        .toList();

    // Build variants payload
    List<Map<String, dynamic>> variantsPayload = [];
    if (optionsPayload.isNotEmpty) {
      for (final v in _variants) {
        // valueIndices[optIdx] = index of chosen value in that option's values list
        final valueIndices = <int>[];
        for (var optIdx = 0; optIdx < _options.length; optIdx++) {
          if (optIdx < v.valueTempIds.length) {
            final tid = v.valueTempIds[optIdx];
            final valIdx = _options[optIdx].values.indexWhere((vd) => vd.tempId == tid);
            valueIndices.add(valIdx < 0 ? 0 : valIdx);
          }
        }
        final inventory = <String, int>{
          for (final e in v.inventoryCtrl.entries)
            e.key: int.tryParse(e.value.text) ?? 0,
        };
        variantsPayload.add({
          'valueIndices':   valueIndices,
          'price':          double.tryParse(v.priceCtrl.text) ?? (double.tryParse(_price.text) ?? 0),
          'compareAtPrice': v.compareAtCtrl.text.trim().isEmpty ? null : double.tryParse(v.compareAtCtrl.text),
          'isActive':       v.isActive,
          'inventory':      inventory,
        });
      }
    }

    // Product-level inventory (only if no variants)
    final productInventory = optionsPayload.isEmpty && _trackInventory
        ? {for (final e in _productInventoryCtrls.entries) e.key: int.tryParse(e.value.text) ?? 0}
        : <String, int>{};

    bool ok;
    if (_isEdit) {
      ok = await context.read<ProductsCubit>().update(
        id: widget.product!.id,
        fields: fields,
        branchIds: _selectedBranchIds,
        categoryIds: _selectedCategoryId != null ? [_selectedCategoryId!] : [],
        options: optionsPayload,
        variants: variantsPayload,
        productInventory: productInventory,
        relatedIds: _relatedProductIds,
        branchId: widget.branchId,
      );
    } else {
      ok = await context.read<ProductsCubit>().create(
        fields: fields,
        branchIds: _selectedBranchIds,
        categoryIds: _selectedCategoryId != null ? [_selectedCategoryId!] : [],
        options: optionsPayload,
        variants: variantsPayload,
        productInventory: productInventory,
        relatedIds: _relatedProductIds,
        branchId: widget.branchId,
      );
    }

    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.of(context).pop();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: GoogleFonts.nunito())),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isWeb = Responsive.isWeb(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDeep,
        foregroundColor: AppColors.white,
        title: Text(
          _isEdit ? l10n.productFormEditTitle : l10n.productFormNewTitle,
          style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 18), fontWeight: FontWeight.w700, color: AppColors.white),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? SizedBox(width: 20.r, height: 20.r, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(l10n.productFormSave, style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w700, color: AppColors.white)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWeb ? 720 : double.infinity),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(isWeb ? 24 : 16.r),
              children: [
                // ── BRANCHES ───
                if (_showBranchPicker) ...[
                  _sectionLabel('Branches'),
                  SizedBox(height: 10.h),
                  _BranchMultiSelect(
                    selectedIds: _selectedBranchIds,
                    onChanged: (ids) => setState(() {
                      _selectedBranchIds = ids;
                      _refreshInventoryCtrls();
                    }),
                  ),
                  SizedBox(height: 20.h),
                ],

                // ── BASIC INFO ───
                _sectionLabel('Basic Info'),
                SizedBox(height: 10.h),
                _field(_name, 'Product Name', required: true),
                SizedBox(height: 12.h),
                _field(_description, 'Description', maxLines: 3),
                SizedBox(height: 20.h),

                // ── IMAGES ───
                _sectionLabel('Images'),
                SizedBox(height: 10.h),
                _ImagesEditor(
                  ctrls: _imageCtrls,
                  onAdd: () => setState(() => _imageCtrls.add(TextEditingController())),
                  onRemove: (i) => setState(() {
                    _imageCtrls[i].dispose();
                    _imageCtrls.removeAt(i);
                  }),
                ),
                SizedBox(height: 20.h),

                // ── CATEGORIES ───
                _sectionLabel('Categories'),
                SizedBox(height: 10.h),
                _categoryDropdown(),
                SizedBox(height: 20.h),

                // ── TYPE & PRICING ───
                _sectionLabel('Type & Pricing'),
                SizedBox(height: 10.h),
                _typeDropdown(),
                SizedBox(height: 12.h),
                isWeb
                    ? Row(children: [
                        Expanded(child: _field(_price, 'Base Price (EGP)', keyboard: TextInputType.number, required: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _field(_compareAt, 'Compare-at Price (EGP)', keyboard: TextInputType.number)),
                      ])
                    : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _field(_price, 'Base Price (EGP)', keyboard: TextInputType.number, required: true),
                        SizedBox(height: 12.h),
                        _field(_compareAt, 'Compare-at Price (EGP)', keyboard: TextInputType.number),
                      ]),
                SizedBox(height: 20.h),

                // ── WEIGHT CONFIG (weight type only) ───
                if (_type == ProductType.weight) ...[
                  _sectionLabel('Weight Configuration'),
                  SizedBox(height: 10.h),
                  _weightConfigSection(),
                  SizedBox(height: 20.h),
                ],

                // ── INVENTORY (no-variant products only) ───
                _sectionLabel('Inventory'),
                SizedBox(height: 8.h),
                _inventorySection(),
                SizedBox(height: 20.h),

                // ── VARIANTS (Fixed type only) ───
                if (_type == ProductType.fixed) ...[
                  _sectionLabel('Variants'),
                  SizedBox(height: 10.h),
                  _variantsSection(),
                  SizedBox(height: 20.h),
                ],

                // ── COGS & RELATED ───
                _sectionLabel('Financials & Related'),
                SizedBox(height: 10.h),
                _cogsSection(),
                SizedBox(height: 12.h),
                _relatedProductsSection(),
                SizedBox(height: 20.h),

                // ── META ───
                _sectionLabel('Meta'),
                SizedBox(height: 10.h),
                isWeb
                    ? Row(children: [
                        Expanded(child: _field(_sortOrder, 'Sort Order', keyboard: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: _field(_loyaltyPts, 'Loyalty Points', keyboard: TextInputType.number)),
                      ])
                    : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _field(_sortOrder, 'Sort Order', keyboard: TextInputType.number),
                        SizedBox(height: 12.h),
                        _field(_loyaltyPts, 'Loyalty Points', keyboard: TextInputType.number),
                      ]),
                SizedBox(height: 12.h),
                _activeSwitch(),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Inventory section ────────────────────────────────────────────────────

  Widget _inventorySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r12,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Track inventory',
                style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w600, color: AppColors.textCharcoal),
              ),
              Switch.adaptive(
                value: _trackInventory,
                activeThumbColor: AppColors.primaryDeep,
                onChanged: (v) => setState(() {
                  _trackInventory = v;
                  if (v && _productInventoryCtrls.isEmpty) _initProductInventoryCtrls();
                }),
              ),
            ],
          ),
          if (_trackInventory && _options.isEmpty) ...[
            Divider(height: 20, color: AppColors.border),
            Text(
              'Quantity per branch',
              style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 12), color: AppColors.textLight),
            ),
            SizedBox(height: 10.h),
            ..._productInventoryCtrls.entries.map((e) {
              final branch = context.read<BranchesCubit>().state.branches.firstWhere(
                (b) => b.id == e.key,
                orElse: () => context.read<BranchesCubit>().state.branches.first,
              );
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        branch.name,
                        style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13), color: AppColors.textDark),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        controller: e.value,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 14), color: AppColors.textDark),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(borderRadius: AppBorderRadius.r8, borderSide: BorderSide(color: AppColors.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r8, borderSide: BorderSide(color: AppColors.border)),
                          focusedBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r8, borderSide: BorderSide(color: AppColors.primaryMid, width: 2)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (_trackInventory && _options.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Inventory is managed per variant below.',
                style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 12), color: AppColors.textLight),
              ),
            ),
        ],
      ),
    );
  }

  void _refreshInventoryCtrls() {
    final branchIds = _selectedBranchIds;
    // Keep existing values, add missing
    final newCtrls = <String, TextEditingController>{};
    for (final bId in branchIds) {
      newCtrls[bId] = _productInventoryCtrls[bId] ?? TextEditingController(text: '0');
    }
    // Dispose removed
    for (final e in _productInventoryCtrls.entries) {
      if (!branchIds.contains(e.key)) e.value.dispose();
    }
    _productInventoryCtrls = newCtrls;
  }

  // ── Variants section ─────────────────────────────────────────────────────

  Widget _variantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Options
        ..._options.asMap().entries.map((e) => _optionCard(e.key, e.value)),

        // Add option button
        OutlinedButton.icon(
          onPressed: _addOption,
          icon: const Icon(Icons.add, size: 16),
          label: Text(AppLocalizations.of(context)!.productFormAddOption, style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryDeep,
            side: BorderSide(color: AppColors.primaryDeep),
            shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r12),
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16),
          ),
        ),

        // Generated variants — grouped by first option
        if (_variants.isNotEmpty) ...[
          SizedBox(height: 20.h),
          Text(
            'Generated Variants (${_variants.length})',
            style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 0.3),
          ),
          SizedBox(height: 10.h),
          _variantGroupedList(),
        ],
      ],
    );
  }

  Widget _optionCard(int optIdx, _OptionDraft opt) {
    final valueCount = opt.values.length;
    final valueSummary = opt.values
        .map((v) => v.ctrl.text.trim())
        .where((t) => t.isNotEmpty)
        .join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r12,
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: Theme(
        // Remove the default ExpansionTile divider lines
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          shape: const Border(),
          collapsedShape: const Border(),
          title: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: opt.nameCtrl,
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 14),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Option name (e.g. Size)',
                    hintStyle: GoogleFonts.nunito(color: AppColors.textLight, fontSize: Responsive.sp(context, 14)),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          subtitle: valueCount > 0
              ? Text(
                  valueSummary.isNotEmpty ? valueSummary : '$valueCount value${valueCount == 1 ? '' : 's'}',
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 11),
                    color: AppColors.textLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _removeOption(optIdx),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline_rounded, size: 18.r, color: AppColors.error.withValues(alpha: 0.7)),
                ),
              ),
              const SizedBox(width: 4),
              // Default expand arrow handled by ExpansionTile
            ],
          ),
          children: [
            Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...opt.values.asMap().entries.map((e) => _valueChip(optIdx, e.key, e.value)),
                GestureDetector(
                  onTap: () => _addValue(optIdx),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMist,
                      borderRadius: AppBorderRadius.full,
                      border: Border.all(color: AppColors.primaryLight),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 14.r, color: AppColors.primaryDeep),
                        const SizedBox(width: 4),
                        Text(
                          'Add value',
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 12),
                            color: AppColors.primaryDeep,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _valueChip(int optIdx, int valIdx, _ValueDraft val) {
    return Container(
      constraints: BoxConstraints(maxWidth: 120),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primaryMist.withValues(alpha: 0.6),
        borderRadius: AppBorderRadius.full,
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: IntrinsicWidth(
              child: TextField(
                controller: val.ctrl,
                onChanged: (_) => setState(() {}),
                style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 12), color: AppColors.primaryDeep),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  hintText: 'Value',
                  hintStyle: GoogleFonts.nunito(color: AppColors.primaryLight),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _removeValue(optIdx, valIdx),
            child: Icon(Icons.close, size: 14.r, color: AppColors.primaryMid),
          ),
        ],
      ),
    );
  }

  Widget _variantGroupedList() {
    // If only one option (or none), fall back to flat list
    if (_options.isEmpty || _options[0].values.isEmpty || _options.length == 1) {
      return Column(
        children: _variants.asMap().entries
            .map((e) => _variantRow(e.key, e.value))
            .toList(),
      );
    }

    // Group by first option value
    final firstOpt = _options[0];
    return Column(
      children: firstOpt.values.asMap().entries.map((optValEntry) {
        final firstValTid = optValEntry.value.tempId;
        final firstValLabel = optValEntry.value.ctrl.text.trim().isEmpty
            ? 'Value ${optValEntry.key + 1}'
            : optValEntry.value.ctrl.text.trim();

        final groupVariants = _variants
            .asMap()
            .entries
            .where((e) =>
                e.value.valueTempIds.isNotEmpty &&
                e.value.valueTempIds[0] == firstValTid)
            .toList();

        if (groupVariants.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppBorderRadius.r12,
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.hardEdge,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: true,
              tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              shape: const Border(),
              collapsedShape: const Border(),
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMist,
                      borderRadius: AppBorderRadius.r8,
                    ),
                    child: Text(
                      '${firstOpt.nameCtrl.text.trim().isEmpty ? 'Option 1' : firstOpt.nameCtrl.text.trim()}: $firstValLabel',
                      style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 13),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${groupVariants.length} variant${groupVariants.length == 1 ? '' : 's'}',
                    style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 12),
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
              children: [
                Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 8),
                ...groupVariants.map((e) => _variantRow(e.key, e.value)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _variantRow(int idx, _VariantDraft v) {
    final label = _variantLabel(v);
    final branches = context.read<BranchesCubit>().state.branches;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r12,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.isEmpty ? 'Variant ${idx + 1}' : label,
                  style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch.adaptive(
                  value: v.isActive,
                  activeThumbColor: AppColors.primaryDeep,
                  onChanged: (val) => setState(() => v.isActive = val),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _inlineField(v.priceCtrl, 'Price (EGP)', required: true),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _inlineField(v.compareAtCtrl, 'Compare-at'),
              ),
            ],
          ),
          if (_trackInventory && v.inventoryCtrl.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(AppLocalizations.of(context)!.productFormStock, style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 11), color: AppColors.textLight)),
            SizedBox(height: 6.h),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: v.inventoryCtrl.entries.map((e) {
                final branch = branches.firstWhere(
                  (b) => b.id == e.key,
                  orElse: () => branches.first,
                );
                return SizedBox(
                  width: 110,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          branch.name,
                          style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 11), color: AppColors.textDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 44,
                        child: _inlineField(e.value, '0'),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ── Weight config section ─────────────────────────────────────────────────

  Widget _weightConfigSection() {
    final isWeb = Responsive.isWeb(context);
    final minW = int.tryParse(_minWeight.text) ?? 250;
    final maxW = int.tryParse(_maxWeight.text) ?? 5000;
    final step = (int.tryParse(_weightStep.text) ?? 250).clamp(1, 999999);
    final discPerStep = double.tryParse(_bulkDiscount.text) ?? 0;
    final basePrice = double.tryParse(_price.text) ?? 0;

    double previewAt(int grams) {
      final pricePerGram = basePrice / 1000;
      final steps = ((grams - minW) / step).floorToDouble();
      final totalDiscount = (steps * discPerStep / 100).clamp(0.0, 1.0);
      return pricePerGram * grams * (1 - totalDiscount);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r12,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price field = price per kg (EGP/kg). Customer selects weight via slider.',
            style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 11), color: AppColors.textLight),
          ),
          SizedBox(height: 12.h),
          // Weight range row
          Row(children: [
            Expanded(child: _field(_minWeight, 'Min Weight (g)', keyboard: TextInputType.number)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('–', style: GoogleFonts.nunito(fontSize: 18, color: AppColors.textLight, fontWeight: FontWeight.w600)),
            ),
            Expanded(child: _field(_maxWeight, 'Max Weight (g)', keyboard: TextInputType.number)),
          ]),
          SizedBox(height: 10.h),
          isWeb
              ? Row(children: [
                  Expanded(child: _field(_weightStep, 'Step (g)', keyboard: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: _field(_bulkDiscount, 'Discount % per Step', keyboard: TextInputType.number)),
                ])
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _field(_weightStep, 'Step (g)', keyboard: TextInputType.number),
                  SizedBox(height: 10.h),
                  _field(_bulkDiscount, 'Discount % per Step', keyboard: TextInputType.number),
                ]),
          if (basePrice > 0 && maxW > minW) ...[
            SizedBox(height: 14.h),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryMist,
                borderRadius: AppBorderRadius.r8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.productFormPricePreview, style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 11), fontWeight: FontWeight.w700, color: AppColors.primaryDeep)),
                  SizedBox(height: 4.h),
                  Text(
                    '${minW}g → EGP ${previewAt(minW).toStringAsFixed(2)}   |   '
                    '${(minW + maxW) ~/ 2}g → EGP ${previewAt((minW + maxW) ~/ 2).toStringAsFixed(2)}   |   '
                    '${maxW}g → EGP ${previewAt(maxW).toStringAsFixed(2)}',
                    style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 12), color: AppColors.textDark),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── COGS section ──────────────────────────────────────────────────────────

  Widget _cogsSection() {
    final cogs = double.tryParse(_cogsPercent.text);
    final margin = cogs != null ? (100 - cogs).clamp(0, 100) : null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r12,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field(_cogsPercent, 'Cost of Goods (COGS %) — optional', keyboard: TextInputType.number),
          if (margin != null) ...[
            SizedBox(height: 8.h),
            Row(children: [
              Icon(Icons.trending_up_rounded, size: 14.r, color: AppColors.primaryDeep),
              const SizedBox(width: 6),
              Text(
                'Profit Margin: ${margin.toStringAsFixed(1)}%',
                style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w600, color: AppColors.primaryDeep),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  // ── Related products section ───────────────────────────────────────────────

  Widget _relatedProductsSection() {
    final allProducts = context.watch<ProductsCubit>().state.products;
    final currentId = widget.product?.id;
    final selectable = allProducts.where((p) => p.id != currentId && p.isActive).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r12,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.productFormRelatedProducts, style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w600, color: AppColors.textCharcoal)),
              TextButton.icon(
                onPressed: () => _showRelatedPicker(selectable),
                icon: Icon(Icons.add_circle_outline, size: 16.r, color: AppColors.primaryDeep),
                label: Text(AppLocalizations.of(context)!.productFormAdd, style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w600, color: AppColors.primaryDeep)),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              ),
            ],
          ),
          if (_relatedProductIds.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(AppLocalizations.of(context)!.productFormNoRelated, style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 12), color: AppColors.textLight)),
            )
          else ...[
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _relatedProductIds.map((id) {
                final product = selectable.where((p) => p.id == id).firstOrNull
                    ?? allProducts.where((p) => p.id == id).firstOrNull;
                final name = product?.name ?? id.substring(0, 8);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMist,
                    borderRadius: AppBorderRadius.full,
                    border: Border.all(color: AppColors.primaryLight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(name, style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 12), color: AppColors.primaryDeep, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => setState(() => _relatedProductIds.remove(id)),
                        child: Icon(Icons.close, size: 14.r, color: AppColors.primaryMid),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _showRelatedPicker(List<dynamic> selectable) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        final products = List<dynamic>.from(selectable)
            .where((p) => !_relatedProductIds.contains((p as dynamic).id))
            .cast<dynamic>()
            .toList();
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (_, sc) => Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(AppLocalizations.of(context)!.productFormSelectRelated, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              Expanded(
                child: ListView.builder(
                  controller: sc,
                  itemCount: products.length,
                  itemBuilder: (_, i) {
                    final p = products[i];
                    return ListTile(
                      title: Text(p.name, style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
                      subtitle: Text(p.type.label, style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textLight)),
                      trailing: Text('EGP ${p.price.toStringAsFixed(2)}', style: GoogleFonts.nunito(fontSize: 13, color: AppColors.primaryDeep, fontWeight: FontWeight.w700)),
                      onTap: () {
                        setState(() => _relatedProductIds.add(p.id as String));
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionLabel(String title) => Text(
        title.toUpperCase(),
        style: GoogleFonts.nunito(
          fontSize: Responsive.sp(context, 11),
          fontWeight: FontWeight.w700,
          color: AppColors.textLight,
          letterSpacing: 0.6,
        ),
      );

  Widget _field(TextEditingController ctrl, String label,
      {bool required = false, int maxLines = 1, TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboard,
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
      style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 14), color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13), color: AppColors.textLight),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: AppColors.primaryMid, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: AppColors.error)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: AppColors.error, width: 2)),
      ),
    );
  }

  Widget _inlineField(TextEditingController ctrl, String hint, {bool required = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
      style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13), color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(fontSize: Responsive.sp(context, 12), color: AppColors.textLight),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: AppBorderRadius.r8, borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r8, borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r8, borderSide: BorderSide(color: AppColors.primaryMid, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r8, borderSide: BorderSide(color: AppColors.error)),
      ),
    );
  }

  Widget _typeDropdown() {
    return DropdownButtonFormField<ProductType>(
      initialValue: _type,
      style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 14), color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: 'Product Type',
        labelStyle: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13), color: AppColors.textLight),
        filled: true, fillColor: AppColors.white,
        border: OutlineInputBorder(borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: AppColors.primaryMid, width: 2)),
      ),
      items: ProductType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
      onChanged: (t) => setState(() {
        _type = t!;
        if (_type != ProductType.fixed) {
          for (final o in _options) { o.dispose(); }
          for (final v in _variants) { v.dispose(); }
          _options.clear();
          _variants.clear();
        }
      }),
    );
  }

  Widget _categoryDropdown() {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (_, state) {
        final seen = <String>{};
        final categories = state.categories.where((c) => seen.add(c.id)).toList();
        final effectiveCategoryId = _selectedCategoryId == null || categories.any((c) => c.id == _selectedCategoryId)
            ? _selectedCategoryId
            : null;
        return DropdownButtonFormField<String?>(
          initialValue: effectiveCategoryId,
          style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 14), color: AppColors.textDark),
          decoration: InputDecoration(
            labelText: 'Category',
            labelStyle: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13), color: AppColors.textLight),
            filled: true, fillColor: AppColors.white,
            border: OutlineInputBorder(borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: AppColors.primaryMid, width: 2)),
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(AppLocalizations.of(context)!.productFormNone, style: GoogleFonts.nunito(color: AppColors.textLight)),
            ),
            ...categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
          ],
          onChanged: (v) => setState(() => _selectedCategoryId = v),
        );
      },
    );
  }

  Widget _activeSwitch() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4.h),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: AppBorderRadius.r12),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            title: Text(AppLocalizations.of(context)!.productFormActive, style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w600, color: AppColors.textCharcoal)),
            subtitle: Text(AppLocalizations.of(context)!.productFormActiveSubtitle, style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 12), color: AppColors.textLight)),
            value: _isActive,
            activeThumbColor: AppColors.primaryDeep,
            activeTrackColor: AppColors.primaryMid,
            onChanged: (v) => setState(() => _isActive = v),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile.adaptive(
            title: Text(AppLocalizations.of(context)!.productFormBestSeller, style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w600, color: AppColors.textCharcoal)),
            subtitle: Text(AppLocalizations.of(context)!.productFormBestSellerSubtitle, style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 12), color: AppColors.textLight)),
            value: _isBestSeller,
            activeThumbColor: const Color(0xFFFF6B35),
            activeTrackColor: const Color(0xFFFFAB91),
            onChanged: (v) => setState(() => _isBestSeller = v),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

// ── Images editor ─────────────────────────────────────────────────────────────

class _ImagesEditor extends StatelessWidget {
  const _ImagesEditor({required this.ctrls, required this.onAdd, required this.onRemove});
  final List<TextEditingController> ctrls;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...ctrls.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: e.value,
                      keyboardType: TextInputType.url,
                      style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13), color: AppColors.textDark),
                      decoration: InputDecoration(
                        hintText: 'Image URL ${e.key + 1}',
                        hintStyle: GoogleFonts.nunito(fontSize: Responsive.sp(context, 12), color: AppColors.textLight),
                        prefixIcon: Icon(Icons.image_outlined, size: 18.r, color: AppColors.textLight),
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: AppColors.primaryMid, width: 2)),
                      ),
                    ),
                  ),
                  if (ctrls.length > 1) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => onRemove(e.key),
                      child: Container(
                        width: 36.r,
                        height: 36.r,
                        decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: AppBorderRadius.r8),
                        child: Icon(Icons.close, size: 16.r, color: AppColors.error),
                      ),
                    ),
                  ],
                ],
              ),
            )),
        TextButton.icon(
          onPressed: onAdd,
          icon: Icon(Icons.add_photo_alternate_outlined, size: 16.r),
          label: Text('Add Image', style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w600)),
          style: TextButton.styleFrom(foregroundColor: AppColors.primaryDeep),
        ),
      ],
    );
  }
}

// ── Branch multi-select ───────────────────────────────────────────────────────

class _BranchMultiSelect extends StatelessWidget {
  const _BranchMultiSelect({required this.selectedIds, required this.onChanged});
  final List<String> selectedIds;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final branches = context.watch<BranchesCubit>().state.branches;
    if (branches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: AppBorderRadius.r12),
        child: Text(AppLocalizations.of(context)!.productFormNoBranches, style: GoogleFonts.nunito(color: AppColors.textLight)),
      );
    }
    final allSelected = branches.every((b) => selectedIds.contains(b.id));
    return Container(
      decoration: BoxDecoration(color: AppColors.white, borderRadius: AppBorderRadius.r12, border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          _CheckRow(
            label: AppLocalizations.of(context)!.categoryFormAllBranches,
            icon: Icons.store_rounded,
            isSelected: allSelected,
            isBold: true,
            onTap: () => onChanged(allSelected ? [] : branches.map((b) => b.id).toList()),
          ),
          Divider(height: 1, color: AppColors.border),
          ...branches.map((b) {
            final sel = selectedIds.contains(b.id);
            return _CheckRow(
              label: b.name,
              isSelected: sel,
              onTap: () {
                final updated = List<String>.from(selectedIds);
                if (sel) { updated.remove(b.id); } else { updated.add(b.id); }
                onChanged(updated);
              },
            );
          }),
        ],
      ),
    );
  }
}

// ── Shared check row ──────────────────────────────────────────────────────────

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.isBold = false,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: AppColors.primaryDeep),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                  color: isBold ? AppColors.primaryDeep : AppColors.textDark,
                ),
              ),
            ),
            Checkbox(
              value: isSelected,
              activeColor: AppColors.primaryDeep,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: (_) => onTap(),
            ),
          ],
        ),
      ),
    );
  }
}
