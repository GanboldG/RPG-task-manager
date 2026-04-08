import 'package:flutter/material.dart';
import 'package:rpg_task_manager/models/difficulty.dart';
import 'package:rpg_task_manager/models/task.dart';

class TaskController extends ChangeNotifier{

  List<Task> tasks = [
      Task(id: 0, 
           name: "Learn\nsdf\nsdfsd\nsf",
           difficulty: Difficulty.easy,
           baseMinutes: 10),
      Task(id: 1, 
           name: "Die",
           difficulty: Difficulty.medium,
           baseMinutes: 20),
      Task(id: 2, 
           name: "Repeat",
           difficulty: Difficulty.hard,
           baseMinutes: 30),
   ];

  // Adds a task into list
  void addTask(){
    tasks.add(Task(
      id: tasks.length, 
      name: "Task ${tasks.length}",
      difficulty: Difficulty.easy,
      baseMinutes: 30,
    ));
    notifyListeners();
  }


  // Deletes a task with certain id
  String deleteTask(int id){
    Task? matchedTask = _findTaskByID(id);

    if (matchedTask != null){
      tasks.remove(matchedTask);
      notifyListeners();
      return matchedTask.name;
    }

    return "Something went wrong";
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