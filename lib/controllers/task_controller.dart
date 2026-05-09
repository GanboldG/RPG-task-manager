import 'package:flutter/material.dart';
import 'package:rpg_task_manager/controllers/user_controller.dart';
import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/models/difficulty.dart';
import 'package:rpg_task_manager/models/task/task.dart';
import 'package:rpg_task_manager/models/task/task_type.dart';
import 'package:rpg_task_manager/services/reward_service.dart';
import 'package:rpg_task_manager/services/task_service.dart';
import 'package:rpg_task_manager/services/timer/task_timer_service.dart';
import 'package:rpg_task_manager/services/user_service.dart';

class TaskController extends ChangeNotifier {
  final TimerService _timerService = TimerService();
  TimerService get timerService => _timerService;

  TaskService get taskService => TaskService();

  late UserController _userController;
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  List<Task> _archivedTasks = [];
  List<Task> get archivedTasks => _archivedTasks;

  TaskController(UserController userController){
    _userController = userController; 
  }

  // Calls after login happens
  void initialize(){
    // Gets all task info from hive box (storage)
    _tasks = taskService.getAllActiveTasks();
    _archivedTasks = taskService.getAllArchivedTasks();

    // Connects TimerService to TaskController
    // This callback is called every second by the timer
    _timerService.onProgressUpdate = (taskId, doneSeconds) {
      updateTaskProgress(taskId, doneSeconds);
    };
  }


  // Populating from firebase
  void populateTasks(List<Task> tasks){
    _tasks.addAll(tasks);
    TaskService().saveTasksLocally(tasks);
    print("ADDED ALL TASK FROM FIREBASE TO MEMORY");
  }


  // --------------------ADD----------------------
  void addTask({  // Returns future, so the caller is aware it's async
    String name = "", 
    Difficulty difficulty = Difficulty.easy, 
    double baseMinutes = 0,
    DateTime? deadline,
    String description = "",
    TaskType type = TaskType.career,
  }) {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      orderId: 0,  // Adding a task always puts at index 1 (on top)
      name: name,
      difficulty: difficulty,
      baseDurationSec: HelperFunctions.minToSec(baseMinutes),
      doneDurationSec: 0,
      deadline: deadline,
      description: description,
      createdAt: DateTime.now(),
      completedAt: null,
      reward: RewardService.calculateTaskReward(difficulty, HelperFunctions.minToSec(baseMinutes), UserService().currentUser.level),
      type: type,
    );

    _tasks.insert(0, newTask);
    taskService.addTask(newTask);

    notifyListeners();
  }

  // --------------------FINISH----------------------
  String finishTask(String id) {
    Task? matchedTask = _findTaskByID(id);

    if (matchedTask != null) {
      if (_timerService.activeTask?.id == id) {
        _timerService.stopTimer();
      }
      
      matchedTask.isCompleted = true;
      matchedTask.completedAt = DateTime.now();

      _userController.addReward(matchedTask.reward);
      taskService.completeTask(matchedTask.id);

      _archivedTasks.add(matchedTask);
      _tasks.remove(matchedTask);

      notifyListeners();
      return matchedTask.name;
    }

    return "Something went wrong";
  }

  // --------------------ABANDON----------------------
  String abandonTask(String id){
    // Remove the rewards as abandon penalty
    Task? matchedTask = _findTaskByID(id);

    if (matchedTask != null){
      _userController.reduceReward(matchedTask.reward);
    }

    return deleteTask(id);
  }


  // --------------------DELETE----------------------
  String deleteTask(String id) {
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
    required String id,
    String name = "", 
    Difficulty difficulty = Difficulty.easy, 
    double baseMinutes = 0,
    DateTime? deadline,
    String description = "",
    TaskType type = TaskType.career
  }) async {
    final task = _tasks.firstWhere((k) => k.id == id);
    task.name = name;
    task.difficulty = difficulty;
    task.baseDurationSec = (baseMinutes * 60).round();
    task.deadline = deadline;
    task.description = description;
    task.reward = RewardService.calculateTaskReward(difficulty, task.getRemainingSeconds(), UserService().currentUser.level);
    task.type = type;

    await taskService.updateTask(task);
    notifyListeners();
  }

  // Called whenever "Pause" button's pressed, causing updated duration to be saved in Hive
  void updateHiveTaskDoneDuration({
    required String taskId,
  }) async {
    final task = _findTaskByID(taskId);

    if (task != null){
      await taskService.updateTask(task);
    }
  }

  // This gets called every second by the timer
  void updateTaskProgress(String taskId, int doneSeconds) {
    final task = _findTaskByID(taskId);
    if (task != null) {
      task.doneDurationSec = doneSeconds;
      notifyListeners();
    }
  }


  Task? _findTaskByID(String id) {
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


  List<Task> getLastNArchivedTasks(int amount){
    final tasks = _archivedTasks.reversed.toList();

    return tasks.take(amount).toList();
  }
}