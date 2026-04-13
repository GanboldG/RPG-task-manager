import 'package:rpg_task_manager/models/task.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TaskService {
  final Box<Task> activeBox = Hive.box<Task>('active_tasks');
  final Box<Task> completedBox = Hive.box<Task>('completed_tasks');
  
  // ----------------ADD--------------------
  Future<int> addTask(Task task) async {
    // int newId = await TaskIdCounter.getNextId();
    // Add to box (key = task.id, value = task)
    await activeBox.put(task.id, task);
    return task.id;
  }

  // ----------------GET--------------------
  List<Task> getAllActiveTasks() {
    final tasks = activeBox.values.toList();
    tasks.sort((a, b) => a.orderId.compareTo(b.orderId));
    return tasks;  // Returns all values sorted
  }

  Task? getTaskById(int id) {
    return activeBox.get(id);  // O(1) lookup
  }

  Map<dynamic, Task> getTasksMap() {
    return activeBox.toMap();  // {0: Task, 1: Task, ...}
  }

  // ----------------UPDATE--------------------
  Future<void> completeTask(int taskId) async {
    
    // Get existing task
    Task? task = activeBox.get(taskId);
    
    if (task != null) {
      // Update fields
      task.isCompleted = true;
      task.completedAt = DateTime.now();
      
      // Move to completed box
      await completedBox.put(taskId, task);
      await activeBox.delete(taskId);
    }
  }

  Future<void> updateTask(Task updatedTask) async {
    activeBox.put(updatedTask.id, updatedTask);
  }

  // ----------------DELETE---------------------
  Future<void> deleteTask(int taskId, {bool permanent = false}) async {
    if (permanent) {
      // Delete from wherever it is
      await activeBox.delete(taskId);
      await completedBox.delete(taskId);
    } else {
      // Soft delete - just remove from active
      await activeBox.delete(taskId);
    }
  }

  // Delete all completed tasks
  Future<void> clearCompletedTasks() async {
    await completedBox.clear();
  }

  Future<void> resetAllHiveData() async {
    // Delete all boxes
    await Hive.deleteBoxFromDisk('active_tasks');
    await Hive.deleteBoxFromDisk('completed_tasks');
    
    // Or delete everything (all boxes)
    await Hive.deleteFromDisk();
  }

  // ----------------MIGRATION---------------------
  // Adds default values of new variables in old elements
  // Future<void> migrateTasks() async {

  //   // Migrate active tasks
  //   for (var key in activeBox.keys) {
  //     final task = activeBox.get(key);
  //     if (task != null) {
  //       // Check if orderId is null (old task)
  //       if (task.orderId == null) {
  //         task.orderId = 0;  // Set default value
  //         await activeBox.put(key, task);
  //       }
  //     }
  //   }
    
  //   // Migrate completed tasks
  //   for (var key in completedBox.keys) {
  //     final task = completedBox.get(key);
  //     if (task != null && task.orderId == null) {
  //       task.orderId = 0;
  //       await completedBox.put(key, task);
  //     }
  //   }
  // }
}