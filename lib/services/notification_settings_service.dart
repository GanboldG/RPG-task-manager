import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_settings.dart';

class NotificationSettingsService {
  static const _soundKey = 'notif_sound';
  static const _vibrationKey = 'notif_vibration';
  static const _pauseKey = 'notif_pause';
  static const _doneKey = 'notif_done';
  static const _remainingKey = 'notif_remaining';
  static const _focusKey = 'notif_focus';

  static Future<NotificationSettings> load() async {
    final prefs = await SharedPreferences.getInstance();

    return NotificationSettings(
      enableSound: prefs.getBool(_soundKey) ?? true,
      enableVibration: prefs.getBool(_vibrationKey) ?? true,
      allowPause: prefs.getBool(_pauseKey) ?? true,
      allowDone: prefs.getBool(_doneKey) ?? true,
      showRemainingTime: prefs.getBool(_remainingKey) ?? true,
      enableFocusMode: prefs.getBool(_focusKey) ?? false,
    );
  }

  static Future<void> save(NotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_soundKey, settings.enableSound);
    await prefs.setBool(_vibrationKey, settings.enableVibration);
    await prefs.setBool(_pauseKey, settings.allowPause);
    await prefs.setBool(_doneKey, settings.allowDone);
    await prefs.setBool(_remainingKey, settings.showRemainingTime);
    await prefs.setBool(_focusKey, settings.enableFocusMode);
  }
}
