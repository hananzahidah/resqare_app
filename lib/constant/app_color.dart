import 'package:flutter/material.dart';

/// =======================================================
/// AnimalResQ App Colors
/// =======================================================
///
/// Usage:
/// Container(color: AppColors.primaryBlue)
/// Text(style: TextStyle(color: AppColors.textPrimary))
///
/// =======================================================

class AppColors {
  AppColors._();

  // =======================================================
  // PRIMARY COLORS
  // =======================================================

  static const Color primaryBlue = Color(0xFF327AF4);
  static const Color softBlue = Color(0xFFDCEBFF);

  // =======================================================
  // BACKGROUND COLORS
  // =======================================================

  static const Color background = Color(0xFFFAF9FD);
  static const Color white = Color(0xFFFFFFFF);

  // =======================================================
  // TEXT COLORS
  // =======================================================

  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF6B7280);

  // =======================================================
  // STATUS COLORS
  // =======================================================

  static const Color waitingRescue = Color(0xFFF59E0B);
  static const Color onRescue = Color(0xFF3B82F6);
  static const Color rescued = Color(0xFF10B981);
  static const Color emergency = Color(0xFFEF4444);

  // =======================================================
  // BORDER & UI
  // =======================================================

  static const Color border = Color(0xFFEDEEF1);
  static const Color cardShadow = Color(0x14000000);
  static const Color divider = Color(0xFFEEEEEE);

  // =======================================================
  // OPTIONAL EXTRA COLORS
  // =======================================================

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFACC15);
  static const Color error = Color(0xFFDC2626);

  // =======================================================
  // GRADIENTS
  // =======================================================

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF327AF4), Color(0xFF5B9DFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
