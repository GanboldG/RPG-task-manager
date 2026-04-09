import 'package:rpg_task_manager/models/difficulty.dart';

class Task {
  int id;
  String name;
  Difficulty difficulty;
  int baseMinutes;
  int doneMinutes = 0;
  DateTime? deadline;

  Task({required this.id, 
        required this.name,
        required this.difficulty,
        required this.baseMinutes,
        DateTime? deadline,
  }) : deadline = deadline != null 
      ? DateTime(deadline.year, deadline.month, deadline.day, deadline.hour, deadline.minute)
      : null; // Removes seconds / milleseconds from deadline
}