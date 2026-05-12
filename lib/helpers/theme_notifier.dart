import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rpg_task_manager/helpers/app_colors.dart';

class AppThemeData {
  final String id;
  final String label;
  final Color primary;
  final Color primaryLight;
  final Color accent;
  final Color scaffoldBg;
  final Color appBar;
  final Color navBar;
  final Color navSelected;
  final Color navUnselected;
  final Color rewardBar;
  final Color background;

  const AppThemeData({
    required this.id,
    required this.label,
    required this.primary,
    required this.primaryLight,
    required this.accent,
    required this.scaffoldBg,
    required this.appBar,
    required this.navBar,
    required this.navSelected,
    required this.navUnselected,
    required this.rewardBar,
    required this.background,
  });

  ThemeData toThemeData() {
    final isDark = scaffoldBg.computeLuminance() < 0.2;
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: scaffoldBg,
      primaryColor: primary,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primary,
              secondary: accent,
              surface: scaffoldBg,
              onSurface: Colors.white,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
            )
          : ColorScheme.light(
              primary: primary,
              secondary: accent,
              onSurface: Colors.black87,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
            ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: navBar,
        selectedItemColor: navSelected,
        unselectedItemColor: navUnselected,
      ),
      appBarTheme: AppBarTheme(backgroundColor: appBar),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: Colors.white,
        headerBackgroundColor: accent,
        headerForegroundColor: Colors.white,
        dayBackgroundColor: WidgetStateProperty.all(Colors.white),
        dayOverlayColor: WidgetStateProperty.all(primary.withOpacity(0.1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: Colors.white,
        hourMinuteColor: primary.withOpacity(0.2),
        hourMinuteTextColor: Colors.black87,
        dialBackgroundColor: primary.withOpacity(0.1),
        dialHandColor: accent,
        dialTextColor: Colors.black87,
        entryModeIconColor: accent,
        hourMinuteShape: const CircleBorder(),
      ),
    );
  }
}

const List<AppThemeData> kAppThemes = [
  // Purple (default)
  AppThemeData(
    id: 'purple',
    label: 'Purple',
    primary: Color(0xFFE1B4FE),
    primaryLight: Color(0xFFF2DFFF),
    accent: Color(0xFF4607AB),
    scaffoldBg: Color(0xFFE0D0EB),
    appBar: Color(0xFFCCCCCC),
    navBar: Color(0xFFE1B4FE),
    navSelected: Colors.white,
    navUnselected: Color(0xFF555555),
    rewardBar: Color(0xFFCE99F0),
    background: Color(0xFFFFFFFF),
  ),
  // Ocean
  AppThemeData(
    id: 'ocean',
    label: 'Ocean',
    primary: Color(0xFF90CAF9),
    primaryLight: Color(0xFFBBDEFB),
    accent: Color(0xFF1565C0),
    scaffoldBg: Color(0xFFE3F2FD),
    appBar: Color(0xFFBBDEFB),
    navBar: Color(0xFF90CAF9),
    navSelected: Colors.white,
    navUnselected: Color(0xFF0D47A1),
    rewardBar: Color(0xFF90CAF9),
    background: Color(0xFFFFFFFF),
  ),
  // Light
  AppThemeData(
    id: 'light',
    label: 'Light',
    primary: Color(0xFFE0E0E0),
    primaryLight: Color(0xFFF5F5F5),
    accent: Color(0xFF1976D2),
    scaffoldBg: Color(0xFFF5F5F5),
    appBar: Color(0xFFEEEEEE),
    navBar: Color(0xFFE0E0E0),
    navSelected: Color(0xFF1976D2),
    navUnselected: Color(0xFF757575),
    rewardBar: Color(0xFFE8E8E8),
    background: Color(0xFFFFFFFF),
  ),
  // Red
  AppThemeData(
    id: 'red',
    label: 'Red',
    primary: Color(0xFFFFCDD2),
    primaryLight: Color(0xFFFFEBEE),
    accent: Color(0xFFC62828),
    scaffoldBg: Color(0xFFFFEBEE),
    appBar: Color(0xFFFFCDD2),
    navBar: Color(0xFFEF9A9A),
    navSelected: Colors.white,
    navUnselected: Color(0xFF7A0000),
    rewardBar: Color(0xFFEF9A9A),
    background: Color(0xFFFFFFFF),
  ),
];

class ThemeNotifier extends ChangeNotifier {
  static const _boxName = 'settings';
  static const _themeKey = 'theme_id';

  AppThemeData _current = kAppThemes[0];

  AppThemeData get current => _current;
  ThemeData get themeData => _current.toThemeData();
  List<AppThemeData> get themes => kAppThemes;

  ThemeNotifier() {
    _load();
  }

  void _load() {
    try {
      final box = Hive.box(_boxName);
      final savedId = box.get(_themeKey, defaultValue: 'purple') as String;
      _current = kAppThemes.firstWhere(
        (t) => t.id == savedId,
        orElse: () => kAppThemes[0],
      );
    } catch (_) {
      _current = kAppThemes[0];
    }
    _applyToAppColors();
  }

  Future<void> setTheme(AppThemeData theme) async {
    _current = theme;
    _applyToAppColors();
    notifyListeners();
    try {
      final box = Hive.box(_boxName);
      await box.put(_themeKey, theme.id);
    } catch (_) {}
  }

  void _applyToAppColors() {
    AppColors.applyTheme(
      newPrimary: _current.primary,
      newPrimaryLight: _current.primaryLight,
      newAccent: _current.accent,
      newAppBar: _current.appBar,
      newRewardBar: _current.rewardBar,
      newBackground: _current.background,
    );
  }
}
