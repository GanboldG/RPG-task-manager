// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_rarity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemRarityAdapter extends TypeAdapter<ItemRarity> {
  @override
  final int typeId = 5;

  @override
  ItemRarity read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ItemRarity.common;
      case 1:
        return ItemRarity.uncommon;
      case 2:
        return ItemRarity.rare;
      case 3:
        return ItemRarity.epic;
      case 4:
        return ItemRarity.legendary;
      case 5:
        return ItemRarity.mythic;
      default:
        return ItemRarity.common;
    }
  }

  @override
  void write(BinaryWriter writer, ItemRarity obj) {
    switch (obj) {
      case ItemRarity.common:
        writer.writeByte(0);
        break;
      case ItemRarity.uncommon:
        writer.writeByte(1);
        break;
      case ItemRarity.rare:
        writer.writeByte(2);
        break;
      case ItemRarity.epic:
        writer.writeByte(3);
        break;
      case ItemRarity.legendary:
        writer.writeByte(4);
        break;
      case ItemRarity.mythic:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemRarityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
