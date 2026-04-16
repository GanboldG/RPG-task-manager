// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voucher.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VoucherAdapter extends TypeAdapter<Voucher> {
  @override
  final int typeId = 2;

  @override
  Voucher read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Voucher(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      priceGold: fields[3] as int,
      createdAt: fields[4] as DateTime,
      imagePath: fields[5] as String?,
      purchaseCount: fields[6] as int,
      isRedeemed: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Voucher obj) {
    writer
      ..writeByte(8)
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
      ..write(obj.isRedeemed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoucherAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
