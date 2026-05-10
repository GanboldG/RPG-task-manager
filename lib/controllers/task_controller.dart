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

enum TaskSortOrder {
  manual,
  newest,
  oldest,
  closestDeadline,
  closestToCompletion,
}

class TaskController extends ChangeNotifier {
  final TimerService _timerService = TimerService();
  TimerService get timerService => _timerService;

  TaskService get taskService => TaskService();

  late UserController _userController;
  List<Task> _tasks = [];
  //  List<Task> get tasks => _tasks;

  List<Task> _archivedTasks = [];
  List<Task> get archivedTasks => _archivedTasks;

  // Task local storage save interval
  int timerCounter = 0;
  final taskLocalSaveInterval = 60;

  // Sort fields
  TaskSortOrder _sortOrder = TaskSortOrder.manual;
  TaskSortOrder get sortOrder => _sortOrder;

  List<Task> get tasks {
    final sorted = List<Task>.from(_tasks);
    switch (_sortOrder) {
      case TaskSortOrder.manual:
        sorted.sort((a, b) {
          if (a.orderId == null && b.orderId == null) return 0;
          if (a.orderId == null) return 1;
          if (b.orderId == null) return -1;
          return a.orderId!.compareTo(b.orderId!);
        });
      case TaskSortOrder.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case TaskSortOrder.oldest:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case TaskSortOrder.closestDeadline:
        sorted.sort((a, b) {
          if (a.deadline == null && b.deadline == null) return 0;
          if (a.deadline == null) return 1;
          if (b.deadline == null) return -1;
          return a.deadline!.compareTo(b.deadline!);
        });
      case TaskSortOrder.closestToCompletion:
        sorted.sort((a, b) => b.progress.compareTo(a.progress));
    }
    return sorted;
  }


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


  // --------------------SORT----------------------
  void setSortOrder(TaskSortOrder order) {
    _sortOrder = order;
    notifyListeners();
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
      _userController.updateCompletedTaskAmount(1);
      _userController.updateTaskCompletionStreak(1);

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
      _userController.resetTaskCompletionStreak();
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


  // Called whenever "Pause" button's pressed or every 60 seconds
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

      // Save every 60 seconds
      timerCounter++;
      if (timerCounter >= taskLocalSaveInterval){
        timerCounter = 0;
        updateHiveTaskDoneDuration(taskId: task.id);
        updateTaskSnapshots(task.id, taskLocalSaveInterval / 60);

        // Save user's task total time field
        _userController.updateTaskTotalSeconds(taskLocalSaveInterval);
      }
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
    
    // Sync _tasks to current sorted order first
    final currentSorted = tasks; // getter returns sorted copy
    _tasks = List.from(currentSorted);
    
    // Now do the swap on the synced list
    final item = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, item);
    
    notifyListeners();
  }

  // Needed for storing the task order in files
  void updateTaskOrderId() async {
    for (int i = 0; i < _tasks.length; i++){
      _tasks[i].orderId = i;
      await taskService.updateTask(_tasks[i]);
    }

    if (_sortOrder != TaskSortOrder.manual){
      _sortOrder = TaskSortOrder.manual;
    }
    // notifyListeners();
  }


  List<Task> getLastNArchivedTasks(int amount){
    final tasks = _archivedTasks.reversed.toList();

    return tasks.take(amount).toList();
  }


  // -------------------------TASK SNAPSHOTS---------------------------- 
  void updateTaskSnapshots(String taskId, double addingMinutes) async{
    await TaskService().updateTaskSnapshots(taskId, addingMinutes);
  }
}