import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get headingLarge => GoogleFonts.bebasNeue(
    fontSize: 48,
    color: AppColors.textPrimary,
    letterSpacing: 1.2,
  );

  static TextStyle get headingMedium => GoogleFonts.bebasNeue(
    fontSize: 32,
    color: AppColors.textPrimary,
    letterSpacing: 1.0,
  );

  static TextStyle get headingSmall => GoogleFonts.bebasNeue(
    fontSize: 24,
    color: AppColors.textPrimary,
    letterSpacing: 0.8,
  );

  static TextStyle get bodyLarge => GoogleFonts.dmSans(
    fontSize: 16,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get bodyMedium => GoogleFonts.dmSans(
    fontSize: 14,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get bodySmall => GoogleFonts.dmSans(
    fontSize: 12,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get button => GoogleFonts.dmSans(
    fontSize: 16,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );
}
