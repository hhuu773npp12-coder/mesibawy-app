import 'package:flutter/material.dart';

class Responsive {
  // Breakpoints
  static bool isSmall(BuildContext context) => MediaQuery.of(context).size.width < 360;
  static bool isMedium(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= 360 && w < 600;
  }
  static bool isLarge(BuildContext context) => MediaQuery.of(context).size.width >= 600;

  // Grid helpers
  static double gridMaxCrossAxisExtent(BuildContext context) {
    if (isSmall(context)) return 160;
    if (isMedium(context)) return 180;
    return 220;
  }

  static double gridChildAspectRatio(BuildContext context) {
    if (isSmall(context)) return 0.9;
    if (isMedium(context)) return 1.05;
    return 1.2;
  }

  // Icon and text sizing for cards
  static double cardIconSize(BuildContext context) {
    if (isSmall(context)) return 32;
    if (isMedium(context)) return 40;
    return 48;
  }

  static double cardFontSize(BuildContext context) {
    if (isSmall(context)) return 13;
    if (isMedium(context)) return 15;
    return 16;
  }

  // Map height suggestions based on height
  static double mapHeight(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    if (h < 640) return 200;
    if (h < 800) return 260;
    return 320;
  }
}
