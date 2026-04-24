// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemAdapter extends TypeAdapter<Item> {
  @override
  final int typeId = 4;

  @override
  Item read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Item(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      imageUrl: fields[3] as String,
      isPermanent: fields[4] as bool,
      durationSeconds: fields[5] as int,
      priceGold: fields[6] as int,
      priceCrystal: fields[7] as int,
      thresholdLevel: fields[8] as int,
      effects: (fields[9] as List).cast<ItemEffect>(),
      rarity: fields[10] as ItemRarity,
      level: fields[11] as int,
      acquiredDate: fields[12] as DateTime,
      remainingSeconds: fields[13] as int,
      isActivated: fields[14] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Item obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.isPermanent)
      ..writeByte(5)
      ..write(obj.durationSeconds)
      ..writeByte(6)
      ..write(obj.priceGold)
      ..writeByte(7)
      ..write(obj.priceCrystal)
      ..writeByte(8)
      ..write(obj.thresholdLevel)
      ..writeByte(9)
      ..write(obj.effects)
      ..writeByte(10)
      ..write(obj.rarity)
      ..writeByte(11)
      ..write(obj.level)
      ..writeByte(12)
      ..write(obj.acquiredDate)
      ..writeByte(13)
      ..write(obj.remainingSeconds)
      ..writeByte(14)
      ..write(obj.isActivated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
