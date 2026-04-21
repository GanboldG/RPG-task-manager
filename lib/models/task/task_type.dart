import 'package:hive/hive.dart';

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
