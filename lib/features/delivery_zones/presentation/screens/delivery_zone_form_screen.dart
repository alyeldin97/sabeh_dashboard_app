import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import '../../data/model/delivery_zone_model.dart';
import '../cubits/delivery_zones_cubit.dart';

class DeliveryZoneFormScreen extends StatefulWidget {
  const DeliveryZoneFormScreen({super.key, this.zone});
  final DeliveryZoneModel? zone;

  @override
  State<DeliveryZoneFormScreen> createState() => _DeliveryZoneFormScreenState();
}

class _DeliveryZoneFormScreenState extends State<DeliveryZoneFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _nameArCtrl;
  late final TextEditingController _feeCtrl;
  late final TextEditingController _actualCostCtrl;
  late final TextEditingController _minOrderCtrl;
  late final TextEditingController _minRiderCtrl;
  bool _isActive = true;
  String? _selectedBranchId;
  List<Map<String, String>> _branches = [];

  bool get _isEdit => widget.zone != null;

  @override
  void initState() {
    super.initState();
    final z = widget.zone;
    _nameCtrl       = TextEditingController(text: z?.name ?? '');
    _nameArCtrl     = TextEditingController(text: z?.nameAr ?? '');
    _feeCtrl        = TextEditingController(text: z != null ? z.userPaidDeliveryFees.toStringAsFixed(0) : '0');
    _actualCostCtrl = TextEditingController(text: z != null && z.deliveryFeesPaidToDriver > 0 ? z.deliveryFeesPaidToDriver.toStringAsFixed(0) : '0');
    _minOrderCtrl   = TextEditingController(text: z != null ? z.minOrderValue.toStringAsFixed(0) : '0');
    _minRiderCtrl   = TextEditingController(text: z != null ? z.minRiderQuantity.toString() : '0');
    _isActive         = z?.isActive ?? true;
    _selectedBranchId = null; // set after branches load to avoid DropdownButton assertion
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    try {
      final rows = await Supabase.instance.client
          .from('branches')
          .select('id, name')
          .order('name') as List<dynamic>;
      if (mounted) {
        setState(() {
          _branches = rows.map((r) => {
            'id': r['id'] as String,
            'name': r['name'] as String,
          }).toList();
          _selectedBranchId = widget.zone?.branchId; // safe now — items exist
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameArCtrl.dispose();
    _feeCtrl.dispose();
    _actualCostCtrl.dispose();
    _minOrderCtrl.dispose();
    _minRiderCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<DeliveryZonesCubit>();
    final name              = _nameCtrl.text.trim();
    final nameAr            = _nameArCtrl.text.trim().isEmpty ? null : _nameArCtrl.text.trim();
    final userPaidDeliveryFees       = double.parse(_feeCtrl.text.trim());
    final deliveryFeesPaidToDriver   = double.tryParse(_actualCostCtrl.text.trim()) ?? 0;
    final minOrder          = double.parse(_minOrderCtrl.text.trim());
    final minRider          = int.parse(_minRiderCtrl.text.trim());

    bool ok;
    if (_isEdit) {
      ok = await cubit.update(
        id: widget.zone!.id,
        name: name,
        nameAr: nameAr,
        userPaidDeliveryFees: userPaidDeliveryFees,
        deliveryFeesPaidToDriver: deliveryFeesPaidToDriver,
        minOrderValue: minOrder,
        minRiderQuantity: minRider,
        isActive: _isActive,
        branchId: _selectedBranchId,
      );
    } else {
      ok = await cubit.create(
        name: name,
        nameAr: nameAr,
        userPaidDeliveryFees: userPaidDeliveryFees,
        deliveryFeesPaidToDriver: deliveryFeesPaidToDriver,
        minOrderValue: minOrder,
        minRiderQuantity: minRider,
        branchId: _selectedBranchId,
      );
    }

    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeliveryZonesCubit, DeliveryZonesState>(
      builder: (context, state) {
        final saving = state.mutationStatus == ZoneMutationStatus.saving;
        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDeep,
            foregroundColor: AppColors.white,
            title: Text(
              _isEdit ? AppLocalizations.of(context)!.zoneFormEditTitle : AppLocalizations.of(context)!.zoneFormNewTitle,
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
                        child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(AppLocalizations.of(context)!.zoneFormSave,
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 15),
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        )),
              ),
              SizedBox(width: 8.w),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(20.r),
              children: [
                _FieldLabel(AppLocalizations.of(context)!.zoneFormNameEn),
                SizedBox(height: 8.h),
                _buildField(
                  controller: _nameCtrl,
                  hint: 'e.g. Maadi',
                  icon: Icons.location_on_outlined,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? AppLocalizations.of(context)!.zoneFormNameRequired : null,
                ),
                SizedBox(height: 20.h),

                _FieldLabel(AppLocalizations.of(context)!.zoneFormNameAr),
                SizedBox(height: 8.h),
                _buildField(
                  controller: _nameArCtrl,
                  hint: 'مثال: المعادي',
                  icon: Icons.translate_rounded,
                ),
                SizedBox(height: 20.h),

                _FieldLabel(AppLocalizations.of(context)!.zoneFormDeliveryFee),
                SizedBox(height: 8.h),
                _buildField(
                  controller: _feeCtrl,
                  hint: '0',
                  icon: Icons.delivery_dining_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    final d = double.tryParse(v ?? '');
                    if (d == null || d < 0) return AppLocalizations.of(context)!.zoneFormFeeInvalid;
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                _FieldLabel('تكلفة التوصيل الفعلية (Actual Delivery Cost)'),
                SizedBox(height: 4.h),
                Text(
                  'Not visible to customers — used in driver cost calculations',
                  style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 11), color: AppColors.textLight),
                ),
                SizedBox(height: 8.h),
                _buildField(
                  controller: _actualCostCtrl,
                  hint: '0',
                  icon: Icons.price_check_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 20.h),

                _FieldLabel('الفرع المسؤول (Branch)'),
                SizedBox(height: 8.h),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: AppBorderRadius.r12,
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedBranchId,
                      isExpanded: true,
                      hint: Text(
                        'No branch linked',
                        style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13), color: AppColors.textLight),
                      ),
                      style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13), color: AppColors.textDark),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text('No branch', style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13), color: AppColors.textLight)),
                        ),
                        ..._branches.map((b) => DropdownMenuItem<String?>(
                          value: b['id'],
                          child: Text(b['name']!, style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13))),
                        )),
                      ],
                      onChanged: (v) => setState(() => _selectedBranchId = v),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                _FieldLabel(AppLocalizations.of(context)!.zoneFormMinOrder),
                SizedBox(height: 8.h),
                _buildField(
                  controller: _minOrderCtrl,
                  hint: '0',
                  icon: Icons.shopping_bag_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    final d = double.tryParse(v ?? '');
                    if (d == null || d < 0) return AppLocalizations.of(context)!.zoneFormMinInvalid;
                    return null;
                  },
                ),
                SizedBox(height: 4.h),
                Text(
                  AppLocalizations.of(context)!.zoneFormMinOrderHint,
                  style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 11), color: AppColors.textLight),
                ),
                SizedBox(height: 20.h),

                _FieldLabel(AppLocalizations.of(context)!.zoneFormMinItems),
                SizedBox(height: 8.h),
                _buildField(
                  controller: _minRiderCtrl,
                  hint: '0',
                  icon: Icons.inventory_2_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final d = int.tryParse(v ?? '');
                    if (d == null || d < 0) return AppLocalizations.of(context)!.zoneFormMinInvalid;
                    return null;
                  },
                ),
                SizedBox(height: 4.h),
                Text(
                  AppLocalizations.of(context)!.zoneFormMinItemsHint,
                  style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 11), color: AppColors.textLight),
                ),

                if (_isEdit) ...[
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
                        Icon(Icons.toggle_on_outlined, size: 20.r, color: AppColors.textLight),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(AppLocalizations.of(context)!.zoneFormActive,
                              style: GoogleFonts.nunito(
                                fontSize: Responsive.sp(context, 14),
                                color: AppColors.textDark,
                              )),
                        ),
                        Switch(
                          value: _isActive,
                          onChanged: (v) => setState(() => _isActive = v),
                          activeThumbColor: AppColors.primaryDeep,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                  OutlinedButton.icon(
                    onPressed: saving ? null : () => _confirmDelete(context),
                    icon: Icon(Icons.delete_outline_rounded, size: 18.r, color: AppColors.error),
                    label: Text(AppLocalizations.of(context)!.zoneFormDelete,
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 14),
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                        )),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r12),
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
        title: Text(AppLocalizations.of(context)!.zoneFormDeleteTitle,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text(
            'This will permanently delete "${widget.zone!.name}". Existing addresses in this zone will lose their zone reference.',
            style: GoogleFonts.nunito()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.zoneFormCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final cubit = context.read<DeliveryZonesCubit>();
              final nav = Navigator.of(context);
              final ok = await cubit.delete(widget.zone!.id);
              if (ok && mounted) nav.pop();
            },
            child: Text(AppLocalizations.of(context)!.zoneFormDeleteConfirm,
                style: GoogleFonts.nunito(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 14), color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13), color: AppColors.textLight),
        prefixIcon: Icon(icon, size: 20.r, color: AppColors.textLight),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: AppBorderRadius.r12,
            borderSide: BorderSide(color: AppColors.primaryMid, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: AppColors.error)),
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
