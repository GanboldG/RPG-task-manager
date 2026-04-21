import 'package:rpg_task_manager/models/item/item_rarity.dart';

class ItemConfig{
  final Map<ItemRarity, double> durationMultipliers;
  final Map<ItemRarity, double> durationMultPerLevel;
  final Map<ItemRarity, double> effectMultipliers;
  final Map<ItemRarity, double> effectMultPerLevel;
  final double costMultPerLevel;

  ItemConfig({
    required this.durationMultipliers,
    required this.durationMultPerLevel,
    required this.effectMultipliers,
    required this.effectMultPerLevel,
    required this.costMultPerLevel,
  });
}