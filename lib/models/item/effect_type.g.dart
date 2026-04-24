// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'effect_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
