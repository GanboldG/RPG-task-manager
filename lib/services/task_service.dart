import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/models/task/task.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rpg_task_manager/models/task/task_snapshot.dart';

class TaskService {

  TaskService._internal();
  static final TaskService _instance = TaskService._internal();
  factory TaskService() {
    return _instance;
  }

  Box<Task> get activeBox => Hive.box<Task>('active_tasks');
  Box<Task> get archivedBox  => Hive.box<Task>('archived_tasks');
  Box<TaskSnapshot> get taskSnapshotBox  => Hive.box<TaskSnapshot>('task_snapshots');

  // Defines how many objects should be fit in a single firestore doc
  static final int _batchSize = 1000;

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
      await archiveTask(task);
      await activeBox.delete(taskId);
    }
  }


  Future<void> updateTask(Task updatedTask) async {
    activeBox.put(updatedTask.id, updatedTask);
  }


  Future<void> deleteTask(String taskId, {bool permanent = true}) async {
    await activeBox.delete(taskId);
  }


  // Manages the archive box, where only last 100 tasks can exist at most
  Future<void> archiveTask(Task task) async {
    await archivedBox.put(task.id, task);
  }


  List<Task> getAllArchivedTasks() {
    return archivedBox.values.toList().reversed.toList();
  }

  // ----------------SNAPSHOT HIVE METHODS---------------------

  Future<void> updateTaskSnapshots(String taskId, double addingMinutes) async {
    String today = HelperFunctions.formatYearMonthDay(DateTime.now());
    
    // Get existing snapshot for today, or create empty one
    TaskSnapshot snapshot = taskSnapshotBox.get(today) ?? TaskSnapshot(
      day: today,
      taskMinutes: {},
    );

    // Add to existing value, or start from 0
    snapshot.taskMinutes[taskId] = (snapshot.taskMinutes[taskId] ?? 0) + addingMinutes;

    // Write back
    await taskSnapshotBox.put(today, snapshot);
  }


  // ----------------FIRESTORE METHODS---------------------
  Future<List<Task>> getActiveTasksFromFirestore() async {
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


  Future<void> uploadActiveTasksToFirestore() async {
    try {
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

  // ─────────────────────────────────────────
  // FIRESTORE ARCHIVED TASKS 
  // ─────────────────────────────────────────

  Future<void> uploadArchivedTasksToFirestore() async {
    try{
      // Delete every documents in firestore first
      await _clearFirestoreCollection("archived_tasks");

      final tasks = archivedBox.values.toList();

      for (int i = 0; i < tasks.length; i += _batchSize) {
        final chunk = tasks.skip(i).take(_batchSize).toList();
        final docName = 'tasks${i ~/ _batchSize + 1}';

        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('archived_tasks')
            .doc(docName)
            .set({'tasks': chunk.map((t) => t.toMap()).toList()});

        await Future.delayed(Duration.zero);
        print("Uploaded archived tasks batch: $docName");
      }
    }
    catch (e){
      print("Exception when trying to upload archived tasks to firestore: $e");
    }
  }


  Future<void> getArchivedTasksFromFirestore() async {
    try{
      await archivedBox.clear();

      final collection = await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('archived_tasks')
            .get();

      for (final doc in collection.docs) {
        final List tasks = doc.data()['tasks'] ?? [];

        for (final taskMap in tasks) {
          final task = Task.fromMap(Map<String, dynamic>.from(taskMap));
          await archivedBox.put(task.id, task);
        }

        await Future.delayed(Duration.zero);
        print("Downloaded archived tasks batch: ${doc.id}");
      }
    }
    catch (e){
      print("Exception when downloading archived tasks from firestore: $e");
    }
  }

  // ─────────────────────────────────────────
  // FIRESTORE TASK SNAPSHOTS
  // ─────────────────────────────────────────

  Future<void> uploadTaskSnapshotsToFirestore() async {
    try{
      // Delete every documents in firestore first
      await _clearFirestoreCollection("task_snapshots");

      final snapshots = taskSnapshotBox.values.toList();

      for (int i = 0; i < snapshots.length; i += _batchSize) {
        final chunk = snapshots.skip(i).take(_batchSize).toList();
        final docName = 'task_snapshots${i ~/ _batchSize + 1}';

        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('task_snapshots')
            .doc(docName)
            .set({'snapshots': chunk.map((s) => s.toMap()).toList()});

        await Future.delayed(Duration.zero);
        print("Uploaded task snapshots batch: $docName");
      }
    }
    catch (e){
      print("Exception when uploading task snapshots to firestore: $e");
    }
  }


  Future<void> getTaskSnapshotsFromFirestore() async {
    try{
      await taskSnapshotBox.clear();

      final collection = await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('task_snapshots')
            .get();

      for (final doc in collection.docs) {
        final List snapshots = doc.data()['snapshots'] ?? [];

        for (final snapshotMap in snapshots) {
          final snapshot = TaskSnapshot.fromMap(Map<String, dynamic>.from(snapshotMap));
          await taskSnapshotBox.put(snapshot.day, snapshot);
        }

        await Future.delayed(Duration.zero);
        print("Downloaded task snapshots batch: ${doc.id}");
      }
    }
    catch (e){
      print("Exception when downloading task snapshots from firestore: $e");
    }
  }


  Future<void> _clearFirestoreCollection(String collectionName) async {
    final collection = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(collectionName)
        .get();

    for (final doc in collection.docs) {
      await doc.reference.delete();
    }
  }
}