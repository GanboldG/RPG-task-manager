// timer_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rpg_task_manager/models/task.dart';

class TimerService extends ChangeNotifier {
  Timer? _timer;
  Task? _activeTask;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  
  // This callback needs to be called!
  Function(int, int)? onProgressUpdate;
  
  Task? get activeTask => _activeTask;
  bool get isRunning => _isRunning;
  int get elapsedSeconds => _elapsedSeconds;
  
  void startTimer(Task task) {
    if (_timer != null) stopTimer();
    
    _activeTask = task;
    _isRunning = true;
    _elapsedSeconds = task.doneDurationSec;
    
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      
      // CRITICAL: Call this callback to update the task!
      if (onProgressUpdate != null) {
        onProgressUpdate!(_activeTask!.id, _elapsedSeconds);
      }
      
      notifyListeners();
    });
    
    notifyListeners();
  }
  
  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    notifyListeners();
  }
  
  void resetTimer() {
    stopTimer();
    _activeTask = null;
    _elapsedSeconds = 0;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}