import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/model/loyalty_rule_model.dart';
import '../cubits/loyalty_cubit.dart';

class LoyaltyRuleFormScreen extends StatefulWidget {
  static const String routeName = '/loyalty-rule-form';

  const LoyaltyRuleFormScreen({super.key, this.rule});
  final LoyaltyRuleModel? rule;

  @override
  State<LoyaltyRuleFormScreen> createState() => _LoyaltyRuleFormScreenState();
}

class _LoyaltyRuleFormScreenState extends State<LoyaltyRuleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _pointsCtrl;
  late final TextEditingController _minOrderCtrl;
  DateTime? _validFrom;
  DateTime? _validUntil;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isActive = true;
  String _ruleType = 'base_earn';
  bool _pointsHaveExpiry = false;
  late final TextEditingController _expiryDaysCtrl;

  bool get _isEdit => widget.rule != null;

  @override
  void initState() {
    super.initState();
    final r = widget.rule;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _pointsCtrl = TextEditingController(
        text: r != null ? r.pointsPerEgp.toString() : '1');
    _minOrderCtrl = TextEditingController(
        text: r != null ? r.minOrderValue.toStringAsFixed(0) : '0');
    _expiryDaysCtrl = TextEditingController(
        text: r?.pointsExpiryDays?.toString() ?? '30');
    _isActive = r?.isActive ?? true;
    _ruleType = r?.ruleType ?? 'base_earn';
    _pointsHaveExpiry = r?.pointsHaveExpiry ?? false;
    _validFrom = r?.validFrom;
    _validUntil = r?.validUntil;
    if (r?.startTime != null) {
      final parts = r!.startTime!.split(':');
      if (parts.length >= 2) {
        _startTime = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: int.tryParse(parts[1]) ?? 0);
      }
    }
    if (r?.endTime != null) {
      final parts = r!.endTime!.split(':');
      if (parts.length >= 2) {
        _endTime = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: int.tryParse(parts[1]) ?? 0);
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _pointsCtrl.dispose();
    _minOrderCtrl.dispose();
    _expiryDaysCtrl.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate(bool isFrom) async {
    final now = DateTime.now();
    final initial = isFrom
        ? (_validFrom ?? now)
        : (_validUntil ?? (_validFrom ?? now).add(const Duration(days: 30)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryDeep),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _validFrom = picked;
        } else {
          _validUntil = picked;
        }
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart
        ? (_startTime ?? const TimeOfDay(hour: 0, minute: 0))
        : (_endTime ?? const TimeOfDay(hour: 23, minute: 59));
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryDeep),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<LoyaltyCubit>();

    final now = DateTime.now();
    final expiryDays = _pointsHaveExpiry
        ? int.tryParse(_expiryDaysCtrl.text.trim())
        : null;
    AppLogger.d('LoyaltyRuleForm', 'submit ruleType=$_ruleType pointsHaveExpiry=$_pointsHaveExpiry expiryDays=$expiryDays');
    final baseRule = LoyaltyRuleModel(
      id: widget.rule?.id ?? '',
      name: _nameCtrl.text.trim(),
      ruleType: _ruleType,
      pointsPerEgp: double.tryParse(_pointsCtrl.text.trim()) ?? 1,
      minOrderValue: double.tryParse(_minOrderCtrl.text.trim()) ?? 0,
      startTime: _startTime != null ? _formatTime(_startTime!) : null,
      endTime: _endTime != null ? _formatTime(_endTime!) : null,
      validFrom: _validFrom,
      validUntil: _validUntil,
      isActive: _isActive,
      createdAt: widget.rule?.createdAt ?? now,
      pointsHaveExpiry: _pointsHaveExpiry,
      pointsExpiryDays: expiryDays,
    );

    final bool ok;
    if (_isEdit) {
      ok = await cubit.updateRule(baseRule);
    } else {
      ok = await cubit.createRule(baseRule);
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
              _isEdit ? 'Edit Rule' : 'New Rule',
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
                _FieldLabel('Rule Name'),
                SizedBox(height: 8.h),
                _buildTextField(
                  controller: _nameCtrl,
                  hint: 'e.g. Double Points Weekend',
                  icon: Icons.label_outline_rounded,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                SizedBox(height: 20.h),
                _FieldLabel('Rule Type'),
                SizedBox(height: 8.h),
                _buildDropdown(),
                SizedBox(height: 20.h),
                _FieldLabel('Points per EGP Spent'),
                SizedBox(height: 8.h),
                _buildTextField(
                  controller: _pointsCtrl,
                  hint: '1',
                  icon: Icons.stars_rounded,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    final d = double.tryParse(v ?? '');
                    if (d == null || d <= 0) return 'Enter a value greater than 0';
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                _FieldLabel('Minimum Order Value (EGP) — optional'),
                SizedBox(height: 8.h),
                _buildTextField(
                  controller: _minOrderCtrl,
                  hint: '0',
                  icon: Icons.shopping_bag_outlined,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    final d = double.tryParse(v ?? '');
                    if (d == null || d < 0) return 'Enter 0 or more';
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                _FieldLabel('Valid From — optional'),
                SizedBox(height: 8.h),
                _buildDateRow(
                  label: _validFrom != null ? _formatDate(_validFrom!) : 'Select date',
                  icon: Icons.calendar_today_outlined,
                  onTap: () => _pickDate(true),
                  onClear: _validFrom != null
                      ? () => setState(() => _validFrom = null)
                      : null,
                ),
                SizedBox(height: 20.h),
                _FieldLabel('Valid Until — optional'),
                SizedBox(height: 8.h),
                _buildDateRow(
                  label: _validUntil != null ? _formatDate(_validUntil!) : 'Select date',
                  icon: Icons.calendar_today_outlined,
                  onTap: () => _pickDate(false),
                  onClear: _validUntil != null
                      ? () => setState(() => _validUntil = null)
                      : null,
                ),
                SizedBox(height: 20.h),
                _FieldLabel('Daily Start Time — optional'),
                SizedBox(height: 8.h),
                _buildDateRow(
                  label: _startTime != null
                      ? _startTime!.format(context)
                      : 'Select time',
                  icon: Icons.access_time_outlined,
                  onTap: () => _pickTime(true),
                  onClear: _startTime != null
                      ? () => setState(() => _startTime = null)
                      : null,
                ),
                SizedBox(height: 20.h),
                _FieldLabel('Daily End Time — optional'),
                SizedBox(height: 8.h),
                _buildDateRow(
                  label: _endTime != null
                      ? _endTime!.format(context)
                      : 'Select time',
                  icon: Icons.access_time_outlined,
                  onTap: () => _pickTime(false),
                  onClear: _endTime != null
                      ? () => setState(() => _endTime = null)
                      : null,
                ),
                SizedBox(height: 20.h),
                // Points expiry toggle
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: AppBorderRadius.r12,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 20.r, color: AppColors.textLight),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Points Have Expiry',
                              style: GoogleFonts.nunito(
                                fontSize: Responsive.sp(context, 14),
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              _pointsHaveExpiry
                                  ? 'Points expire after the set days'
                                  : 'Points never expire (permanent)',
                              style: GoogleFonts.nunito(
                                fontSize: Responsive.sp(context, 11),
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _pointsHaveExpiry,
                        onChanged: (v) => setState(() => _pointsHaveExpiry = v),
                        activeThumbColor: AppColors.primaryDeep,
                      ),
                    ],
                  ),
                ),
                if (_pointsHaveExpiry) ...[
                  SizedBox(height: 12.h),
                  _FieldLabel('Points Expiry (days after earning)'),
                  SizedBox(height: 8.h),
                  _buildTextField(
                    controller: _expiryDaysCtrl,
                    hint: '30',
                    icon: Icons.hourglass_bottom_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (!_pointsHaveExpiry) return null;
                      final d = int.tryParse(v ?? '');
                      if (d == null || d <= 0) return 'Enter a positive number of days';
                      return null;
                    },
                  ),
                ],
                SizedBox(height: 20.h),
                // Active toggle
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 4.h),
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
                      'Delete Rule',
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
        title: Text('Delete Rule?',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text(
          'This will permanently delete "${widget.rule!.name}".',
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
              final nav = Navigator.of(context);
              await cubit.deleteRule(widget.rule!.id);
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

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r12,
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _ruleType,
          isExpanded: true,
          style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 14),
              color: AppColors.textDark),
          items: const [
            DropdownMenuItem(
                value: 'base_earn', child: Text('Base Earn')),
            DropdownMenuItem(
                value: 'cashback_event', child: Text('Cashback Event')),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _ruleType = v);
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.nunito(
          fontSize: Responsive.sp(context, 14), color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 13), color: AppColors.textLight),
        prefixIcon: Icon(icon, size: 20.r, color: AppColors.textLight),
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
            borderSide:
                BorderSide(color: AppColors.primaryMid, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: AppBorderRadius.r12,
            borderSide: BorderSide(color: AppColors.error)),
      ),
    );
  }

  Widget _buildDateRow({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppBorderRadius.r12,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.r, color: AppColors.textLight),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 14),
                  color: onClear != null
                      ? AppColors.textDark
                      : AppColors.textLight,
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded,
                    size: 18.r, color: AppColors.textLight),
              ),
          ],
        ),
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
