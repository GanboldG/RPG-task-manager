// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomItemAdapter extends TypeAdapter<CustomItem> {
  @override
  final int typeId = 3;

  @override
  CustomItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomItem(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      priceGold: fields[3] as int,
      createdAt: fields[4] as DateTime,
      imagePath: fields[5] as String?,
      purchaseCount: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CustomItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.priceGold)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.imagePath)
      ..writeByte(6)
      ..write(obj.purchaseCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
