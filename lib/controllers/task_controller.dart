import 'package:flutter/material.dart';
import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/models/task.dart';

class TaskController{
  BuildContext context;
  TaskController({required this.context});

  List<Task> tasks = [
      Task(id: 0, name: "Learn"),
      Task(id: 1, name: "Die"),
      Task(id: 2, name: "Repeat"),
   ];

  // Adds a task into list
  void addTask(){
    tasks.add(Task(id: tasks.length, name: "Task ${tasks.length}"));
  }


  void deleteTask(int id){
    Task? matchedTask = _findTaskByID(id);

    if (matchedTask != null){
      tasks.remove(matchedTask);
      HelperFunctions.showMessage(context, "Deleted task: ${matchedTask.name}");
    }
  }


  Task? _findTaskByID(int id){
    for (Task task in tasks){
      if (task.id == id){
        return task;
      }
    }

    return null;
  }
}