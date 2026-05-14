import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rpg_task_manager/services/background_handler.dart';

class TaskForegroundService {
  static void initialize() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'rpg_task_channel',
        channelName: 'RPG Task Timer',
        channelDescription: 'Task timer',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000),
        allowWakeLock: true,
      ),
    );
  }

  static Future<void> start({
    required String taskName,
    required int remainingSeconds,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bg_task_name', taskName);
      await prefs.setInt('bg_remaining_seconds', remainingSeconds);
      await prefs.setBool('bg_is_paused', false);
      await prefs.setBool('bg_task_completed', false);
      await prefs.setBool('bg_time_expired', false);

      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.restartService();
      } else {
        await FlutterForegroundTask.startService(
          serviceId: 300,
          notificationTitle: taskName,
          notificationText: 'Эхэлж байна...',
          notificationButtons: [
            const NotificationButton(id: 'btn_pause', text: '⏸ Зогсоох'),
            const NotificationButton(id: 'btn_done', text: '✅ Дуусгах'),
          ],
          callback: startCallback,
        );
      }
    } catch (e) {
      print('Service error: $e');
    }
  }

  static void sendPause() => FlutterForegroundTask.sendDataToTask('pause');
  static void sendResume() => FlutterForegroundTask.sendDataToTask('resume');
  static void sendDone() => FlutterForegroundTask.sendDataToTask('done');
  static Future<void> stop() async => await FlutterForegroundTask.stopService();
  static Future<bool> isRunning() async =>
      await FlutterForegroundTask.isRunningService;
}
