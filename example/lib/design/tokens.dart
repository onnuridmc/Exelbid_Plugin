import 'package:flutter/material.dart';

class Spacing {
  Spacing._();
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 20;
  static const double xxl = 28;
}

class CornerRadii {
  CornerRadii._();
  static const double card = 14;
  static const double button = 12;
  static const double log = 8;
}

class BrandColors {
  BrandColors._();
  static const Color accent = Color(0xFF0A84FF);
}

class AppInsets {
  AppInsets._();
  static const EdgeInsets card =
      EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  static const EdgeInsets screen =
      EdgeInsets.fromLTRB(16, 0, 16, 32);
}
