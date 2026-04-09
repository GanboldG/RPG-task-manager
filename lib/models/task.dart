import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/models/difficulty.dart';

class Task {
  int id;
  String name;
  String description;
  Difficulty difficulty;
  int baseMinutes;
  int doneMinutes = 0;
  DateTime? deadline;

  Task({required this.id, 
        required this.name,
        this.description = "",
        required this.difficulty,
        required this.baseMinutes,
        DateTime? deadline,
  }) : deadline = deadline != null 
      ? DateTime(deadline.year, deadline.month, deadline.day, deadline.hour, deadline.minute)
      : null; // Removes seconds / milleseconds from deadline


  // -----------------Helper methods related to DateTime-------------------

  String getDeadlineString(){
    return HelperFunctions.formatDateTimeToString(deadline);
  }

  String getTimeTillDeadlineString(){
      if (deadline == null) return "No Deadline";
      
      final difference = deadline!.difference(DateTime.now());
      if (difference.isNegative) return "Overdue";
      
      final days = difference.inDays;
      final hours = difference.inHours % 24;
      final minutes = difference.inMinutes % 60;
      
      if (days > 0) return "${days}d";
      if (hours > 0) return "${hours}h";
      if (minutes > 0) return "${minutes}m";
      return "Less than a minute";
  }

  String getRemainingTimeString(){
      final remaining = baseMinutes - doneMinutes;
      final hours = remaining ~/ 60;
      final minutes = remaining % 60;
      
      if (hours > 0) {
          return "${hours}h ${minutes}m";
      } else {
          return "${minutes}m";
      }
  }
}