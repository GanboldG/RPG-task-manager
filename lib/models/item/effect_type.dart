
import 'package:hive/hive.dart';

part 'effect_type.g.dart';

@HiveType(typeId: 10)
enum EffectType {
  @HiveField(0)
  increaseXpGain,
  
  @HiveField(1)
  increaseGoldGain,
  
  @HiveField(2)
  increaseCrystalDropChance,
  
  @HiveField(3)
  reduceGoldGain, // Trade-off effect
  
  @HiveField(4)
  reduceCustomShopCost,
  
  @HiveField(5)
  reduceBaseShopCost,
  
  @HiveField(6)
  rerollBaseShop,
  
  @HiveField(7)
  increaseItemRarity,
  
  @HiveField(8)
  reduceTaskDuration,
  
  @HiveField(9)
  increaseTaskReward,
  
  @HiveField(10)
  passiveIncomeBonus,

  @HiveField(11)
  reduceXpGain,
}