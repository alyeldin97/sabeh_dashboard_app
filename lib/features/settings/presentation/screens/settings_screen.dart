import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state.user;
          return ListView(
            padding: EdgeInsets.all(16.r),
            children: [
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
              SizedBox(height: 20.h),
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
    );
  }
}
