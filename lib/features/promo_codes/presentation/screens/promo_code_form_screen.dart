import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import '../../data/model/promo_code_model.dart';
import '../cubits/promo_codes_cubit.dart';

class PromoCodeFormScreen extends StatefulWidget {
  const PromoCodeFormScreen({super.key, this.code});
  final PromoCodeModel? code;

  @override
  State<PromoCodeFormScreen> createState() => _PromoCodeFormScreenState();
}

class _PromoCodeFormScreenState extends State<PromoCodeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _codeCtrl =
      TextEditingController(text: widget.code?.code ?? '');
  late final _discountCtrl = TextEditingController(
      text: widget.code?.discountValue != 0
          ? widget.code?.discountValue.toStringAsFixed(0) ?? ''
          : '');
  late final _minOrderCtrl = TextEditingController(
      text: widget.code?.minOrder != 0
          ? widget.code?.minOrder.toStringAsFixed(0) ?? ''
          : '');
  late final _maxUsesCtrl =
      TextEditingController(text: widget.code?.maxUses?.toString() ?? '');
  late final _maxPerUserCtrl = TextEditingController(
      text: widget.code?.maxUsesPerUser.toString() ?? '1');
  late final _descCtrl =
      TextEditingController(text: widget.code?.description ?? '');
  late final _cashbackExpiryDaysCtrl = TextEditingController(
      text: widget.code?.cashbackExpiryDays?.toString() ?? '30');
  late bool _cashbackPointsExpire = widget.code?.cashbackExpiryDays != null;
  late PromoType _type = widget.code?.type ?? PromoType.percentage;
  late bool _isActive = widget.code?.isActive ?? true;
  late DateTime? _expiresAt = widget.code?.expiresAt;
  late DateTime? _startsAt = widget.code?.startsAt;

  bool get _isEditing => widget.code != null;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _discountCtrl.dispose();
    _minOrderCtrl.dispose();
    _maxUsesCtrl.dispose();
    _maxPerUserCtrl.dispose();
    _descCtrl.dispose();
    _cashbackExpiryDaysCtrl.dispose();
    super.dispose();
  }

  void _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random();
    final code = List.generate(8, (_) => chars[rng.nextInt(chars.length)]).join();
    setState(() => _codeCtrl.text = code);
  }

  Future<void> _pickDate(bool isExpiry) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isExpiry ? _expiresAt : _startsAt) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primaryDeep),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isExpiry) { _expiresAt = picked; }
      else { _startsAt = picked; }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<PromoCodesCubit>();
    final discountValue =
        double.tryParse(_discountCtrl.text.trim()) ?? 0;
    final minOrder = double.tryParse(_minOrderCtrl.text.trim()) ?? 0;
    final maxUses =
        _maxUsesCtrl.text.trim().isEmpty ? null : int.tryParse(_maxUsesCtrl.text.trim());
    final maxPerUser = int.tryParse(_maxPerUserCtrl.text.trim()) ?? 1;

    final cashbackExpiryDays = _type == PromoType.cashback && _cashbackPointsExpire
        ? int.tryParse(_cashbackExpiryDaysCtrl.text.trim())
        : null;

    bool ok;
    if (_isEditing) {
      ok = await cubit.update(
        id:                 widget.code!.id,
        code:               _codeCtrl.text.trim(),
        type:               _type,
        discountValue:      discountValue,
        minOrder:           minOrder,
        maxUses:            maxUses,
        expiresAt:          _expiresAt,
        startsAt:           _startsAt,
        isActive:           _isActive,
        description:        _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        maxUsesPerUser:     maxPerUser,
        cashbackExpiryDays: cashbackExpiryDays,
      );
    } else {
      ok = await cubit.create(
        code:               _codeCtrl.text.trim(),
        type:               _type,
        discountValue:      discountValue,
        minOrder:           minOrder,
        maxUses:            maxUses,
        expiresAt:          _expiresAt,
        startsAt:           _startsAt,
        description:        _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        maxUsesPerUser:     maxPerUser,
        cashbackExpiryDays: cashbackExpiryDays,
      );
    }
    if (ok && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDeep,
        foregroundColor: AppColors.white,
        title: Text(
          _isEditing ? l10n.promoCodeFormEditTitle : l10n.promoCodeFormNewTitle,
          style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 18),
              fontWeight: FontWeight.w700,
              color: AppColors.white),
        ),
      ),
      body: BlocBuilder<PromoCodesCubit, PromoCodesState>(
        builder: (context, state) {
          final isSaving = state.mutationStatus == PromoMutationStatus.saving;
          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(20.r),
              children: [
                // Code field
                _Label(text: l10n.promoCodeFormCodeField),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: _codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                  ],
                  style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 15),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: AppColors.textDark),
                  decoration: _decoration(
                    icon: Icons.confirmation_number_outlined,
                    hint: 'e.g. SUMMER20',
                    suffix: IconButton(
                      icon: Icon(Icons.auto_awesome_rounded,
                          size: 18.r, color: AppColors.primaryMid),
                      onPressed: _generateCode,
                      tooltip: l10n.promoCodeFormGenerate,
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? l10n.promoCodeFormCodeRequired : null,
                ),
                SizedBox(height: 16.h),

                // Type dropdown
                _Label(text: l10n.promoCodeFormDiscountType),
                SizedBox(height: 6.h),
                DropdownButtonFormField<PromoType>(
                  value: _type,
                  decoration: _decoration(icon: Icons.discount_outlined),
                  style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 14),
                      color: AppColors.textDark),
                  items: PromoType.values
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                      .toList(),
                  onChanged: (t) => setState(() => _type = t!),
                ),
                SizedBox(height: 16.h),

                // Discount value (only for percentage/fixed/cashback)
                if (_type.hasDiscountValue) ...[
                  _Label(
                      text: _type == PromoType.cashback
                          ? 'Cashback % of Order Total'
                          : _type == PromoType.percentage
                              ? l10n.promoCodeFormDiscountPct
                              : l10n.promoCodeFormDiscountAmount),
                  SizedBox(height: 6.h),
                  TextFormField(
                    controller: _discountCtrl,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 14),
                        color: AppColors.textDark),
                    decoration: _decoration(
                      icon: _type == PromoType.cashback
                          ? Icons.stars_rounded
                          : _type == PromoType.percentage
                              ? Icons.percent_rounded
                              : Icons.attach_money_rounded,
                      hint: _type == PromoType.percentage || _type == PromoType.cashback ? '10' : '50',
                      suffixText: _type == PromoType.cashback || _type == PromoType.percentage
                          ? '%'
                          : 'EGP',
                    ),
                    validator: (v) {
                      if (!_type.hasDiscountValue) return null;
                      final n = double.tryParse(v ?? '');
                      if (n == null || n <= 0) return l10n.promoCodeFormInvalidValue;
                      if ((_type == PromoType.percentage || _type == PromoType.cashback) && n > 100) {
                        return l10n.promoCodeFormPctMax;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                ],

                // Cashback expiry toggle + days (only for cashback type)
                if (_type == PromoType.cashback) ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppBorderRadius.r12,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(children: [
                      Icon(Icons.timer_outlined, size: 20.r, color: AppColors.textLight),
                      SizedBox(width: 10.w),
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
                              _cashbackPointsExpire
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
                        value: _cashbackPointsExpire,
                        onChanged: (v) => setState(() => _cashbackPointsExpire = v),
                        activeThumbColor: AppColors.primaryDeep,
                      ),
                    ]),
                  ),
                  if (_cashbackPointsExpire) ...[
                    SizedBox(height: 12.h),
                    _Label(text: 'Points Expiry (days after earning)'),
                    SizedBox(height: 6.h),
                    TextFormField(
                      controller: _cashbackExpiryDaysCtrl,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 14),
                          color: AppColors.textDark),
                      decoration: _decoration(
                        icon: Icons.hourglass_bottom_rounded,
                        hint: '30',
                      ),
                      validator: (v) {
                        if (!_cashbackPointsExpire) return null;
                        final n = int.tryParse(v?.trim() ?? '');
                        if (n == null || n <= 0) return 'Enter a positive number of days';
                        return null;
                      },
                    ),
                  ],
                  SizedBox(height: 16.h),
                ],

                // Description
                _Label(text: l10n.promoCodeFormDescription),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 2,
                  style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 14),
                      color: AppColors.textDark),
                  decoration: _decoration(
                      icon: Icons.notes_rounded, hint: 'Internal note or display text'),
                ),
                SizedBox(height: 16.h),

                // Min order
                _Label(text: l10n.promoCodeFormMinOrder),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: _minOrderCtrl,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 14),
                      color: AppColors.textDark),
                  decoration: _decoration(
                      icon: Icons.shopping_cart_outlined, hint: '0 = no minimum'),
                ),
                SizedBox(height: 16.h),

                // Max uses + per user row
                Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _Label(text: l10n.promoCodeFormMaxUses),
                      SizedBox(height: 6.h),
                      TextFormField(
                        controller: _maxUsesCtrl,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 14),
                            color: AppColors.textDark),
                        decoration:
                            _decoration(icon: Icons.people_outline_rounded, hint: '∞'),
                      ),
                    ]),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _Label(text: l10n.promoCodeFormPerUser),
                      SizedBox(height: 6.h),
                      TextFormField(
                        controller: _maxPerUserCtrl,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 14),
                            color: AppColors.textDark),
                        decoration: _decoration(
                            icon: Icons.person_outline_rounded, hint: '1'),
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n < 1) return l10n.promoCodeFormMin1;
                          return null;
                        },
                      ),
                    ]),
                  ),
                ]),
                SizedBox(height: 16.h),

                // Date pickers
                _DatePickerRow(
                  label: l10n.promoCodeFormStartDate,
                  date: _startsAt,
                  onPick: () => _pickDate(false),
                  onClear: () => setState(() => _startsAt = null),
                ),
                SizedBox(height: 12.h),
                _DatePickerRow(
                  label: l10n.promoCodeFormExpiryDate,
                  date: _expiresAt,
                  onPick: () => _pickDate(true),
                  onClear: () => setState(() => _expiresAt = null),
                ),
                SizedBox(height: 16.h),

                // Active toggle
                if (_isEditing) ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppBorderRadius.r12,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(children: [
                      Icon(Icons.toggle_on_outlined,
                          color: AppColors.textLight, size: 20.r),
                      SizedBox(width: 12.w),
                      Expanded(
                          child: Text(l10n.promoCodeFormActive,
                              style: GoogleFonts.nunito(
                                  fontSize: Responsive.sp(context, 14),
                                  color: AppColors.textDark))),
                      Switch(
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                        activeThumbColor: AppColors.primaryDeep,
                      ),
                    ]),
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
                                strokeWidth: 2, color: Colors.white))
                        : Text(
                            _isEditing ? l10n.promoCodeFormSaveChanges : l10n.promoCodeFormCreate,
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

  InputDecoration _decoration({
    required IconData icon,
    String? hint,
    String? suffixText,
    Widget? suffix,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 13), color: AppColors.textLight),
        suffixText: suffixText,
        suffixStyle: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 13), color: AppColors.textLight),
        suffix: suffix,
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
          Icon(
            Icons.calendar_today_outlined,
            size: 18.r,
            color: date != null ? AppColors.primaryMid : AppColors.textLight,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              date != null
                  ? '${label.split(' ').first}: ${DateFormat('MMM d, y').format(date!)}'
                  : label,
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 13),
                color: date != null ? AppColors.textDark : AppColors.textLight,
              ),
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

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue newVal) =>
      newVal.copyWith(text: newVal.text.toUpperCase());
}
