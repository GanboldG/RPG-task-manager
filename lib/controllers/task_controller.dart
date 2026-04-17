import 'package:flutter/material.dart';
import 'package:rpg_task_manager/controllers/user_controller.dart';
import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/models/difficulty.dart';
import 'package:rpg_task_manager/models/task.dart';
import 'package:rpg_task_manager/services/reward_service.dart';
import 'package:rpg_task_manager/services/task_id_counter.dart';
import 'package:rpg_task_manager/services/task_service.dart';
import 'package:rpg_task_manager/services/timer/task_timer_service.dart';
import 'package:rpg_task_manager/services/user_service.dart';

class TaskController extends ChangeNotifier {
  final TimerService _timerService = TimerService();
  TimerService get timerService => _timerService;
  final TaskService _taskSerivce = TaskService();
  TaskService get taskService => _taskSerivce;
  late UserController _userController;
  late List<Task> _tasks;
  List<Task> get tasks => _tasks;

  TaskController(UserController userController) {
    _userController = userController;
    
    // Gets all task info from hive box (storage)
    _tasks = taskService.getAllActiveTasks();

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
      orderId: 0,  // Adding a task always puts at index 1
      name: name,
      difficulty: difficulty,
      baseDurationSec: HelperFunctions.minToSec(baseMinutes),
      doneDurationSec: 0,
      deadline: deadline,
      description: description,
      createdAt: DateTime.now(),
      reward: RewardService.calculateTaskReward(difficulty, HelperFunctions.minToSec(baseMinutes), UserService().currentUser.level),
    );

    _tasks.insert(0, newTask);
    taskService.addTask(newTask);

    notifyListeners();
  }

  // --------------------FINISH----------------------
  String finishTask(int id) {
    Task? matchedTask = _findTaskByID(id);

    if (matchedTask != null) {
      if (_timerService.activeTask?.id == id) {
        _timerService.stopTimer();
      }
      
      _userController.addReward(matchedTask.reward);
      _tasks.remove(matchedTask);
      // Add a method in service, that archives the task in finished_task box
      // Add a method in service, that archives the task in finished_task box
      // Instead of this::::::::
      taskService.deleteTask(matchedTask.id);
      // Add a method in service, that archives the task in finished_task box

      notifyListeners();
      return matchedTask.name;
    }

    return "Something went wrong";
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
  }) async {
    final task = _tasks.firstWhere((k) => k.id == id);
    task.name = name;
    task.difficulty = difficulty;
    task.baseDurationSec = (baseMinutes * 60).round();
    task.deadline = deadline;
    task.description = description;
    task.reward = RewardService.calculateTaskReward(difficulty, task.getRemainingSeconds(), UserService().currentUser.level);

    await taskService.updateTask(task);
    notifyListeners();
  }

  // Called whenever "Pause" button's pressed, causing updated duration to be saved in Hive
  void updateHiveTaskDoneDuration({
    required int taskId,
  }) async {
    final task = _findTaskByID(taskId);

    if (task != null){
      await taskService.updateTask(task);
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

  // Needed for storing the task order in files
  void updateTaskOrderId() async {
    for (int i = 0; i < tasks.length; i++){
      tasks[i].orderId = i;
      await taskService.updateTask(tasks[i]);
    }
  }
}