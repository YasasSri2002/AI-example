import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Nestify typography system.
///
/// Uses **Inter** (sans-serif) for all body text and UI elements,
/// and **Playfair Display** (serif) for hero/display headings.
///
/// All styles reference [AppColors] for default text color.
class AppTextStyles {
  AppTextStyles._();

  // ──────────────────────────────────────────────
  // Display — Playfair Display (hero headings)
  // ──────────────────────────────────────────────

  /// Extra-large display heading — hero sections.
  static TextStyle displayXl = GoogleFonts.playfairDisplay(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.neutral800,
    height: 1.2,
  );

  /// Large display heading.
  static TextStyle displayLg = GoogleFonts.playfairDisplay(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: AppColors.neutral800,
    height: 1.2,
  );

  /// Medium display heading.
  static TextStyle displayMd = GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral800,
    height: 1.3,
  );

  // ──────────────────────────────────────────────
  // Headings — Inter
  // ──────────────────────────────────────────────

  /// Extra-large heading.
  static TextStyle headingXl = GoogleFonts.inter(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.neutral800,
    height: 1.3,
  );

  /// Large heading.
  static TextStyle headingLg = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral800,
    height: 1.3,
  );

  /// Medium heading.
  static TextStyle headingMd = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral800,
    height: 1.4,
  );

  /// Small heading.
  static TextStyle headingSm = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral800,
    height: 1.4,
  );

  // ──────────────────────────────────────────────
  // Body — Inter
  // ──────────────────────────────────────────────

  /// Large body text.
  static TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral600,
    height: 1.6,
  );

  /// Medium body text — default body.
  static TextStyle bodyMd = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral600,
    height: 1.6,
  );

  /// Small body text.
  static TextStyle bodySm = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral600,
    height: 1.5,
  );

  // ──────────────────────────────────────────────
  // Utility — Inter
  // ──────────────────────────────────────────────

  /// Caption text — small, muted.
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral400,
    height: 1.5,
  );

  /// Button text — medium weight, uppercase tracking.
  static TextStyle button = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.surfaceSnow,
    height: 1.0,
    letterSpacing: 0.5,
  );

  /// Label text — form labels, nav links.
  static TextStyle label = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.neutral600,
    height: 1.4,
  );

  /// Link text — accent colored.
  static TextStyle link = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.accent600,
    height: 1.4,
    decoration: TextDecoration.underline,
  );
}
