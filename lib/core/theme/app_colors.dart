import 'package:flutter/material.dart';

/// Nestify design system color palette.
///
/// All colors are defined here to ensure consistency across the app.
/// Never use hardcoded Color values in widgets — always reference [AppColors].
class AppColors {
  AppColors._();

  // ──────────────────────────────────────────────
  // Primary — Deep Blue & Sapphire
  // ──────────────────────────────────────────────
  static const Color primary900 = Color(0xFF0A192F);
  static const Color primary800 = Color(0xFF112240);
  static const Color primary700 = Color(0xFF233554);
  static const Color primary600 = Color(0xFF495670);

  // ──────────────────────────────────────────────
  // Accent — Blue
  // ──────────────────────────────────────────────
  static const Color accent600 = Color(0xFF1D4ED8);
  static const Color accent500 = Color(0xFF2563EB);
  static const Color accent400 = Color(0xFF3B82F6);
  static const Color accent100 = Color(0xFFDBEAFE);

  // ──────────────────────────────────────────────
  // Surface — Snow & Ice (Aqua-tinged)
  // ──────────────────────────────────────────────
  static const Color surfaceSnow = Color(0xFFFFFFFF);
  static const Color surfaceIce100 = Color(0xFFF4F7F7);
  static const Color surfaceIce200 = Color(0xFFEAF2F1);
  static const Color surfaceAquaPale = Color(0xFFD1E3E2);
  static const Color surfaceAquaMuted = Color(0xFFB9D5D3);

  // ──────────────────────────────────────────────
  // Neutral
  // ──────────────────────────────────────────────
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral200 = Color(0xFFE2E8F0);

  // ──────────────────────────────────────────────
  // Semantic
  // ──────────────────────────────────────────────
  static const Color success = Color(0xFF059669);
  static const Color successBg = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFD97706);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorBg = Color(0xFFFEE2E2);
  static const Color rating = Color(0xFFF59E0B);

  // ──────────────────────────────────────────────
  // Background & Foreground
  // ──────────────────────────────────────────────
  static const Color background = Color(0xFFFAFBFC);
  static const Color foreground = Color(0xFF1E293B);

  // ──────────────────────────────────────────────
  // Gradient Definitions
  // ──────────────────────────────────────────────

  /// Hero section gradient: background → surfaceIce200
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFAFBFC), // background
      Color(0xFFEAF2F1), // surfaceIce200
    ],
  );

  /// Service gig detail gradient
  static const LinearGradient serviceDetailGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFD9EDEE),
      Color(0xFFE6F3F3),
      Color(0xFFEBF7F7),
    ],
  );

  /// Profile section gradient: snow → ice100 → ice200
  static const LinearGradient profileGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      surfaceSnow,
      surfaceIce100,
      surfaceIce200,
    ],
  );

  /// Card shadow color
  static const Color cardShadow = Color(0x1F0A192F); // rgba(10,25,47,0.12)
}
