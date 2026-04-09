import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/models/difficulty.dart';

class Task {
  int id;
  String name;
  String description;
  Difficulty difficulty;
  int baseSeconds;
  int doneSeconds = 0;
  DateTime? deadline;

  Task({required this.id, 
        required this.name,
        this.description = "",
        required this.difficulty,
        required this.baseSeconds,
        DateTime? deadline,
        this.doneSeconds = 0,
  }) : deadline = deadline != null 
      ? DateTime(deadline.year, deadline.month, deadline.day, deadline.hour, deadline.minute)
      : null; // Removes seconds / milleseconds from deadline


  // -----------------Helper methods related to DateTime-------------------

  double getBaseMinutes(){
    return double.parse((baseSeconds / 60).toStringAsFixed(1));
  }

  double getDoneMinutes(){
    return double.parse((doneSeconds / 60).toStringAsFixed(1));
  }

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
      final remainingSec = baseSeconds - doneSeconds;
      int hours = 0;
      int minutes = remainingSec ~/ 60;
      int seconds = remainingSec % 60;

      if (minutes >= 60){
        hours = minutes ~/ 60;
        minutes = minutes % 60;
      }
      
      if (hours > 0) {
          return "${hours}h ${minutes}m ${seconds}s";
      } 
      else if (minutes > 0){
          return "${minutes}m ${seconds}s";
      }
      else {
        return "${seconds}s";
      }
  }

  String getFormattedStudyingTime() {
    final minutes = doneSeconds ~/ 60;
    final seconds = doneSeconds % 60;
    
    if (minutes > 0) {
      return "$minutes m ${seconds}s";
    } else {
      return "${seconds}s";
    }
  }

  double get progress {
    if (baseSeconds <= 0) return 0;
    return doneSeconds / baseSeconds;
  }
}