import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import '../../../branches/presentation/cubits/branches_cubit.dart';
import '../../data/model/category.dart';
import '../cubits/categories_cubit.dart';

class CategoryFormScreen extends StatefulWidget {
  const CategoryFormScreen({super.key, this.category, this.branchId});
  final Category? category;
  final String? branchId;

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _nameAr;
  late final TextEditingController _imageUrl;
  late bool _isActive;
  late List<String> _selectedBranchIds;
  bool _saving = false;

  bool get _isEdit => widget.category != null;
  bool get _showBranchPicker => widget.branchId == null;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _name     = TextEditingController(text: c?.name ?? '');
    _nameAr   = TextEditingController(text: c?.nameAr ?? '');
    _imageUrl = TextEditingController(text: c?.imageUrl ?? '');
    _isActive = c?.isActive ?? true;
    if (widget.branchId != null) {
      _selectedBranchIds = [widget.branchId!];
    } else {
      _selectedBranchIds = List.of(c?.branchIds ?? []);
    }
  }

  @override
  void dispose() {
    _name.dispose(); _nameAr.dispose(); _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBranchIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.categoryFormSelectBranch, style: GoogleFonts.nunito())),
      );
      return;
    }

    setState(() => _saving = true);
    final data = {
      'name':      _name.text.trim(),
      'name_ar':   _nameAr.text.trim().isEmpty ? null : _nameAr.text.trim(),
      'image_url': _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
      'is_active': _isActive,
    };

    bool ok;
    if (_isEdit) {
      ok = await context.read<CategoriesCubit>().update(
        id: widget.category!.id,
        data: data,
        branchIds: _selectedBranchIds,
        branchId: widget.branchId,
      );
    } else {
      ok = await context.read<CategoriesCubit>().create(
        data,
        branchIds: _selectedBranchIds,
        branchId: widget.branchId,
      );
    }

    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = Responsive.isWeb(context);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDeep,
        foregroundColor: AppColors.white,
        title: Text(
          _isEdit ? AppLocalizations.of(context)!.categoryFormEditTitle : AppLocalizations.of(context)!.categoryFormNewTitle,
          style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 18), fontWeight: FontWeight.w700, color: AppColors.white),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? SizedBox(width: 20.r, height: 20.r, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(AppLocalizations.of(context)!.categoryFormSave, style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w700, color: AppColors.white)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWeb ? 560 : double.infinity),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(isWeb ? 24 : 16.r),
              children: [
                if (_showBranchPicker) ...[
                  _section(context, AppLocalizations.of(context)!.categoryFormBranches),
                  SizedBox(height: 12.h),
                  _BranchMultiSelect(
                    selectedIds: _selectedBranchIds,
                    onChanged: (ids) => setState(() => _selectedBranchIds = ids),
                  ),
                  SizedBox(height: 16.h),
                ],
                _section(context, AppLocalizations.of(context)!.categoryFormName),
                SizedBox(height: 12.h),
                _field(context, _name, AppLocalizations.of(context)!.categoryFormNameEn, required: true),
                SizedBox(height: 12.h),
                _field(context, _nameAr, AppLocalizations.of(context)!.categoryFormNameAr),
                SizedBox(height: 16.h),
                _section(context, AppLocalizations.of(context)!.categoryFormMedia),
                SizedBox(height: 12.h),
                _field(context, _imageUrl, AppLocalizations.of(context)!.categoryFormCoverUrl, keyboard: TextInputType.url),
                SizedBox(height: 16.h),
                _section(context, AppLocalizations.of(context)!.categoryFormVisibility),
                SizedBox(height: 12.h),
                Container(
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: AppBorderRadius.r12),
                  child: SwitchListTile.adaptive(
                    title: Text(AppLocalizations.of(context)!.categoryFormActive, style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w600, color: AppColors.textCharcoal)),
                    subtitle: Text(AppLocalizations.of(context)!.categoryFormActiveSubtitle, style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 12), color: AppColors.textLight)),
                    value: _isActive,
                    activeThumbColor: AppColors.primaryDeep,
                    activeTrackColor: AppColors.primaryMid,
                    onChanged: (v) => setState(() => _isActive = v),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title) => Text(
        title,
        style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 0.5),
      );

  Widget _field(BuildContext context, TextEditingController ctrl, String label,
      {bool required = false, TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? AppLocalizations.of(context)!.categoryFormRequired : null : null,
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
}

// ── Shared multi-select branch widget ────────────────────────────────────────

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
        child: Text(AppLocalizations.of(context)!.categoryFormNoBranches, style: GoogleFonts.nunito(color: AppColors.textLight)),
      );
    }

    final allSelected = branches.every((b) => selectedIds.contains(b.id));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r12,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Select All toggle
          _BranchCheckRow(
            label: AppLocalizations.of(context)!.categoryFormAllBranches,
            icon: Icons.store_rounded,
            isSelected: allSelected,
            isBold: true,
            onTap: () {
              if (allSelected) {
                onChanged([]);
              } else {
                onChanged(branches.map((b) => b.id).toList());
              }
            },
          ),
          Divider(height: 1, color: AppColors.border),
          ...branches.map((b) {
            final selected = selectedIds.contains(b.id);
            return _BranchCheckRow(
              label: b.name,
              isSelected: selected,
              onTap: () {
                final updated = List<String>.from(selectedIds);
                if (selected) {
                  updated.remove(b.id);
                } else {
                  updated.add(b.id);
                }
                onChanged(updated);
              },
            );
          }),
        ],
      ),
    );
  }
}

class _BranchCheckRow extends StatelessWidget {
  const _BranchCheckRow({
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
      borderRadius: AppBorderRadius.r12,
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
