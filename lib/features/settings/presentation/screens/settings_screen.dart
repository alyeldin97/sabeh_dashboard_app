import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/locale/locale_cubit.dart';
import '../../../../core/styling/colors.dart';
import '../../../app_settings/presentation/cubits/app_settings_cubit.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _feeCtrl                = TextEditingController();
  final _maxPtsCtrl             = TextEditingController();
  final _refBonusCtrl           = TextEditingController();
  final _refRewardCtrl          = TextEditingController();
  final _onlineWindowCtrl       = TextEditingController();
  final _latePendingCtrl        = TextEditingController();
  final _lateConfirmedCtrl      = TextEditingController();
  final _latePreparingCtrl      = TextEditingController();
  final _latePreparedCtrl       = TextEditingController();
  final _lateOutDeliveryCtrl    = TextEditingController();
  final _whatsappCtrl           = TextEditingController();
  bool _feeEnabled = false;
  bool _dirty = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = context.read<AppSettingsCubit>().state.settings;
    if (settings != null && !_dirty) {
      _feeCtrl.text             = settings.serviceFeeValue.toStringAsFixed(2);
      _feeEnabled               = settings.serviceFeeEnabled;
      _maxPtsCtrl.text          = settings.loyaltyMaxPointsPerOrder.toString();
      _refBonusCtrl.text        = settings.loyaltyReferralBonus.toString();
      _refRewardCtrl.text       = settings.loyaltyReferralReward.toString();
      _onlineWindowCtrl.text    = settings.onlineWindowMinutes.toString();
      _latePendingCtrl.text     = settings.latePendingMinutes.toString();
      _lateConfirmedCtrl.text   = settings.lateConfirmedMinutes.toString();
      _latePreparingCtrl.text   = settings.latePreparingMinutes.toString();
      _latePreparedCtrl.text    = settings.latePreparedMinutes.toString();
      _lateOutDeliveryCtrl.text = settings.lateOutForDeliveryMinutes.toString();
      _whatsappCtrl.text        = settings.whatsappNumber ?? '';
    }
  }

  @override
  void dispose() {
    _feeCtrl.dispose();
    _maxPtsCtrl.dispose();
    _refBonusCtrl.dispose();
    _refRewardCtrl.dispose();
    _onlineWindowCtrl.dispose();
    _latePendingCtrl.dispose();
    _lateConfirmedCtrl.dispose();
    _latePreparingCtrl.dispose();
    _latePreparedCtrl.dispose();
    _lateOutDeliveryCtrl.dispose();
    _whatsappCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final value                = double.tryParse(_feeCtrl.text) ?? 0;
    final maxPts               = int.tryParse(_maxPtsCtrl.text) ?? 0;
    final refBonus             = int.tryParse(_refBonusCtrl.text) ?? 50;
    final refReward            = int.tryParse(_refRewardCtrl.text) ?? 50;
    final onlineWindow         = (int.tryParse(_onlineWindowCtrl.text) ?? 3).clamp(1, 60);
    final latePending          = (int.tryParse(_latePendingCtrl.text) ?? 30).clamp(1, 999);
    final lateConfirmed        = (int.tryParse(_lateConfirmedCtrl.text) ?? 30).clamp(1, 999);
    final latePreparing        = (int.tryParse(_latePreparingCtrl.text) ?? 30).clamp(1, 999);
    final latePrepared         = (int.tryParse(_latePreparedCtrl.text) ?? 30).clamp(1, 999);
    final lateOutForDelivery   = (int.tryParse(_lateOutDeliveryCtrl.text) ?? 60).clamp(1, 999);
    context.read<AppSettingsCubit>().save(
          serviceFeeValue:           value,
          serviceFeeEnabled:         _feeEnabled,
          loyaltyMaxPointsPerOrder:  maxPts,
          loyaltyReferralBonus:      refBonus,
          loyaltyReferralReward:     refReward,
          onlineWindowMinutes:       onlineWindow,
          latePendingMinutes:        latePending,
          lateConfirmedMinutes:      lateConfirmed,
          latePreparingMinutes:      latePreparing,
          latePreparedMinutes:       latePrepared,
          lateOutForDeliveryMinutes: lateOutForDelivery,
          whatsappNumber:            _whatsappCtrl.text.trim(),
        );
    setState(() => _dirty = false);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDeep,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.settingsTitle,
          style: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 20),
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ),
      body: BlocListener<AppSettingsCubit, AppSettingsState>(
        listener: (context, state) {
          if (state.status == AppSettingsStatus.loaded && state.settings != null && !_dirty) {
            _feeCtrl.text             = state.settings!.serviceFeeValue.toStringAsFixed(2);
            _maxPtsCtrl.text          = state.settings!.loyaltyMaxPointsPerOrder.toString();
            _refBonusCtrl.text        = state.settings!.loyaltyReferralBonus.toString();
            _refRewardCtrl.text       = state.settings!.loyaltyReferralReward.toString();
            _onlineWindowCtrl.text    = state.settings!.onlineWindowMinutes.toString();
            _latePendingCtrl.text     = state.settings!.latePendingMinutes.toString();
            _lateConfirmedCtrl.text   = state.settings!.lateConfirmedMinutes.toString();
            _latePreparingCtrl.text   = state.settings!.latePreparingMinutes.toString();
            _latePreparedCtrl.text    = state.settings!.latePreparedMinutes.toString();
            _lateOutDeliveryCtrl.text = state.settings!.lateOutForDeliveryMinutes.toString();
            _whatsappCtrl.text        = state.settings!.whatsappNumber ?? '';
            setState(() => _feeEnabled = state.settings!.serviceFeeEnabled);
          }
          if (state.status == AppSettingsStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? l10n.settingsSaveFailed),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state.status == AppSettingsStatus.loaded && _dirty == false) {
            // saved successfully — show confirmation
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            final user = authState.user;
            return ListView(
              padding: EdgeInsets.all(16.r),
              children: [
                // Profile card
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: AppBorderRadius.r12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52.r,
                        height: 52.r,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDeep,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            user?.name.isNotEmpty == true
                                ? user!.name[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.nunito(
                              fontSize: Responsive.sp(context, 22),
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? l10n.navStaffFallback,
                              style: GoogleFonts.nunito(
                                fontSize: Responsive.sp(context, 16),
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              user?.role.value.replaceAll('_', ' ').toUpperCase() ?? '',
                              style: GoogleFonts.nunito(
                                fontSize: Responsive.sp(context, 12),
                                color: AppColors.primaryMid,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              user?.email ?? '',
                              style: GoogleFonts.nunito(
                                fontSize: Responsive.sp(context, 12),
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Service Fee section
                BlocBuilder<AppSettingsCubit, AppSettingsState>(
                  builder: (context, settingsState) {
                    final isLoading = settingsState.status == AppSettingsStatus.loading;
                    final isSaving  = settingsState.status == AppSettingsStatus.saving;

                    return Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: AppBorderRadius.r12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36.r,
                                height: 36.r,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E0),
                                  borderRadius: AppBorderRadius.r8,
                                ),
                                child: const Icon(
                                  Icons.receipt_long_outlined,
                                  color: Color(0xFFE65100),
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                l10n.settingsServiceFee,
                                style: GoogleFonts.nunito(
                                  fontSize: Responsive.sp(context, 16),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // Enabled toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.settingsShowInCheckout,
                                    style: GoogleFonts.nunito(
                                      fontSize: Responsive.sp(context, 14),
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  Text(
                                    l10n.settingsShowInCheckoutSubtitle,
                                    style: GoogleFonts.nunito(
                                      fontSize: Responsive.sp(context, 11),
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ],
                              ),
                              isLoading
                                  ? SizedBox(
                                      width: 24.r,
                                      height: 24.r,
                                      child: const CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Switch(
                                      value: _feeEnabled,
                                      activeThumbColor: AppColors.primaryDeep,
                                      onChanged: (v) => setState(() {
                                        _feeEnabled = v;
                                        _dirty = true;
                                      }),
                                    ),
                            ],
                          ),

                          SizedBox(height: 16.h),

                          // Fee value field
                          Text(
                            l10n.settingsFeeAmount,
                            style: GoogleFonts.nunito(
                              fontSize: Responsive.sp(context, 13),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textLight,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          TextField(
                            controller: _feeCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            style: GoogleFonts.nunito(
                              fontSize: Responsive.sp(context, 15),
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                            onChanged: (_) => setState(() => _dirty = true),
                            decoration: InputDecoration(
                              prefixText: 'EGP  ',
                              prefixStyle: GoogleFonts.nunito(
                                fontSize: Responsive.sp(context, 14),
                                color: AppColors.textLight,
                              ),
                              filled: true,
                              fillColor: AppColors.scaffoldBg,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: AppBorderRadius.r8,
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppBorderRadius.r8,
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: AppBorderRadius.r8,
                                borderSide: BorderSide(color: AppColors.primaryMid, width: 2),
                              ),
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Max loyalty points per order
                          Text(
                            l10n.settingsMaxPoints,
                            style: GoogleFonts.nunito(
                              fontSize: Responsive.sp(context, 13),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textLight,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          TextField(
                            controller: _maxPtsCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: GoogleFonts.nunito(
                              fontSize: Responsive.sp(context, 15),
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                            onChanged: (_) => setState(() => _dirty = true),
                            decoration: InputDecoration(
                              hintText: '0',
                              prefixIcon: Icon(Icons.stars_rounded, size: 18, color: AppColors.textLight),
                              filled: true,
                              fillColor: AppColors.scaffoldBg,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: AppBorderRadius.r8,
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppBorderRadius.r8,
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: AppBorderRadius.r8,
                                borderSide: BorderSide(color: AppColors.primaryMid, width: 2),
                              ),
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Online presence window
                          Text(
                            l10n.settingsOnlineWindow,
                            style: GoogleFonts.nunito(
                              fontSize: Responsive.sp(context, 13),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textLight,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            l10n.settingsOnlineWindowDesc,
                            style: GoogleFonts.nunito(
                              fontSize: Responsive.sp(context, 11),
                              color: AppColors.textLight,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          TextField(
                            controller: _onlineWindowCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: GoogleFonts.nunito(
                              fontSize: Responsive.sp(context, 15),
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                            onChanged: (_) => setState(() => _dirty = true),
                            decoration: InputDecoration(
                              hintText: '3',
                              suffixText: 'min',
                              prefixIcon: Icon(Icons.wifi_rounded, size: 18, color: AppColors.textLight),
                              filled: true,
                              fillColor: AppColors.scaffoldBg,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: AppBorderRadius.r8, borderSide: BorderSide(color: AppColors.border)),
                              enabledBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r8, borderSide: BorderSide(color: AppColors.border)),
                              focusedBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r8, borderSide: BorderSide(color: AppColors.primaryMid, width: 2)),
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Referral bonus (referrer gets this)
                          Text(
                            l10n.settingsReferralBonusReferrer,
                            style: GoogleFonts.nunito(
                              fontSize: Responsive.sp(context, 13),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textLight,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          TextField(
                            controller: _refBonusCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: GoogleFonts.nunito(
                              fontSize: Responsive.sp(context, 15),
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                            onChanged: (_) => setState(() => _dirty = true),
                            decoration: InputDecoration(
                              hintText: '50',
                              prefixIcon: Icon(Icons.share_outlined, size: 18, color: AppColors.textLight),
                              filled: true,
                              fillColor: AppColors.scaffoldBg,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: AppBorderRadius.r8, borderSide: BorderSide(color: AppColors.border)),
                              enabledBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r8, borderSide: BorderSide(color: AppColors.border)),
                              focusedBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r8, borderSide: BorderSide(color: AppColors.primaryMid, width: 2)),
                            ),
                          ),

                          SizedBox(height: 12.h),

                          // Referral reward (new user gets this)
                          Text(
                            l10n.settingsReferralRewardNew,
                            style: GoogleFonts.nunito(
                              fontSize: Responsive.sp(context, 13),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textLight,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          TextField(
                            controller: _refRewardCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: GoogleFonts.nunito(
                              fontSize: Responsive.sp(context, 15),
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                            onChanged: (_) => setState(() => _dirty = true),
                            decoration: InputDecoration(
                              hintText: '50',
                              prefixIcon: Icon(Icons.person_add_outlined, size: 18, color: AppColors.textLight),
                              filled: true,
                              fillColor: AppColors.scaffoldBg,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: AppBorderRadius.r8, borderSide: BorderSide(color: AppColors.border)),
                              enabledBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r8, borderSide: BorderSide(color: AppColors.border)),
                              focusedBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r8, borderSide: BorderSide(color: AppColors.primaryMid, width: 2)),
                            ),
                          ),

                          SizedBox(height: 20.h),

                          // ── WhatsApp contact number ──────────────────────
                          Row(
                            children: [
                              Container(
                                width: 28.r, height: 28.r,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: AppBorderRadius.r8,
                                ),
                                child: const Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 16),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'WhatsApp Number',
                                style: GoogleFonts.nunito(
                                  fontSize: Responsive.sp(context, 14),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Include country code without + (e.g. 201001234567). Leave empty to hide the button.',
                            style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 11), color: AppColors.textLight),
                          ),
                          SizedBox(height: 6.h),
                          TextField(
                            controller: _whatsappCtrl,
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.nunito(
                              fontSize: Responsive.sp(context, 15),
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                            onChanged: (_) => setState(() => _dirty = true),
                            decoration: InputDecoration(
                              hintText: '201001234567',
                              prefixIcon: Icon(Icons.chat_rounded, size: 18, color: const Color(0xFF25D366)),
                              filled: true,
                              fillColor: AppColors.scaffoldBg,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: AppBorderRadius.r8, borderSide: BorderSide(color: AppColors.border)),
                              enabledBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r8, borderSide: BorderSide(color: AppColors.border)),
                              focusedBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r8, borderSide: const BorderSide(color: Color(0xFF25D366), width: 2)),
                            ),
                          ),

                          SizedBox(height: 20.h),

                          // ── Late-flag thresholds ─────────────────────────
                          Row(
                            children: [
                              Container(
                                width: 28.r, height: 28.r,
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: AppBorderRadius.r8,
                                ),
                                child: Icon(Icons.timer_outlined, color: Colors.orange.shade700, size: 16),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Late-Flag Thresholds (minutes)',
                                style: GoogleFonts.nunito(
                                  fontSize: Responsive.sp(context, 14),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Orders exceeding these limits are flagged as late on the board.',
                            style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 11), color: AppColors.textLight),
                          ),
                          SizedBox(height: 10.h),
                          _LateThresholdField(label: 'Pending → Confirmed', ctrl: _latePendingCtrl, onChanged: () => setState(() => _dirty = true)),
                          SizedBox(height: 8.h),
                          _LateThresholdField(label: 'Confirmed → Preparing', ctrl: _lateConfirmedCtrl, onChanged: () => setState(() => _dirty = true)),
                          SizedBox(height: 8.h),
                          _LateThresholdField(label: 'Preparing → Prepared', ctrl: _latePreparingCtrl, onChanged: () => setState(() => _dirty = true)),
                          SizedBox(height: 8.h),
                          _LateThresholdField(label: 'Prepared → Out for Delivery', ctrl: _latePreparedCtrl, onChanged: () => setState(() => _dirty = true)),
                          SizedBox(height: 8.h),
                          _LateThresholdField(label: 'Out for Delivery → Done', ctrl: _lateOutDeliveryCtrl, onChanged: () => setState(() => _dirty = true)),

                          SizedBox(height: 16.h),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (isLoading || isSaving || !_dirty) ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryDeep,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: AppBorderRadius.r8),
                                padding: EdgeInsets.symmetric(vertical: 13.h),
                                elevation: 0,
                              ),
                              child: isSaving
                                  ? SizedBox(
                                      width: 18.r,
                                      height: 18.r,
                                      child: const CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(
                                      l10n.settingsSaveChanges,
                                      style: GoogleFonts.nunito(
                                        fontSize: Responsive.sp(context, 14),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: 24.h),

                // Language selector
                BlocBuilder<LocaleCubit, Locale>(
                  builder: (context, locale) {
                    final isArabic = locale.languageCode == 'ar';
                    return Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: AppBorderRadius.r12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36.r,
                                height: 36.r,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: AppBorderRadius.r8,
                                ),
                                child: const Icon(
                                  Icons.language_rounded,
                                  color: Color(0xFF2E7D32),
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                l10n.settingsLanguage,
                                style: GoogleFonts.nunito(
                                  fontSize: Responsive.sp(context, 16),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Expanded(
                                child: _LangOption(
                                  label: l10n.settingsLanguageEnglish,
                                  selected: !isArabic,
                                  onTap: () => context.read<LocaleCubit>().setLocale(const Locale('en')),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: _LangOption(
                                  label: l10n.settingsLanguageArabic,
                                  selected: isArabic,
                                  onTap: () => context.read<LocaleCubit>().setLocale(const Locale('ar')),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: 24.h),

                // Sign out
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await context.read<AuthCubit>().signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          LoginScreen.routeName,
                          (route) => false,
                        );
                      }
                    },
                    icon: Icon(Icons.logout_rounded, color: AppColors.error, size: 20.r),
                    label: Text(
                      l10n.settingsSignOut,
                      style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 15),
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r12),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LateThresholdField extends StatelessWidget {
  const _LateThresholdField({
    required this.label,
    required this.ctrl,
    required this.onChanged,
  });
  final String label;
  final TextEditingController ctrl;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 12),
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
            ),
          ),
        ),
        SizedBox(
          width: 80.w,
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 14),
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              suffixText: 'min',
              suffixStyle: GoogleFonts.nunito(fontSize: 11, color: AppColors.textLight),
              filled: true,
              fillColor: AppColors.scaffoldBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(borderRadius: AppBorderRadius.r8, borderSide: BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r8, borderSide: BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r8, borderSide: BorderSide(color: Colors.orange, width: 2)),
            ),
          ),
        ),
      ],
    );
  }
}

class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDeep : AppColors.scaffoldBg,
          borderRadius: AppBorderRadius.r8,
          border: Border.all(
            color: selected ? AppColors.primaryDeep : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 14),
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
