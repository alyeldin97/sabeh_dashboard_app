import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import '../../data/model/branch_model.dart';
import '../cubits/branches_cubit.dart';

class BranchFormScreen extends StatefulWidget {
  const BranchFormScreen({super.key, this.branch});
  final BranchModel? branch;

  @override
  State<BranchFormScreen> createState() => _BranchFormScreenState();
}

class _BranchFormScreenState extends State<BranchFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late final TextEditingController _radiusCtrl;
  bool _isActive = true;

  bool get _isEdit => widget.branch != null;

  @override
  void initState() {
    super.initState();
    final b = widget.branch;
    _nameCtrl   = TextEditingController(text: b?.name ?? '');
    _latCtrl    = TextEditingController(text: b != null ? b.lat.toString() : '');
    _lngCtrl    = TextEditingController(text: b != null ? b.lng.toString() : '');
    _radiusCtrl = TextEditingController(text: b != null ? b.coverageRadius.toString() : '10.0');
    _isActive   = b?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _radiusCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<BranchesCubit>();
    final name   = _nameCtrl.text.trim();
    final lat    = double.parse(_latCtrl.text.trim());
    final lng    = double.parse(_lngCtrl.text.trim());
    final radius = double.parse(_radiusCtrl.text.trim());

    bool ok;
    if (_isEdit) {
      ok = await cubit.update(
        id:         widget.branch!.id,
        name:       name,
        lat:        lat,
        lng:        lng,
        coverageKm: radius,
        isActive:   _isActive,
      );
    } else {
      ok = await cubit.create(name: name, lat: lat, lng: lng, coverageKm: radius);
    }

    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BranchesCubit, BranchesState>(
      builder: (context, state) {
        final saving = state.mutationStatus == BranchMutationStatus.saving;
        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDeep,
            foregroundColor: AppColors.white,
            title: Text(
              _isEdit ? 'Edit Branch' : 'New Branch',
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
                _FieldLabel('Branch Name'),
                SizedBox(height: 8.h),
                _buildField(
                  controller: _nameCtrl,
                  hint: 'e.g. Downtown Branch',
                  icon: Icons.store_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                SizedBox(height: 20.h),
                _FieldLabel('Latitude'),
                SizedBox(height: 8.h),
                _buildField(
                  controller: _latCtrl,
                  hint: 'e.g. 30.0444',
                  icon: Icons.location_on_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  validator: (v) {
                    final d = double.tryParse(v ?? '');
                    if (d == null) return 'Enter a valid latitude';
                    if (d < -90 || d > 90) return 'Latitude must be between -90 and 90';
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                _FieldLabel('Longitude'),
                SizedBox(height: 8.h),
                _buildField(
                  controller: _lngCtrl,
                  hint: 'e.g. 31.2357',
                  icon: Icons.location_on_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  validator: (v) {
                    final d = double.tryParse(v ?? '');
                    if (d == null) return 'Enter a valid longitude';
                    if (d < -180 || d > 180) return 'Longitude must be between -180 and 180';
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                _FieldLabel('Coverage Radius (km)'),
                SizedBox(height: 8.h),
                _buildField(
                  controller: _radiusCtrl,
                  hint: 'e.g. 10.0',
                  icon: Icons.radar_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    final d = double.tryParse(v ?? '');
                    if (d == null || d <= 0) return 'Enter a valid radius > 0';
                    return null;
                  },
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
                ],
                if (_isEdit) ...[
                  SizedBox(height: 32.h),
                  OutlinedButton.icon(
                    onPressed: saving
                        ? null
                        : () => _confirmDelete(context),
                    icon: Icon(Icons.delete_outline_rounded, size: 18.r, color: AppColors.error),
                    label: Text(
                      'Delete Branch',
                      style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 14),
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
        title: Text('Delete Branch?',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text('This will permanently delete "${widget.branch!.name}". This cannot be undone.',
            style: GoogleFonts.nunito()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final cubit = context.read<BranchesCubit>();
              final nav = Navigator.of(context);
              final ok = await cubit.delete(id: widget.branch!.id);
              if (ok && mounted) nav.pop();
            },
            child: Text('Delete',
                style: GoogleFonts.nunito(color: AppColors.error, fontWeight: FontWeight.w700)),
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
      style: GoogleFonts.nunito(
        fontSize: Responsive.sp(context, 14),
        color: AppColors.textDark,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 13), color: AppColors.textLight),
        prefixIcon: Icon(icon, size: 20.r, color: AppColors.textLight),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
