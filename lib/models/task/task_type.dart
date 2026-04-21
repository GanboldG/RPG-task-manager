import 'package:hive/hive.dart';

part 'task_type.g.dart';  // Generated file

@HiveType(typeId: 8)
enum TaskType {
  @HiveField(0)
  learning,

  @HiveField(1)
  health,

  @HiveField(2)
  chore,

  @HiveField(3)
  social,

  @HiveField(4)
  career,
}
