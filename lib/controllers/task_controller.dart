import 'package:flutter/material.dart';
import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/models/difficulty.dart';
import 'package:rpg_task_manager/models/reward.dart';
import 'package:rpg_task_manager/models/task.dart';
import 'package:rpg_task_manager/services/timer_service.dart';

class TaskController extends ChangeNotifier {
  final TimerService _timerService = TimerService();
  TimerService get timerService => _timerService;

  final List<Task> _tasks = [
    Task(
      id: 0, 
      name: "Learn",
      difficulty: Difficulty.easy,
      baseDurationSec: 180,
      doneDurationSec: 0,
      deadline: DateTime.now(),
      createdAt: DateTime.now(),
      reward: Reward(xp: 0, gold: 0, crystal: 0),
    ),
    Task(
      id: 1, 
      name: "Die",
      difficulty: Difficulty.medium,
      baseDurationSec: 180,
      doneDurationSec: 0,
      createdAt: DateTime.now(),
      reward: Reward(xp: 0, gold: 0, crystal: 0),
    ),
    Task(
      id: 2, 
      name: "Repeat",
      difficulty: Difficulty.hard,
      baseDurationSec: 180,
      doneDurationSec: 0,
      createdAt: DateTime.now(),
      reward: Reward(xp: 0, gold: 0, crystal: 0),
    ),
  ];
  
  List<Task> get tasks => _tasks;

  // Constructor that connects TimerService to TaskController
  TaskController() {
    // This callback is called every second by the timer
    _timerService.onProgressUpdate = (taskId, doneSeconds) {
      updateTaskProgress(taskId, doneSeconds);
    };
  }

  void addTask({
    String name = "", 
    Difficulty difficulty = Difficulty.easy, 
    double baseMinutes = 0,
    DateTime? deadline,
    String description = "",
  }) {
    final newTask = Task(
      id: _getNextId(),
      name: name,
      difficulty: difficulty,
      baseDurationSec: HelperFunctions.minToSec(baseMinutes),
      doneDurationSec: 0,
      deadline: deadline,
      description: description,
      createdAt: DateTime.now(),
      reward: Reward(xp: 0, gold: 0, crystal: 0),
    );
    
    _tasks.add(newTask);
    notifyListeners();
  }

  String deleteTask(int id) {
    Task? matchedTask = _findTaskByID(id);

    if (matchedTask != null) {
      if (_timerService.activeTask?.id == id) {
        _timerService.stopTimer();
      }
      
      _tasks.remove(matchedTask);
      notifyListeners();
      return matchedTask.name;
    }

    return "Something went wrong";
  }

  void updateTask({    
    required int id,
    String name = "", 
    Difficulty difficulty = Difficulty.easy, 
    double baseMinutes = 0,
    DateTime? deadline,
    String description = "",
  }){
    final task = _tasks.firstWhere((k) => k.id == id);
    task.name = name;
    task.difficulty = difficulty;
    task.baseDurationSec = (baseMinutes * 60).round();
    task.deadline = deadline;
    task.description = description;

    notifyListeners();
  }

  // This gets called every second by the timer
  void updateTaskProgress(int taskId, int doneSeconds) {
    final task = _findTaskByID(taskId);
    if (task != null) {
      task.doneDurationSec = doneSeconds;
      notifyListeners(); // ← This rebuilds the UI
    }
  }

  int _getNextId() {
    if (_tasks.isEmpty) return 0;
    return _tasks.map((t) => t.id).reduce((max, id) => id > max ? id : max) + 1;
  }

  Task? _findTaskByID(int id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }
  
  void reorderTasks(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, item);
    notifyListeners();
  }
}