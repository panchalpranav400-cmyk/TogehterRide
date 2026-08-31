import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Sahay Typographic Tokens (Hanken Grotesk & JetBrains Mono)
class AppTypography {
  static TextStyle headlineLarge = GoogleFonts.hankenGrotesk(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.onSurface,
  );

  static TextStyle headlineMedium = GoogleFonts.hankenGrotesk(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.onSurface,
  );

  static TextStyle headlineSmall = GoogleFonts.hankenGrotesk(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.onSurface,
  );

  static TextStyle bodyLarge = GoogleFonts.hankenGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.onSurface,
  );

  static TextStyle bodyMedium = GoogleFonts.hankenGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle labelMonoMedium = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.onSurface,
  );

  static TextStyle labelMonoSmall = GoogleFonts.jetBrainsMono(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: AppColors.outline,
  );
}
