import 'dart:math';

import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/models/difficulty.dart';
import 'package:hive/hive.dart';
import 'package:rpg_task_manager/models/reward.dart';
import 'package:rpg_task_manager/models/task/task_type.dart';

part 'task.g.dart';  // Generated file

@HiveType(typeId: 0)  // Each class needs unique typeId

class Task {
  // --------------Hive Stuff that converts to bytes to storage----------------

  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  bool isCompleted;
  
  @HiveField(4)
  Difficulty difficulty;
  
  @HiveField(5)
  int baseDurationSec;

  @HiveField(6)
  int doneDurationSec;

  @HiveField(7)
  DateTime? deadline;

  @HiveField(8)
  DateTime createdAt;
  
  @HiveField(9)
  DateTime? completedAt;

  @HiveField(10)
  Reward reward;

  @HiveField(11)
  int? orderId;

  @HiveField(12)
  TaskType? type;

  Task({
    required this.id,
    required this.orderId,
    required this.name,
    this.description = "",
    this.isCompleted = false,
    required this.difficulty,
    required this.baseDurationSec,
    this.doneDurationSec = 0,
    DateTime? deadline,
    required this.createdAt,
    this.completedAt,
    required this.reward,
    required this.type,
  }) : deadline = deadline != null
          ? DateTime(
              deadline.year,
              deadline.month,
              deadline.day,
              deadline.hour,
              deadline.minute,
            )
          : null;

  // ------------------------Firestore / JSON save & load------------------------

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isCompleted': isCompleted,
      'difficulty': difficulty.toMap(),
      'baseDurationSec': baseDurationSec,
      'doneDurationSec': doneDurationSec,
      'deadline': deadline,
      'createdAt': createdAt,
      'completedAt': completedAt,
      'reward': reward.toMap(),
      'orderId': orderId,
      'type': type?.name, // enum example
    };
  }


  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      isCompleted: map['isCompleted'],
      difficulty: Difficulty.fromMap(map['difficulty']),
      baseDurationSec: map['baseDurationSec'],
      doneDurationSec: map['doneDurationSec'],
      deadline: map['deadline']?.toDate(),
      createdAt: map['createdAt'].toDate(),
      completedAt: map['completedAt']?.toDate(),
      reward: Reward.fromMap(map['reward']),
      orderId: map['orderId'],
      type: map['type'] != null
          ? TaskType.values.firstWhere((e) => e.name == map['type'])
          : null,
    );
  }

  // -----------------Helper methods related to DateTime-------------------

  double getBaseMinutes(){
    return double.parse((baseDurationSec / 60).toStringAsFixed(1));
  }

  double getDoneMinutes(){
    return double.parse((doneDurationSec / 60).toStringAsFixed(1));
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
      final remainingSec = baseDurationSec - doneDurationSec;
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
    final minutes = doneDurationSec ~/ 60;
    final seconds = doneDurationSec % 60;
    
    if (minutes > 0) {
      return "$minutes m ${seconds}s";
    } else {
      return "${seconds}s";
    }
  }

  double get progress {
    if (baseDurationSec <= 0) return 0;
    return doneDurationSec / baseDurationSec;
  }

  int getRewardXp(){
    return reward.xp;
  }

  int getRewardGold(){
    return reward.gold;
  }

  int getRemainingSeconds(){
    return max(0, baseDurationSec - doneDurationSec);
  }

  int? getSecondsSinceCompletion() {
    if (!isCompleted || completedAt == null){
      return null;
    }

    return DateTime.now()
        .difference(completedAt!)
        .inSeconds;
  }
}