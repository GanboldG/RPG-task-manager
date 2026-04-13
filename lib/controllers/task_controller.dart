import 'package:flutter/material.dart';
import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/models/difficulty.dart';
import 'package:rpg_task_manager/models/reward.dart';
import 'package:rpg_task_manager/models/task.dart';
import 'package:rpg_task_manager/services/task_id_counter.dart';
import 'package:rpg_task_manager/services/task_service.dart';
import 'package:rpg_task_manager/services/timer_service.dart';

class TaskController extends ChangeNotifier {
  final TimerService _timerService = TimerService();
  TimerService get timerService => _timerService;
  final TaskService _taskSerivce = TaskService();
  TaskService get taskService => _taskSerivce;
  late List<Task> _tasks;
  List<Task> get tasks => _tasks;

  TaskController() {
    // Gets all task info from hive box (storage)
    debugPrint(_tasks.map((o) => o.name).toString());

    // Connects TimerService to TaskController
    // This callback is called every second by the timer
    _timerService.onProgressUpdate = (taskId, doneSeconds) {
      updateTaskProgress(taskId, doneSeconds);
    };
  }

  // --------------------ADD----------------------
  Future<void> addTask({  // Returns future, so the caller is aware it's async
    String name = "", 
    Difficulty difficulty = Difficulty.easy, 
    double baseMinutes = 0,
    DateTime? deadline,
    String description = "",
  }) async {
    final newTask = Task(
      id: await TaskIdCounter.getNextId(),
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
    taskService.addTask(newTask);

    notifyListeners();
  }

  // --------------------DELETE----------------------
  String deleteTask(int id) {
    Task? matchedTask = _findTaskByID(id);

    if (matchedTask != null) {
      if (_timerService.activeTask?.id == id) {
        _timerService.stopTimer();
      }
      
      _tasks.remove(matchedTask);
      taskService.deleteTask(matchedTask.id);

      notifyListeners();
      return matchedTask.name;
    }

    return "Something went wrong";
  }

  // --------------------UPDATE----------------------
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

    taskService.updateTask(task);
    notifyListeners();
  }

  // Called whenever "Pause" button's pressed, causing updated duration to be saved in Hive
  void updateHiveTaskDoneDuration({
    required int taskId,
  }){
    final task = _findTaskByID(taskId);

    if (task != null){
      taskService.updateTask(task);
    }
  }

  // This gets called every second by the timer
  void updateTaskProgress(int taskId, int doneSeconds) {
    final task = _findTaskByID(taskId);
    if (task != null) {
      task.doneDurationSec = doneSeconds;
      notifyListeners();
    }
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