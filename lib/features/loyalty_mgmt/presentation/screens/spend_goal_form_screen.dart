import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/widgets/entity_picker_field.dart';
import '../../data/model/spend_goal_model.dart';
import '../cubits/loyalty_cubit.dart';

class SpendGoalFormScreen extends StatefulWidget {
  const SpendGoalFormScreen({super.key, this.goal});
  final SpendGoalModel? goal;

  @override
  State<SpendGoalFormScreen> createState() => _SpendGoalFormScreenState();
}

class _SpendGoalFormScreenState extends State<SpendGoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _iconCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _spendCtrl;
  late final TextEditingController _discountCtrl;
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
    _iconCtrl     = TextEditingController(text: g?.icon ?? '🎁');
    _titleCtrl    = TextEditingController(text: g?.title ?? '');
    _spendCtrl    = TextEditingController(
        text: g != null ? g.spendRequired.toStringAsFixed(0) : '');
    _discountCtrl = TextEditingController(
        text: g != null ? g.rewardDiscountAmount.toStringAsFixed(0) : '0');
    _descCtrl     = TextEditingController(text: g?.description ?? '');
    _sortCtrl     = TextEditingController(
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
    _spendCtrl.dispose();
    _discountCtrl.dispose();
    _descCtrl.dispose();
    _sortCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<LoyaltyCubit>();

    final goal = SpendGoalModel(
      id:                   widget.goal?.id ?? '',
      icon:                 _iconCtrl.text.trim().isEmpty ? '🎁' : _iconCtrl.text.trim(),
      title:                _titleCtrl.text.trim(),
      description:          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      spendRequired:        double.tryParse(_spendCtrl.text.trim()) ?? 0,
      rewardType:           _rewardType,
      rewardProductId:      _rewardType == 'free_product' ? _selectedProductId : null,
      rewardDiscountAmount: _rewardType == 'discount'
          ? (double.tryParse(_discountCtrl.text.trim()) ?? 0)
          : 0,
      isActive:             _isActive,
      sortOrder:            int.tryParse(_sortCtrl.text.trim()) ?? 0,
    );

    final bool ok;
    if (_isEdit) {
      ok = await cubit.updateSpendGoal(goal);
    } else {
      ok = await cubit.createSpendGoal(goal);
    }

    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoyaltyCubit, LoyaltyState>(
      builder: (context, state) {
        final saving = state.actionStatus == LoyaltyMgmtStatus.loading;
        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDeep,
            foregroundColor: AppColors.white,
            title: Text(
              _isEdit ? 'Edit Spend Milestone' : 'New Spend Milestone',
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
                        'Save',
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
                _FieldLabel('Icon (emoji)'),
                SizedBox(height: 8.h),
                _buildTextField(
                  controller: _iconCtrl,
                  hint: '🎁',
                  icon: Icons.emoji_emotions_outlined,
                ),
                SizedBox(height: 20.h),
                _FieldLabel('Title'),
                SizedBox(height: 8.h),
                _buildTextField(
                  controller: _titleCtrl,
                  hint: 'e.g. Free Delivery at EGP 300',
                  icon: Icons.title_rounded,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                ),
                SizedBox(height: 20.h),
                _FieldLabel('Spend Required (EGP)'),
                SizedBox(height: 8.h),
                _buildTextField(
                  controller: _spendCtrl,
                  hint: '300',
                  icon: Icons.payments_outlined,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    final d = double.tryParse(v ?? '');
                    if (d == null || d <= 0) return 'Enter a spend amount greater than 0';
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                _FieldLabel('Reward Type'),
                SizedBox(height: 8.h),
                _buildRewardDropdown(),
                SizedBox(height: 16.h),

                if (_rewardType == 'free_product') ...[
                  _FieldLabel('Free Product'),
                  SizedBox(height: 8.h),
                  EntityPickerField(
                    icon: Icons.inventory_2_outlined,
                    placeholder: 'Tap to choose a product',
                    sheetTitle: 'Select Free Product',
                    fetchItems: _fetchProducts,
                    selectedId: _selectedProductId,
                    selectedName: _selectedProductName,
                    requiredMessage: 'Select a product for this milestone',
                    onSelected: (item) => setState(() {
                      _selectedProductId   = item.id;
                      _selectedProductName = item.name;
                    }),
                  ),
                  SizedBox(height: 20.h),
                ],

                if (_rewardType == 'discount') ...[
                  _FieldLabel('Discount (%)'),
                  SizedBox(height: 8.h),
                  _buildTextField(
                    controller: _discountCtrl,
                    hint: '10',
                    icon: Icons.discount_outlined,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final d = double.tryParse(v ?? '');
                      if (d == null || d <= 0 || d > 100) {
                        return 'Enter a discount between 1 and 100';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                ],

                _FieldLabel('Description — optional'),
                SizedBox(height: 8.h),
                _buildTextField(
                  controller: _descCtrl,
                  hint: 'Shown to customers in cart and checkout',
                  icon: Icons.notes_rounded,
                  maxLines: 3,
                ),
                SizedBox(height: 20.h),
                _FieldLabel('Sort Order'),
                SizedBox(height: 8.h),
                _buildTextField(
                  controller: _sortCtrl,
                  hint: '0',
                  icon: Icons.sort_rounded,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final d = int.tryParse(v ?? '');
                    if (d == null || d < 0) return 'Enter 0 or more';
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
                          'Active',
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
                      'Delete Milestone',
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Milestone?',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text(
          'This will permanently delete "${widget.goal!.title}".',
          style: GoogleFonts.nunito(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final cubit = context.read<LoyaltyCubit>();
              final nav   = Navigator.of(context);
              await cubit.deleteSpendGoal(widget.goal!.id);
              if (mounted) nav.pop();
            },
            child: Text('Delete',
                style: GoogleFonts.nunito(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardDropdown() {
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
          items: const [
            DropdownMenuItem(value: 'free_delivery', child: Text('Free Delivery')),
            DropdownMenuItem(value: 'free_product',  child: Text('Free Product')),
            DropdownMenuItem(value: 'discount',      child: Text('Discount (%)')),
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
