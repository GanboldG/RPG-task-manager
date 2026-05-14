import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isPaused = false;
  String _taskName = 'Task';

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final prefs = await SharedPreferences.getInstance();
    _remainingSeconds = prefs.getInt('bg_remaining_seconds') ?? 0;
    _taskName = prefs.getString('bg_task_name') ?? 'Task';
    _isPaused = false;
    _startCounting();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  void _startCounting() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_isPaused) return;
      final prefs = await SharedPreferences.getInstance();
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        await prefs.setInt('bg_remaining_seconds', _remainingSeconds);
        final mins = _remainingSeconds ~/ 60;
        final secs = _remainingSeconds % 60;
        final timeStr =
            '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
        FlutterForegroundTask.updateService(
          notificationTitle: _taskName,
          notificationText: '▶  $timeStr үлдсэн',
        );
      } else {
        await prefs.setBool('bg_time_expired', true);
        FlutterForegroundTask.updateService(
          notificationTitle: _taskName,
          notificationText: '⏰ Хугацаа дууслаа!',
        );
      }
    });
  }

  @override
  Future<void> onReceiveData(Object data) async {
    final prefs = await SharedPreferences.getInstance();
    if (data == 'pause') {
      _isPaused = true;
      await prefs.setBool('bg_is_paused', true);
      FlutterForegroundTask.updateService(
        notificationTitle: _taskName,
        notificationText: '⏸  Түр зогссон',
        notificationButtons: [
          const NotificationButton(id: 'btn_pause', text: '▶ Эхлүүлэх'),
          const NotificationButton(id: 'btn_done', text: '✅ Дуусгах'),
        ],
      );
    } else if (data == 'resume') {
      _isPaused = false;
      await prefs.setBool('bg_is_paused', false);
      FlutterForegroundTask.updateService(
        notificationButtons: [
          const NotificationButton(id: 'btn_pause', text: '⏸ Зогсоох'),
          const NotificationButton(id: 'btn_done', text: '✅ Дуусгах'),
        ],
      );
    } else if (data == 'done') {
      await prefs.setBool('bg_task_completed', true);
      await prefs.setInt('bg_bonus_seconds', _remainingSeconds);
      await FlutterForegroundTask.stopService();
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
