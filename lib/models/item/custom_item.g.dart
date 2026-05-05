// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomItemAdapter extends TypeAdapter<CustomItem> {
  @override
  final int typeId = 16;

  @override
  CustomItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomItem(
      id: fields[0] as String,
      name: fields[1] as String,
      durationMinutes: fields[7] as int,
      description: fields[2] as String,
      priceGold: fields[3] as int,
      createdAt: fields[4] as DateTime,
      imagePath: fields[5] as String?,
      purchaseCount: fields[6] as int,
      imagePublicId: fields[9] as String?,
      imageUrl: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CustomItem obj) {
    writer
      ..writeByte(10)
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
      ..write(obj.purchaseCount)
      ..writeByte(7)
      ..write(obj.durationMinutes)
      ..writeByte(8)
      ..write(obj.imageUrl)
      ..writeByte(9)
      ..write(obj.imagePublicId);
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
