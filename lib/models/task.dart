import 'package:rpg_task_manager/models/difficulty.dart';

class Task {
  int id;
  String name;
  Difficulty difficulty;
  double baseMinutes;
  double doneMinutes = 0;

  Task({required this.id, 
        required this.name,
        required this.difficulty,
        required this.baseMinutes,
  });
}