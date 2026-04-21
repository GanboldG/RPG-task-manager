// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskTypeAdapter extends TypeAdapter<TaskType> {
  @override
  final int typeId = 8;

  @override
  TaskType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskType.learning;
      case 1:
        return TaskType.health;
      case 2:
        return TaskType.chore;
      case 3:
        return TaskType.social;
      case 4:
        return TaskType.career;
      default:
        return TaskType.learning;
    }
  }

  @override
  void write(BinaryWriter writer, TaskType obj) {
    switch (obj) {
      case TaskType.learning:
        writer.writeByte(0);
        break;
      case TaskType.health:
        writer.writeByte(1);
        break;
      case TaskType.chore:
        writer.writeByte(2);
        break;
      case TaskType.social:
        writer.writeByte(3);
        break;
      case TaskType.career:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
