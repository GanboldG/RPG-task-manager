// background_handler.dart - ЗАСАГДСАН ХУВИЛБАР

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_settings.dart';
import 'notification_settings_service.dart';

@pragma('vm:entry-point')
void startCallback() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  Timer? _timer;
  late SharedPreferences prefs;

  int _remainingSeconds = 0;
  bool _isPaused = false;
  bool _isExpired = false; // ← НЭМЛЭЭ: дахин дуусаагүй шалгах
  String _taskName = 'Task';

  NotificationSettings settings = NotificationSettings.defaults();

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    prefs = await SharedPreferences.getInstance();
    settings = await NotificationSettingsService.load();

    _remainingSeconds = prefs.getInt('bg_remaining_seconds') ?? 0;
    _taskName = prefs.getString('bg_task_name') ?? 'Task';
    _isPaused = prefs.getBool('bg_is_paused') ?? false;
    _isExpired = false;

    _startCounting();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  void _startCounting() {
    _timer?.cancel(); // ← аюулгүйн тулд урьдахыг цуцална
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        if (_isPaused || _isExpired) return; // ← НЭМЛЭЭ: expired бол skip

        if (_remainingSeconds > 0) {
          _remainingSeconds--;

          await prefs.setInt('bg_remaining_seconds', _remainingSeconds);

          // Секунд 5 болгонд notification update (battery хэмнэнэ)
          if (_remainingSeconds % 5 == 0 || _remainingSeconds <= 10) {
            _updateNotification();
          }
        } else {
          // ← ЗАСАГДСАН: зөвхөн НЭГ УДАА дуусна
          _isExpired = true;
          timer.cancel(); // ← ГАРЧИЛ БАЙСАН: timer зогсоно!

          await prefs.setBool('bg_time_expired', true);

          await FlutterForegroundTask.updateService(
            notificationTitle: '⏰ $_taskName',
            notificationText: 'Хугацаа дууслаа!',
          );
        }
      } catch (e) {
        debugPrint("Foreground timer error: $e");
      }
    });
  }

  void _updateNotification() {
    final mins = _remainingSeconds ~/ 60;
    final secs = _remainingSeconds % 60;
    final timeStr =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    FlutterForegroundTask.updateService(
      notificationTitle: settings.enableFocusMode
          ? '🔥 Focus Mode'
          : '🎯 $_taskName',
      notificationText: settings.showRemainingTime
          ? '⏳ $timeStr remaining'
          : 'Focus session active',
      notificationButtons: _buildButtons(),
    );
  }

  List<NotificationButton> _buildButtons() {
    final buttons = <NotificationButton>[];
    if (settings.allowPause) {
      buttons.add(
        NotificationButton(
          id: 'btn_pause',
          text: _isPaused ? '▶ Resume' : '⏸ Pause',
        ),
      );
    }
    if (settings.allowDone) {
      buttons.add(const NotificationButton(id: 'btn_done', text: '✅ Done'));
    }
    return buttons;
  }

  @override
  Future<void> onReceiveData(Object data) async {
    try {
      if (data == 'pause') {
        _isPaused = true;
        await prefs.setBool('bg_is_paused', true);
        await FlutterForegroundTask.updateService(
          notificationTitle: '⏸ $_taskName',
          notificationText: 'Түр зогссон',
          notificationButtons: _buildButtons(),
        );
      } else if (data == 'resume') {
        _isPaused = false;
        await prefs.setBool('bg_is_paused', false);
        _updateNotification();
      } else if (data == 'done') {
        _isExpired = true; // ← НЭМЛЭЭ: done хийхэд ч expired болгоно
        _timer?.cancel();
        await prefs.setBool('bg_task_completed', true);
        await prefs.setInt('bg_bonus_seconds', _remainingSeconds);
        await FlutterForegroundTask.stopService();
      }
    } catch (e) {
      debugPrint("onReceiveData error: $e");
    }
  }

  @override
  void onNotificationButtonPressed(String id) {
    if (id == 'btn_pause') {
      onReceiveData(_isPaused ? 'resume' : 'pause');
    } else if (id == 'btn_done') {
      onReceiveData('done');
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    _timer?.cancel();
  }
}
