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
      avatarPath: fields[5] as String?,
      avatarUrl: fields[25] as String?,
      avatarPublicId: fields[26] as String?,
      bio: fields[6] as String?,
      experiencePoints: fields[7] as int,
      experienceThreshold: fields[17] as int,
      golds: fields[8] as int,
      crystals: fields[9] as int,
      level: fields[10] as int,
      ownedItems: (fields[14] as List?)?.cast<Item>(),
      equippedItems: (fields[15] as List?)?.cast<Item>(),
      ownedCustomItems: (fields[18] as List?)?.cast<OwnedCustomItem>(),
      activatedCustomItems: (fields[19] as List?)?.cast<OwnedCustomItem>(),
      unlockedAchievements: (fields[16] as List?)?.cast<String>(),
      friends: (fields[11] as List?)?.cast<String>(),
      createdAt: fields[12] as DateTime,
      lastActive: fields[13] as DateTime,
      maxEquippedItemAmount: fields[20] as int,
      shopSlot: fields[21] as int,
      customShopSlot: fields[22] as int,
      shopRerolls: fields[23] as int,
      inventorySlot: fields[24] as int,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(27)
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
      ..write(obj.avatarPath)
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
      ..write(obj.ownedItems)
      ..writeByte(15)
      ..write(obj.equippedItems)
      ..writeByte(16)
      ..write(obj.unlockedAchievements)
      ..writeByte(17)
      ..write(obj.experienceThreshold)
      ..writeByte(18)
      ..write(obj.ownedCustomItems)
      ..writeByte(19)
      ..write(obj.activatedCustomItems)
      ..writeByte(20)
      ..write(obj.maxEquippedItemAmount)
      ..writeByte(21)
      ..write(obj.shopSlot)
      ..writeByte(22)
      ..write(obj.customShopSlot)
      ..writeByte(23)
      ..write(obj.shopRerolls)
      ..writeByte(24)
      ..write(obj.inventorySlot)
      ..writeByte(25)
      ..write(obj.avatarUrl)
      ..writeByte(26)
      ..write(obj.avatarPublicId);
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
