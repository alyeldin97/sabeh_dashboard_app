import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/helpers/responsive.dart';
import '../../core/styling/colors.dart';

class ProductsMgmtScreen extends StatelessWidget {
  const ProductsMgmtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDeep,
        title: Text(
          'Products',
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
            Icon(
              Icons.inventory_2_outlined,
              size: 64.r,
              color: AppColors.primaryLight,
            ),
            SizedBox(height: 16.h),
            Text(
              'Products Management',
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 20),
                fontWeight: FontWeight.w700,
                color: AppColors.textCharcoal,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Coming soon',
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 14),
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
