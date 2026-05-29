import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/helpers/responsive.dart';
import '../../core/styling/colors.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDeep,
        title: Text(
          l10n.customersTitle,
          style: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 20),
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline_rounded, size: 64.r, color: AppColors.primaryLight),
            SizedBox(height: 16.h),
            Text(
              l10n.customersTitle,
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 20),
                fontWeight: FontWeight.w700,
                color: AppColors.textCharcoal,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.stubComingSoon,
              style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 14), color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }
}
