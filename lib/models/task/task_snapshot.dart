import 'package:hive/hive.dart';

part 'task_snapshot.g.dart';  // Generated file

@HiveType(typeId: 20)
class TaskSnapshot extends HiveObject {
  @HiveField(0)
  String day; // "2026-05-10"

  @HiveField(1)
  Map<String, double> taskMinutes;

  TaskSnapshot({
    required this.day,
    required this.taskMinutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'taskMinutes': taskMinutes,
    };
  }

  factory TaskSnapshot.fromMap(Map<String, dynamic> map) {
    return TaskSnapshot(
      day: map['day'],
      taskMinutes: Map<String, double>.from(map['taskMinutes']),
    );
  }

  
}