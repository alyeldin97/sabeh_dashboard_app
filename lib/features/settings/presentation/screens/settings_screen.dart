import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
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
  final _feeCtrl          = TextEditingController();
  final _maxPtsCtrl       = TextEditingController();
  final _refBonusCtrl     = TextEditingController();
  final _refRewardCtrl    = TextEditingController();
  bool _feeEnabled = false;
  bool _dirty = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = context.read<AppSettingsCubit>().state.settings;
    if (settings != null && !_dirty) {
      _feeCtrl.text       = settings.serviceFeeValue.toStringAsFixed(2);
      _feeEnabled         = settings.serviceFeeEnabled;
      _maxPtsCtrl.text    = settings.loyaltyMaxPointsPerOrder.toString();
      _refBonusCtrl.text  = settings.loyaltyReferralBonus.toString();
      _refRewardCtrl.text = settings.loyaltyReferralReward.toString();
    }
  }

  @override
  void dispose() {
    _feeCtrl.dispose();
    _maxPtsCtrl.dispose();
    _refBonusCtrl.dispose();
    _refRewardCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final value      = double.tryParse(_feeCtrl.text) ?? 0;
    final maxPts     = int.tryParse(_maxPtsCtrl.text) ?? 0;
    final refBonus   = int.tryParse(_refBonusCtrl.text) ?? 50;
    final refReward  = int.tryParse(_refRewardCtrl.text) ?? 50;
    context.read<AppSettingsCubit>().save(
          serviceFeeValue:          value,
          serviceFeeEnabled:        _feeEnabled,
          loyaltyMaxPointsPerOrder: maxPts,
          loyaltyReferralBonus:     refBonus,
          loyaltyReferralReward:    refReward,
        );
    setState(() => _dirty = false);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDeep,
        title: Text(
          'Settings',
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
            _feeCtrl.text       = state.settings!.serviceFeeValue.toStringAsFixed(2);
            _maxPtsCtrl.text    = state.settings!.loyaltyMaxPointsPerOrder.toString();
            _refBonusCtrl.text  = state.settings!.loyaltyReferralBonus.toString();
            _refRewardCtrl.text = state.settings!.loyaltyReferralReward.toString();
            setState(() => _feeEnabled = state.settings!.serviceFeeEnabled);
          }
          if (state.status == AppSettingsStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Failed to save'),
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
                              user?.name ?? 'Staff',
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
                                'Service Fee',
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
                                    'Show in checkout',
                                    style: GoogleFonts.nunito(
                                      fontSize: Responsive.sp(context, 14),
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  Text(
                                    'Appears as a line item on the order summary',
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
                            'Fee Amount (EGP)',
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
                            'Max Points Per Order (0 = unlimited)',
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

                          // Referral bonus (referrer gets this)
                          Text(
                            'Referral Bonus — Referrer (pts)',
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
                            'Referral Reward — New User (pts)',
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
                                      'Save Changes',
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
                      'Sign Out',
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
