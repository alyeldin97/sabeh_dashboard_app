import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/widgets/entity_picker_field.dart';
import '../../data/model/loyalty_goal_model.dart';
import '../cubits/loyalty_cubit.dart';

class LoyaltyGoalFormScreen extends StatefulWidget {
  static const String routeName = '/loyalty-goal-form';

  const LoyaltyGoalFormScreen({super.key, this.goal});
  final LoyaltyGoalModel? goal;

  @override
  State<LoyaltyGoalFormScreen> createState() => _LoyaltyGoalFormScreenState();
}

class _LoyaltyGoalFormScreenState extends State<LoyaltyGoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _iconCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _pointsCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _sortCtrl;
  String _rewardType = 'free_delivery';
  bool _isActive = true;

  String? _selectedProductId;
  String? _selectedProductName;

  bool get _isEdit => widget.goal != null;

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    _iconCtrl   = TextEditingController(text: g?.icon ?? '🎁');
    _titleCtrl  = TextEditingController(text: g?.title ?? '');
    _pointsCtrl = TextEditingController(
        text: g != null ? g.pointsRequired.toString() : '');
    _descCtrl   = TextEditingController(text: g?.description ?? '');
    _sortCtrl   = TextEditingController(
        text: g != null ? g.sortOrder.toString() : '0');
    _rewardType        = g?.rewardType ?? 'free_delivery';
    _isActive          = g?.isActive ?? true;
    _selectedProductId = g?.rewardProductId;

    if (_selectedProductId != null) _resolveProductName();
  }

  Future<void> _resolveProductName() async {
    try {
      final row = await Supabase.instance.client
          .from('products')
          .select('name')
          .eq('id', _selectedProductId!)
          .single();
      if (mounted) setState(() => _selectedProductName = row['name'] as String?);
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

  @override
  void dispose() {
    _iconCtrl.dispose();
    _titleCtrl.dispose();
    _pointsCtrl.dispose();
    _descCtrl.dispose();
    _sortCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<LoyaltyCubit>();

    final goal = LoyaltyGoalModel(
      id:             widget.goal?.id ?? '',
      icon:           _iconCtrl.text.trim().isEmpty ? '🎁' : _iconCtrl.text.trim(),
      title:          _titleCtrl.text.trim(),
      description:    _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      spendRequired:  0,
      pointsRequired: int.tryParse(_pointsCtrl.text.trim()) ?? 0,
      rewardType:     _rewardType,
      rewardProductId: _rewardType == 'free_product' ? _selectedProductId : null,
      isActive:       _isActive,
      sortOrder:      int.tryParse(_sortCtrl.text.trim()) ?? 0,
    );

    final bool ok;
    if (_isEdit) {
      ok = await cubit.updateGoal(goal);
    } else {
      ok = await cubit.createGoal(goal);
    }

    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<LoyaltyCubit, LoyaltyState>(
      builder: (context, state) {
        final saving = state.actionStatus == LoyaltyMgmtStatus.loading;
        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDeep,
            foregroundColor: AppColors.white,
            title: Text(
              _isEdit ? l10n.loyaltyGoalFormEditTitle : l10n.loyaltyGoalFormNewTitle,
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 18),
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : _submit,
                child: saving
                    ? SizedBox(
                        width: 18.r,
                        height: 18.r,
                        child: const CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        l10n.loyaltyGoalFormSave,
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 15),
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
              ),
              SizedBox(width: 8.w),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(20.r),
              children: [
                _FieldLabel(l10n.loyaltyGoalFormIcon),
                SizedBox(height: 8.h),
                _buildTextField(
                  controller: _iconCtrl,
                  hint: '🎁',
                  icon: Icons.emoji_emotions_outlined,
                ),
                SizedBox(height: 20.h),
                _FieldLabel(l10n.loyaltyGoalFormTitle),
                SizedBox(height: 8.h),
                _buildTextField(
                  controller: _titleCtrl,
                  hint: 'e.g. Free Delivery',
                  icon: Icons.title_rounded,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? l10n.loyaltyGoalFormTitleRequired : null,
                ),
                SizedBox(height: 20.h),
                _FieldLabel(l10n.loyaltyGoalFormPointsRequired),
                SizedBox(height: 8.h),
                _buildTextField(
                  controller: _pointsCtrl,
                  hint: '300',
                  icon: Icons.stars_rounded,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final d = int.tryParse(v ?? '');
                    if (d == null || d <= 0) return l10n.loyaltyGoalFormPointsInvalid;
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                _FieldLabel(l10n.loyaltyGoalFormRewardType),
                SizedBox(height: 8.h),
                _buildRewardDropdown(l10n),
                SizedBox(height: 16.h),

                if (_rewardType == 'free_product') ...[
                  _FieldLabel(l10n.loyaltyGoalFormSelectProduct),
                  SizedBox(height: 8.h),
                  EntityPickerField(
                    icon: Icons.inventory_2_outlined,
                    placeholder: l10n.loyaltyGoalFormTapProduct,
                    sheetTitle: l10n.loyaltyGoalFormSelectProduct,
                    fetchItems: _fetchProducts,
                    selectedId: _selectedProductId,
                    selectedName: _selectedProductName,
                    requiredMessage: 'Select a product for this reward',
                    onSelected: (item) => setState(() {
                      _selectedProductId   = item.id;
                      _selectedProductName = item.name;
                    }),
                  ),
                  SizedBox(height: 20.h),
                ],

                _FieldLabel(l10n.loyaltyGoalFormDescription),
                SizedBox(height: 8.h),
                _buildTextField(
                  controller: _descCtrl,
                  hint: 'Short description shown to customers',
                  icon: Icons.notes_rounded,
                  maxLines: 3,
                ),
                SizedBox(height: 20.h),
                _FieldLabel(l10n.loyaltyGoalFormSortOrder),
                SizedBox(height: 8.h),
                _buildTextField(
                  controller: _sortCtrl,
                  hint: '0',
                  icon: Icons.sort_rounded,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final d = int.tryParse(v ?? '');
                    if (d == null || d < 0) return l10n.loyaltyGoalFormSortInvalid;
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: AppBorderRadius.r12,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.toggle_on_outlined,
                          size: 20.r, color: AppColors.textLight),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.loyaltyGoalFormActive,
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 14),
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      Switch(
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                        activeThumbColor: AppColors.primaryDeep,
                      ),
                    ],
                  ),
                ),
                if (_isEdit) ...[
                  SizedBox(height: 32.h),
                  OutlinedButton.icon(
                    onPressed: saving ? null : () => _confirmDelete(context),
                    icon: Icon(Icons.delete_outline_rounded,
                        size: 18.r, color: AppColors.error),
                    label: Text(
                      l10n.loyaltyGoalFormDelete,
                      style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 14),
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.r12),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ],
                SizedBox(height: 32.h),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.loyaltyGoalFormDeleteTitle,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text(
          'This will permanently delete "${widget.goal!.title}".',
          style: GoogleFonts.nunito(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.loyaltyGoalFormCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final cubit = context.read<LoyaltyCubit>();
              final nav   = Navigator.of(context);
              await cubit.deleteGoal(widget.goal!.id);
              if (mounted) nav.pop();
            },
            child: Text(l10n.loyaltyGoalFormDeleteConfirm,
                style: GoogleFonts.nunito(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardDropdown(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r12,
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _rewardType,
          isExpanded: true,
          style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 14), color: AppColors.textDark),
          items: [
            DropdownMenuItem(value: 'free_delivery', child: Text(l10n.loyaltyGoalFormFreeDelivery)),
            DropdownMenuItem(value: 'free_product',  child: Text(l10n.loyaltyGoalFormFreeProduct)),
          ],
          onChanged: (v) {
            if (v != null) {
              setState(() {
                _rewardType = v;
                if (v != 'free_product') {
                  _selectedProductId   = null;
                  _selectedProductName = null;
                }
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    FormFieldValidator<String>? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: GoogleFonts.nunito(
          fontSize: Responsive.sp(context, 14), color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 13), color: AppColors.textLight),
        prefixIcon: maxLines == 1
            ? Icon(icon, size: 20.r, color: AppColors.textLight)
            : null,
        filled: true,
        fillColor: AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: Responsive.sp(context, 13),
          fontWeight: FontWeight.w700,
          color: AppColors.textLight,
        ),
      );
}
