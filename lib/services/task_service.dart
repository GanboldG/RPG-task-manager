import 'package:rpg_task_manager/models/task/task.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TaskService {
  final Box<Task> activeBox = Hive.box<Task>('active_tasks');
  final Box<Task> completedBox = Hive.box<Task>('completed_tasks');
  final Box<Task> abandonedBox = Hive.box<Task>('abandoned_tasks');
  
  // ----------------ADD--------------------
  Future<String> addTask(Task task) async {
    // int newId = await TaskIdCounter.getNextId();
    // Add to box (key = task.id, value = task)
    await activeBox.put(task.id, task);
    return task.id;
  }

  // ----------------GET--------------------
  List<Task> getAllActiveTasks() {
    final tasks = activeBox.values.toList();

    tasks.sort((a, b) => (a.orderId ?? 0).compareTo(b.orderId ?? 0));
    return tasks;  // Returns all values sorted
  }

  Task? getTaskById(int id) {
    return activeBox.get(id);  // O(1) lookup
  }

  Map<dynamic, Task> getTasksMap() {
    return activeBox.toMap();  // {0: Task, 1: Task, ...}
  }

  // ----------------UPDATE--------------------
  Future<void> completeTask(String taskId) async {
    
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
  Future<void> deleteTask(String taskId, {bool permanent = false}) async {
    if (permanent) {
      Task? task = activeBox.get(taskId);
      if (task != null){
        await abandonedBox.put(taskId, task);
      }
      else{
        task = completedBox.get(taskId);
        if (task != null){
          await abandonedBox.put(taskId, task);
        }
      }

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
    await Hive.deleteBoxFromDisk('abandoned_tasks');
    
    // Or delete everything (all boxes)
    await Hive.deleteFromDisk();
  }
}