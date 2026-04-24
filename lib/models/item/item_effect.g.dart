// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_effect.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemEffectAdapter extends TypeAdapter<ItemEffect> {
  @override
  final int typeId = 11;

  @override
  ItemEffect read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemEffect(
      type: fields[0] as EffectType,
      value: fields[1] as double,
      secondaryValue: fields[2] as String?,
      isStackable: fields[3] as bool,
      maxStack: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ItemEffect obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.secondaryValue)
      ..writeByte(3)
      ..write(obj.isStackable)
      ..writeByte(4)
      ..write(obj.maxStack);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemEffectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
