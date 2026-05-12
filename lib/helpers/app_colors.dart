import 'package:flutter/material.dart';

class AppColors {
  // ── Dynamic colors (updated when theme changes) ───────────────────────────
  static Color primary = const Color(0xFFE1B4FE);
  static Color primaryLight = const Color(0xFFF2DFFF);
  static Color textSecondary = const Color(0xFF4607AB);
  static Color textSecondaryLight = const Color(0xFF8146FF);
  static Color appBarSecondary = const Color(0xFFCCCCCC);
  static Color rewardBar = const Color(0xFFCE99F0);
  static Color background = const Color(0xFFFFFFFF);

  // ── Static colors (never change) ──────────────────────────────────────────
  static const secondary = Color(0xFF000000);
  static const surface = Color(0xFF000000);
  static const textPrimary = Color(0xFF000000);
  static const textPrimaryLight = Color(0xFF8D8D8D);

  // Resource icons
  static const level = Color(0xFFFFCE8F);
  static const experience = Color(0xFFA6F3FF);
  static const gold = Color(0xFFFFF09C);
  static const gemstone = Color(0xFF6DFDAC);

  // Difficulty colors
  static const taskEasy = Color(0xFFB7FFB3);
  static const taskMedium = Color(0xFFFFEDA3);
  static const taskHard = Color(0xFFFF8686);
  static const taskExpert = Color(0xFFFF4C4C);

  // Rarity colors
  static const rarityCommon = Color(0xFFB3B2B2);
  static const rarityUncommon = Color(0xFFB8D688);
  static const rarityRare = Color(0xFF50FFD6);
  static const rarityEpic = Color(0xFF8519E3);
  static const rarityLegendary = Color(0xFFFFA602);
  static const rarityMythic = Color(0xFF8F0000);

  // ── Called by ThemeNotifier when theme changes ────────────────────────────
  static void applyTheme({
    required Color newPrimary,
    required Color newPrimaryLight,
    required Color newAccent,
    required Color newAppBar,
    required Color newRewardBar,
    required Color newBackground,
  }) {
    primary = newPrimary;
    primaryLight = newPrimaryLight;
    textSecondary = newAccent;
    textSecondaryLight = newAccent.withOpacity(0.6);
    appBarSecondary = newAppBar;
    rewardBar = newRewardBar;
    background = newBackground;
  }
}
