import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../helpers/responsive.dart';
import 'colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle heading1(BuildContext context) => GoogleFonts.nunito(
        fontSize: Responsive.sp(context, 24),
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      );

  static TextStyle heading2(BuildContext context) => GoogleFonts.nunito(
        fontSize: Responsive.sp(context, 20),
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      );

  static TextStyle heading3(BuildContext context) => GoogleFonts.nunito(
        fontSize: Responsive.sp(context, 18),
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      );

  static TextStyle subtitle(BuildContext context) => GoogleFonts.nunito(
        fontSize: Responsive.sp(context, 16),
        fontWeight: FontWeight.w600,
        color: AppColors.textCharcoal,
      );

  static TextStyle body(BuildContext context) => GoogleFonts.nunito(
        fontSize: Responsive.sp(context, 14),
        fontWeight: FontWeight.w400,
        color: AppColors.textCharcoal,
      );

  static TextStyle bodySmall(BuildContext context) => GoogleFonts.nunito(
        fontSize: Responsive.sp(context, 12),
        fontWeight: FontWeight.w400,
        color: AppColors.textMid,
      );

  static TextStyle label(BuildContext context) => GoogleFonts.nunito(
        fontSize: Responsive.sp(context, 14),
        fontWeight: FontWeight.w500,
        color: AppColors.textMid,
      );

  static TextStyle button(BuildContext context) => GoogleFonts.nunito(
        fontSize: Responsive.sp(context, 16),
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  static TextStyle headingAr(BuildContext context) => GoogleFonts.cairo(
        fontSize: Responsive.sp(context, 24),
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      );

  static TextStyle bodyAr(BuildContext context) => GoogleFonts.cairo(
        fontSize: Responsive.sp(context, 14),
        fontWeight: FontWeight.w400,
        color: AppColors.textCharcoal,
      );
}
