import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rpg_task_manager/models/task/task.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TaskService {

  TaskService._internal();
  static final TaskService _instance = TaskService._internal();
  factory TaskService() {
    return _instance;
  }

  final Box<Task> activeBox = Hive.box<Task>('active_tasks');
  final Box<Task> completedBox = Hive.box<Task>('completed_tasks');
  final Box<Task> abandonedBox = Hive.box<Task>('abandoned_tasks');
  

  // ----------------HIVE METHODS---------------------

  Future<void> saveTasksLocally(List<Task> tasks) async {
    for (Task task in tasks){
      activeBox.put(task.id, task);
    }
    print("(HIVE) Locally saved ${tasks.length} tasks");
  }

  Future<String> addTask(Task task) async {
    // int newId = await TaskIdCounter.getNextId();
    // Add to box (key = task.id, value = task)
    await activeBox.put(task.id, task);
    return task.id;
  }

  List<Task> getAllActiveTasks() {
    final tasks = activeBox.values.toList();
    tasks.sort((a, b) => (a.orderId ?? 0).compareTo(b.orderId ?? 0));
    return tasks;  // Returns all values sorted
  }

  Future<void> completeTask(String taskId) async {
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

  Future<void> deleteTask(String taskId, {bool permanent = true}) async {
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


  // ----------------FIRESTORE METHODS---------------------
  Future<List<Task>> getFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('tasks')
          .doc('data')
          .get();

      final data = snapshot.data();

      if (data == null) return [];

      final List<dynamic> rawTasks = data['tasks'];

      return rawTasks
          .map((taskMap) => Task.fromMap(taskMap))
          .toList();

    } catch (e) {
      print("Exception $e while getting tasks from firestore");
      return [];
    }
  }

  Future<void> uploadToFirestore() async {
    try {
      // TODO: Keep max amount of tasks within 100-150 (Tasks: 100 / Daily, weekly: 50)
      final tasks = getAllActiveTasks()
          .map((task) => task.toMap())
          .toList();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('tasks')
          .doc('data')
          .set({
            'tasks': tasks, 
          });

    } catch (e) {
      print("Exception $e while uploading tasks to firestore");
    }
  }
}