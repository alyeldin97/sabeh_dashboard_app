import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/widgets/entity_picker_field.dart';
import '../../data/model/banner_model.dart';
import '../cubits/banners_cubit.dart';

class BannerFormScreen extends StatefulWidget {
  const BannerFormScreen({super.key, this.banner});
  final BannerModel? banner;

  @override
  State<BannerFormScreen> createState() => _BannerFormScreenState();
}

class _BannerFormScreenState extends State<BannerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _imageUrlCtrl =
      TextEditingController(text: widget.banner?.imageUrl ?? '');
  late final _titleCtrl =
      TextEditingController(text: widget.banner?.title ?? '');
  late final _sortCtrl =
      TextEditingController(text: widget.banner?.sortOrder.toString() ?? '0');
  late final _actionUrlCtrl =
      TextEditingController(text: widget.banner?.actionUrl ?? '');

  late BannerActionType _actionType =
      widget.banner?.actionType ?? BannerActionType.none;
  late bool _isActive = widget.banner?.isActive ?? true;
  late DateTime? _startDate = widget.banner?.startDate;
  late DateTime? _endDate = widget.banner?.endDate;
  String _previewUrl = '';

  // Product picker state
  String? _selectedProductId;
  String? _selectedProductName;

  // Collection picker state
  String? _selectedCollectionId;
  String? _selectedCollectionName;

  bool get _isEditing => widget.banner != null;

  @override
  void initState() {
    super.initState();
    _previewUrl = widget.banner?.imageUrl ?? '';
    _imageUrlCtrl.addListener(() {
      if (mounted) setState(() => _previewUrl = _imageUrlCtrl.text.trim());
    });

    _selectedProductId = widget.banner?.actionProductId;
    _selectedCollectionId = widget.banner?.actionCollectionId;
    if (_selectedProductId != null || _selectedCollectionId != null) {
      _resolveEntityNames();
    }
  }

  Future<void> _resolveEntityNames() async {
    final client = Supabase.instance.client;
    try {
      if (_selectedProductId != null) {
        final row = await client
            .from('products')
            .select('name')
            .eq('id', _selectedProductId!)
            .single();
        if (mounted) setState(() => _selectedProductName = row['name'] as String?);
      }
      if (_selectedCollectionId != null) {
        final row = await client
            .from('categories')
            .select('name')
            .eq('id', _selectedCollectionId!)
            .single();
        if (mounted) setState(() => _selectedCollectionName = row['name'] as String?);
      }
    } catch (_) {}
  }

  Future<List<EntityPickerItem>> _fetchProducts() async {
    final rows = await Supabase.instance.client
        .from('products')
        .select('id, name')
        .order('name');
    return (rows as List)
        .map((r) => EntityPickerItem(
            id: r['id'] as String, name: r['name'] as String))
        .toList();
  }

  Future<List<EntityPickerItem>> _fetchCategories() async {
    final rows = await Supabase.instance.client
        .from('categories')
        .select('id, name')
        .order('name');
    return (rows as List)
        .map((r) => EntityPickerItem(
            id: r['id'] as String, name: r['name'] as String))
        .toList();
  }

  @override
  void dispose() {
    _imageUrlCtrl.dispose();
    _titleCtrl.dispose();
    _sortCtrl.dispose();
    _actionUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primaryDeep)),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<BannersCubit>();
    final sortOrder = int.tryParse(_sortCtrl.text.trim()) ?? 0;

    bool ok;
    if (_isEditing) {
      ok = await cubit.update(
        id: widget.banner!.id,
        imageUrl: _imageUrlCtrl.text.trim(),
        title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
        isActive: _isActive,
        sortOrder: sortOrder,
        actionType: _actionType,
        actionUrl: _actionUrlCtrl.text.trim().isEmpty
            ? null
            : _actionUrlCtrl.text.trim(),
        actionProductId: _selectedProductId,
        actionCollectionId: _selectedCollectionId,
        startDate: _startDate,
        endDate: _endDate,
      );
    } else {
      ok = await cubit.create(
        imageUrl: _imageUrlCtrl.text.trim(),
        title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
        isActive: _isActive,
        sortOrder: sortOrder,
        actionType: _actionType,
        actionUrl: _actionUrlCtrl.text.trim().isEmpty
            ? null
            : _actionUrlCtrl.text.trim(),
        actionProductId: _selectedProductId,
        actionCollectionId: _selectedCollectionId,
        startDate: _startDate,
        endDate: _endDate,
      );
    }
    if (ok && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDeep,
        foregroundColor: AppColors.white,
        title: Text(
          _isEditing ? 'Edit Banner' : 'New Banner',
          style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 18),
              fontWeight: FontWeight.w700,
              color: AppColors.white),
        ),
      ),
      body: BlocBuilder<BannersCubit, BannersState>(
        builder: (context, state) {
          final isSaving =
              state.mutationStatus == BannerMutationStatus.saving;
          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(20.r),
              children: [
                // Image URL
                _Label(text: 'Image URL'),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: _imageUrlCtrl,
                  keyboardType: TextInputType.url,
                  style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 14),
                      color: AppColors.textDark),
                  decoration: _decoration(
                      icon: Icons.link_rounded,
                      hint: 'https://example.com/banner.jpg'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Image URL is required'
                          : null,
                ),
                if (_previewUrl.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  ClipRRect(
                    borderRadius: AppBorderRadius.r12,
                    child: CachedNetworkImage(
                      imageUrl: _previewUrl,
                      height: 180.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        height: 60.h,
                        color: AppColors.primaryMist,
                        child: Center(
                          child: Text('Invalid image URL',
                              style: GoogleFonts.nunito(
                                  color: AppColors.textLight,
                                  fontSize: Responsive.sp(context, 12))),
                        ),
                      ),
                      placeholder: (_, __) => Container(
                        height: 180.h,
                        color: AppColors.primaryMist,
                        child: const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primaryDeep)),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 16.h),

                // Title
                _Label(text: 'Title (optional)'),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: _titleCtrl,
                  style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 14),
                      color: AppColors.textDark),
                  decoration: _decoration(
                      icon: Icons.title_rounded, hint: 'Short headline text'),
                ),
                SizedBox(height: 16.h),

                // Sort order + Active row
                Row(children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label(text: 'Sort Order'),
                          SizedBox(height: 6.h),
                          TextFormField(
                            controller: _sortCtrl,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.nunito(
                                fontSize: Responsive.sp(context, 14),
                                color: AppColors.textDark),
                            decoration:
                                _decoration(icon: Icons.sort_rounded, hint: '0'),
                          ),
                        ]),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _Label(text: 'Active'),
                        Switch(
                          value: _isActive,
                          onChanged: (v) => setState(() => _isActive = v),
                          activeThumbColor: AppColors.primaryDeep,
                        ),
                      ]),
                ]),
                SizedBox(height: 16.h),

                // Action type
                _Label(text: 'On Tap Action'),
                SizedBox(height: 6.h),
                DropdownButtonFormField<BannerActionType>(
                  value: _actionType,
                  decoration: _decoration(icon: Icons.touch_app_outlined),
                  style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 14),
                      color: AppColors.textDark),
                  items: BannerActionType.values
                      .map((t) =>
                          DropdownMenuItem(value: t, child: Text(t.label)))
                      .toList(),
                  onChanged: (t) => setState(() {
                    _actionType = t!;
                    // clear the other pickers
                    if (_actionType != BannerActionType.product) {
                      _selectedProductId = null;
                      _selectedProductName = null;
                    }
                    if (_actionType != BannerActionType.collection) {
                      _selectedCollectionId = null;
                      _selectedCollectionName = null;
                    }
                  }),
                ),
                SizedBox(height: 16.h),

                // Action-specific fields
                if (_actionType == BannerActionType.url) ...[
                  _Label(text: 'URL to Open'),
                  SizedBox(height: 6.h),
                  TextFormField(
                    controller: _actionUrlCtrl,
                    keyboardType: TextInputType.url,
                    style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 14),
                        color: AppColors.textDark),
                    decoration: _decoration(
                        icon: Icons.open_in_new_rounded,
                        hint: 'https://example.com'),
                    validator: (v) =>
                        _actionType == BannerActionType.url &&
                                (v == null || v.trim().isEmpty)
                            ? 'URL is required'
                            : null,
                  ),
                  SizedBox(height: 16.h),
                ],
                if (_actionType == BannerActionType.product) ...[
                  _Label(text: 'Select Product'),
                  SizedBox(height: 6.h),
                  EntityPickerField(
                    icon: Icons.inventory_2_outlined,
                    placeholder: 'Tap to choose a product',
                    sheetTitle: 'Select Product',
                    fetchItems: _fetchProducts,
                    selectedId: _selectedProductId,
                    selectedName: _selectedProductName,
                    requiredMessage: 'Product is required',
                    onSelected: (item) => setState(() {
                      _selectedProductId = item.id;
                      _selectedProductName = item.name;
                    }),
                  ),
                  SizedBox(height: 16.h),
                ],
                if (_actionType == BannerActionType.collection) ...[
                  _Label(text: 'Select Category'),
                  SizedBox(height: 6.h),
                  EntityPickerField(
                    icon: Icons.grid_view_outlined,
                    placeholder: 'Tap to choose a category',
                    sheetTitle: 'Select Category',
                    fetchItems: _fetchCategories,
                    selectedId: _selectedCollectionId,
                    selectedName: _selectedCollectionName,
                    requiredMessage: 'Category is required',
                    onSelected: (item) => setState(() {
                      _selectedCollectionId = item.id;
                      _selectedCollectionName = item.name;
                    }),
                  ),
                  SizedBox(height: 16.h),
                ],

                // Date range
                _DatePickerRow(
                  label: 'Start Date (optional)',
                  date: _startDate,
                  onPick: () => _pickDate(true),
                  onClear: () => setState(() => _startDate = null),
                ),
                SizedBox(height: 12.h),
                _DatePickerRow(
                  label: 'End Date (optional)',
                  date: _endDate,
                  onPick: () => _pickDate(false),
                  onClear: () => setState(() => _endDate = null),
                ),
                SizedBox(height: 24.h),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDeep,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.r12),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      elevation: 0,
                    ),
                    child: isSaving
                        ? SizedBox(
                            width: 20.r,
                            height: 20.r,
                            child: const CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(
                            _isEditing ? 'Save Changes' : 'Create Banner',
                            style: GoogleFonts.nunito(
                                fontSize: Responsive.sp(context, 15),
                                fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _decoration({required IconData icon, String? hint}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 13), color: AppColors.textLight),
        prefixIcon: Icon(icon, size: 18.r, color: AppColors.textLight),
        filled: true,
        fillColor: AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: AppBorderRadius.r12,
            borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: AppBorderRadius.r12,
            borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: AppBorderRadius.r12,
            borderSide: BorderSide(color: AppColors.primaryMid, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: AppBorderRadius.r12,
            borderSide: BorderSide(color: AppColors.error)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppBorderRadius.r12,
            borderSide: BorderSide(color: AppColors.error, width: 2)),
      );
}

class _DatePickerRow extends StatelessWidget {
  const _DatePickerRow({
    required this.label,
    required this.date,
    required this.onPick,
    required this.onClear,
  });
  final String label;
  final DateTime? date;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppBorderRadius.r12,
          border: Border.all(
              color: date != null ? AppColors.primaryMid : AppColors.border,
              width: date != null ? 1.5 : 1),
        ),
        child: Row(children: [
          Icon(Icons.calendar_today_outlined,
              size: 18.r,
              color: date != null ? AppColors.primaryMid : AppColors.textLight),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              date != null
                  ? '${label.split(' ').first}: ${DateFormat('MMM d, y').format(date!)}'
                  : label,
              style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 13),
                  color: date != null ? AppColors.textDark : AppColors.textLight),
            ),
          ),
          if (date != null)
            GestureDetector(
              onTap: onClear,
              child: Icon(Icons.clear_rounded,
                  size: 16.r, color: AppColors.textLight),
            ),
        ]),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: Responsive.sp(context, 13),
          fontWeight: FontWeight.w600,
          color: AppColors.textCharcoal,
        ),
      );
}
