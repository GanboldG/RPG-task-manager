// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 3;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      fullName: fields[1] as String,
      email: fields[2] as String,
      phoneNumber: fields[3] as String?,
      dateOfBirth: fields[4] as DateTime?,
      avatarUrl: fields[5] as String?,
      bio: fields[6] as String?,
      experiencePoints: fields[7] as int,
      experienceThreshold: fields[20] as int,
      golds: fields[8] as int,
      crystals: fields[9] as int,
      level: fields[10] as int,
      ownedItems: (fields[16] as List?)?.cast<Item>(),
      equippedItems: (fields[17] as List?)?.cast<Item>(),
      ownedCustomItems: (fields[21] as List?)?.cast<OwnedCustomItem>(),
      activatedCustomItems: (fields[22] as List?)?.cast<OwnedCustomItem>(),
      unlockedAchievements: (fields[18] as List?)?.cast<int>(),
      badges: (fields[19] as List?)?.cast<int>(),
      friends: (fields[11] as List?)?.cast<int>(),
      tasksCompleted: fields[14] as int,
      totalWorkTime: fields[15] as Duration,
      createdAt: fields[12] as DateTime,
      lastActive: fields[13] as DateTime,
      maxEquippedItemAmount: fields[23] as int,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.dateOfBirth)
      ..writeByte(5)
      ..write(obj.avatarUrl)
      ..writeByte(6)
      ..write(obj.bio)
      ..writeByte(7)
      ..write(obj.experiencePoints)
      ..writeByte(8)
      ..write(obj.golds)
      ..writeByte(9)
      ..write(obj.crystals)
      ..writeByte(10)
      ..write(obj.level)
      ..writeByte(11)
      ..write(obj.friends)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.lastActive)
      ..writeByte(14)
      ..write(obj.tasksCompleted)
      ..writeByte(15)
      ..write(obj.totalWorkTime)
      ..writeByte(16)
      ..write(obj.ownedItems)
      ..writeByte(17)
      ..write(obj.equippedItems)
      ..writeByte(18)
      ..write(obj.unlockedAchievements)
      ..writeByte(19)
      ..write(obj.badges)
      ..writeByte(20)
      ..write(obj.experienceThreshold)
      ..writeByte(21)
      ..write(obj.ownedCustomItems)
      ..writeByte(22)
      ..write(obj.activatedCustomItems)
      ..writeByte(23)
      ..write(obj.maxEquippedItemAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
