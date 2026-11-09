import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xxxs = 2.0;
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;

  // EdgeInsets presets
  static const EdgeInsets zero = EdgeInsets.zero;
  static const EdgeInsets p4 = EdgeInsets.all(xxs);
  static const EdgeInsets p8 = EdgeInsets.all(xs);
  static const EdgeInsets p12 = EdgeInsets.all(sm);
  static const EdgeInsets p16 = EdgeInsets.all(md);
  static const EdgeInsets p20 = EdgeInsets.all(lg);
  static const EdgeInsets p24 = EdgeInsets.all(xl);

  // Horizontal Padding presets
  static const EdgeInsets h8 = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets h16 = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets h24 = EdgeInsets.symmetric(horizontal: xl);

  // Vertical Padding presets
  static const EdgeInsets v8 = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets v12 = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets v16 = EdgeInsets.symmetric(vertical: md);
}

abstract final class AppRadius {
  static const double r4 = 4.0;
  static const double r8 = 8.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r24 = 24.0;
  static const double round = 999.0;

  // BorderRadius presets
  static const BorderRadius sm = BorderRadius.all(Radius.circular(r4));
  static const BorderRadius md = BorderRadius.all(Radius.circular(r8));
  static const BorderRadius circular12 = BorderRadius.all(Radius.circular(r12));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(r16));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(r24));
  static const BorderRadius full = BorderRadius.all(Radius.circular(round));
}

abstract final class AppGaps {
  // Vertical Gaps
  static const SizedBox vGap4 = SizedBox(height: AppSpacing.xxs);
  static const SizedBox vGap8 = SizedBox(height: AppSpacing.xs);
  static const SizedBox vGap12 = SizedBox(height: AppSpacing.sm);
  static const SizedBox vGap16 = SizedBox(height: AppSpacing.md);
  static const SizedBox vGap20 = SizedBox(height: AppSpacing.lg);
  static const SizedBox vGap24 = SizedBox(height: AppSpacing.xl);
  static const SizedBox vGap32 = SizedBox(height: AppSpacing.xxl);

  // Horizontal Gaps
  static const SizedBox hGap4 = SizedBox(width: AppSpacing.xxs);
  static const SizedBox hGap8 = SizedBox(width: AppSpacing.xs);
  static const SizedBox hGap12 = SizedBox(width: AppSpacing.sm);
  static const SizedBox hGap16 = SizedBox(width: AppSpacing.md);
  static const SizedBox hGap20 = SizedBox(width: AppSpacing.lg);
  static const SizedBox hGap24 = SizedBox(width: AppSpacing.xl);
}
