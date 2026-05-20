import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import '../../../auth/data/model/staff_user.dart';
import '../../../branches/data/model/branch_model.dart';
import '../../../branches/presentation/cubits/branches_cubit.dart';
import '../../data/model/staff_member.dart';
import '../cubits/staff_cubit.dart';

class StaffFormScreen extends StatefulWidget {
  const StaffFormScreen({super.key, this.member});
  final StaffMember? member;

  @override
  State<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends State<StaffFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.member?.name ?? '');
  late final _phoneCtrl =
      TextEditingController(text: widget.member?.phone ?? '');
  final _passwordCtrl = TextEditingController();
  late StaffRole _role = widget.member?.role ?? StaffRole.customerService;
  late List<String> _selectedBranchIds =
      List<String>.from(widget.member?.branchIds ?? []);
  late bool _isActive = widget.member?.isActive ?? true;

  bool get _isEditing => widget.member != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<StaffCubit>();
    final phone = _phoneCtrl.text.trim();
    final branchIds = _role.isScoped ? _selectedBranchIds : <String>[];

    bool ok;
    if (_isEditing) {
      ok = await cubit.update(
        id:        widget.member!.id,
        name:      _nameCtrl.text.trim(),
        role:      _role,
        branchIds: branchIds,
        isActive:  _isActive,
        phone:     phone.isEmpty ? null : phone,
      );
    } else {
      ok = await cubit.create(
        phone:     phone,
        password:  _passwordCtrl.text.trim(),
        name:      _nameCtrl.text.trim(),
        role:      _role,
        branchIds: branchIds,
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
          _isEditing ? 'Edit Staff Member' : 'Add Staff Member',
          style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 18),
              fontWeight: FontWeight.w700,
              color: AppColors.white),
        ),
      ),
      body: BlocBuilder<StaffCubit, StaffState>(
        builder: (context, state) {
          final isSaving = state.mutationStatus == StaffMutationStatus.saving;
          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(20.r),
              children: [
                _field(
                  label: 'Full Name',
                  controller: _nameCtrl,
                  icon: Icons.person_outline_rounded,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                SizedBox(height: 16.h),
                _field(
                  label: _isEditing ? 'Phone (optional)' : 'Phone Number',
                  controller: _phoneCtrl,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: _isEditing
                      ? null
                      : (v) => (v == null || v.trim().isEmpty)
                          ? 'Phone number is required'
                          : null,
                ),
                SizedBox(height: 16.h),
                if (!_isEditing) ...[
                  _field(
                    label: 'Temporary Password',
                    controller: _passwordCtrl,
                    icon: Icons.lock_outline_rounded,
                    obscureText: true,
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Password must be at least 6 characters'
                        : null,
                  ),
                  SizedBox(height: 16.h),
                ],

                // Role dropdown
                _Label(text: 'Role'),
                SizedBox(height: 6.h),
                DropdownButtonFormField<StaffRole>(
                  value: _role,
                  decoration: _inputDecoration(icon: Icons.badge_outlined),
                  style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 14),
                      color: AppColors.textDark),
                  items: StaffRole.values
                      .map((r) =>
                          DropdownMenuItem(value: r, child: Text(r.label)))
                      .toList(),
                  onChanged: (r) => setState(() {
                    _role = r!;
                    if (!_role.isScoped) _selectedBranchIds = [];
                  }),
                ),
                SizedBox(height: 16.h),

                // Branch multi-select (only for scoped roles)
                if (_role.isScoped) ...[
                  _Label(text: 'Branches'),
                  SizedBox(height: 6.h),
                  BlocBuilder<BranchesCubit, BranchesState>(
                    builder: (context, branchState) {
                      final branches = branchState.branches;
                      if (branches.isEmpty) {
                        return Text('No branches available',
                            style: GoogleFonts.nunito(
                                color: AppColors.textLight,
                                fontSize: Responsive.sp(context, 13)));
                      }
                      return Column(
                        children: branches
                            .map((b) => _BranchCheckbox(
                                  branch: b,
                                  checked: _selectedBranchIds.contains(b.id),
                                  onChanged: (checked) => setState(() {
                                    if (checked) {
                                      _selectedBranchIds.add(b.id);
                                    } else {
                                      _selectedBranchIds.remove(b.id);
                                    }
                                  }),
                                ))
                            .toList(),
                      );
                    },
                  ),
                  // Validate at least one branch
                  FormField<List<String>>(
                    initialValue: _selectedBranchIds,
                    validator: (_) => _role.isScoped && _selectedBranchIds.isEmpty
                        ? 'Select at least one branch'
                        : null,
                    builder: (field) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) field.didChange(_selectedBranchIds);
                      });
                      return field.hasError
                          ? Padding(
                              padding: EdgeInsets.only(top: 4.h, left: 14.w),
                              child: Text(field.errorText!,
                                  style: GoogleFonts.nunito(
                                      fontSize: Responsive.sp(context, 11),
                                      color: AppColors.error)),
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                  SizedBox(height: 16.h),
                ],

                // Active toggle (edit only)
                if (_isEditing) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppBorderRadius.r12,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.toggle_on_outlined,
                            color: AppColors.textLight, size: 20.r),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text('Active',
                              style: GoogleFonts.nunito(
                                  fontSize: Responsive.sp(context, 14),
                                  color: AppColors.textDark)),
                        ),
                        Switch(
                          value: _isActive,
                          onChanged: (v) => setState(() => _isActive = v),
                          activeThumbColor: AppColors.primaryDeep,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
                SizedBox(height: 8.h),
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
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            _isEditing ? 'Save Changes' : 'Create Staff Account',
                            style: GoogleFonts.nunito(
                                fontSize: Responsive.sp(context, 15),
                                fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration({required IconData icon}) => InputDecoration(
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

  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(text: label),
          SizedBox(height: 6.h),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 14), color: AppColors.textDark),
            decoration: _inputDecoration(icon: icon),
            validator: validator,
          ),
        ],
      );
}

class _BranchCheckbox extends StatelessWidget {
  const _BranchCheckbox({
    required this.branch,
    required this.checked,
    required this.onChanged,
  });
  final BranchModel branch;
  final bool checked;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: checked
            ? AppColors.primaryDeep.withValues(alpha: 0.05)
            : AppColors.white,
        borderRadius: AppBorderRadius.r12,
        border: Border.all(
            color: checked ? AppColors.primaryMid : AppColors.border,
            width: checked ? 1.5 : 1),
      ),
      child: CheckboxListTile(
        value: checked,
        onChanged: (v) => onChanged(v ?? false),
        title: Text(branch.name,
            style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 14),
                color: AppColors.textDark,
                fontWeight: checked ? FontWeight.w600 : FontWeight.w400)),
        activeColor: AppColors.primaryDeep,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r12),
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
