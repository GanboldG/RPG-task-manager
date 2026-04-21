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
      itemConfig: fields[15] as ItemConfig,
    );
  }

  @override
  void write(BinaryWriter writer, Item obj) {
    writer
      ..writeByte(16)
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
      ..write(obj.isActivated)
      ..writeByte(15)
      ..write(obj.itemConfig);
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

class EffectTypeAdapter extends TypeAdapter<EffectType> {
  @override
  final int typeId = 10;

  @override
  EffectType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EffectType.increaseXpGain;
      case 1:
        return EffectType.increaseGoldGain;
      case 2:
        return EffectType.increaseCrystalDropChance;
      case 3:
        return EffectType.reduceGoldGain;
      case 4:
        return EffectType.reduceCustomShopCost;
      case 5:
        return EffectType.reduceBaseShopCost;
      case 6:
        return EffectType.rerollBaseShop;
      case 7:
        return EffectType.increaseItemRarity;
      case 8:
        return EffectType.reduceTaskDuration;
      case 9:
        return EffectType.increaseTaskReward;
      case 10:
        return EffectType.passiveIncomeBonus;
      case 11:
        return EffectType.reduceXpGain;
      default:
        return EffectType.increaseXpGain;
    }
  }

  @override
  void write(BinaryWriter writer, EffectType obj) {
    switch (obj) {
      case EffectType.increaseXpGain:
        writer.writeByte(0);
        break;
      case EffectType.increaseGoldGain:
        writer.writeByte(1);
        break;
      case EffectType.increaseCrystalDropChance:
        writer.writeByte(2);
        break;
      case EffectType.reduceGoldGain:
        writer.writeByte(3);
        break;
      case EffectType.reduceCustomShopCost:
        writer.writeByte(4);
        break;
      case EffectType.reduceBaseShopCost:
        writer.writeByte(5);
        break;
      case EffectType.rerollBaseShop:
        writer.writeByte(6);
        break;
      case EffectType.increaseItemRarity:
        writer.writeByte(7);
        break;
      case EffectType.reduceTaskDuration:
        writer.writeByte(8);
        break;
      case EffectType.increaseTaskReward:
        writer.writeByte(9);
        break;
      case EffectType.passiveIncomeBonus:
        writer.writeByte(10);
        break;
      case EffectType.reduceXpGain:
        writer.writeByte(11);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EffectTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
