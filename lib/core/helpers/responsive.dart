import 'package:flutter/material.dart';

class Responsive {
  static const double _mobileBreak = 700;
  static const double _tabletBreak = 1100;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < _mobileBreak;

  static bool isWeb(BuildContext context) =>
      MediaQuery.of(context).size.width >= _mobileBreak;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= _tabletBreak;

  static double maxContentWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= _tabletBreak) return 1100;
    return double.infinity;
  }

  static int gridCrossAxisCount(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1400) return 5;
    if (w >= 1100) return 4;
    if (w >= 750)  return 3;
    return 2;
  }

  static int listGridCrossAxisCount(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1100) return 3;
    if (w >= 700)  return 2;
    return 1;
  }

  static double sidePadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= _tabletBreak) return 24.0;
    if (w >= _mobileBreak) return 20.0;
    return 16.0;
  }

  /// Responsive font size that stays stable across all screen sizes.
  /// On web/tablet (>= 700px) returns [base] exactly.
  /// On small phones scales down slightly but never below 85% of [base].
  static double sp(BuildContext context, double base) {
    final w = MediaQuery.of(context).size.width;
    if (w >= _mobileBreak) return base;
    return base * (w / 390.0).clamp(0.85, 1.0);
  }

  /// Responsive size for icons and square containers.
  /// Mirrors [sp] clamping behaviour.
  static double r(BuildContext context, double base) {
    final w = MediaQuery.of(context).size.width;
    if (w >= _mobileBreak) return base;
    return base * (w / 390.0).clamp(0.85, 1.0);
  }
}
