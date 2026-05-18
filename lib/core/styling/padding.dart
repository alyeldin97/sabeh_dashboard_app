import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppPadding {
  AppPadding._();

  static const EdgeInsets screenH   = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets screenHV  = EdgeInsets.symmetric(horizontal: 20, vertical: 24);
  static EdgeInsets get cardPadding => EdgeInsets.all(16.r);

  static double get h4  => 4.h;
  static double get h8  => 8.h;
  static double get h12 => 12.h;
  static double get h16 => 16.h;
  static double get h20 => 20.h;
  static double get h24 => 24.h;
  static double get h32 => 32.h;

  static const double w4  = 4;
  static const double w8  = 8;
  static const double w12 = 12;
  static const double w16 = 16;
}
