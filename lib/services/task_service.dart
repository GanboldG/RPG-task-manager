import 'package:rpg_task_manager/models/task.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rpg_task_manager/services/task_id_counter.dart';

class TaskService {
  final Box<Task> activeBox = Hive.box<Task>('active_tasks');
  
  Future<int> addTask(Task task) async {
    int newId = await TaskIdCounter.getNextId();
    
    // Add to box (key = task.id, value = task)
    await activeBox.put(task.id, task);
    
    return newId;
  }
}