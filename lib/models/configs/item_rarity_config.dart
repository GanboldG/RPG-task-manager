import 'package:rpg_task_manager/models/item/item_rarity.dart';

class ItemRarityConfig {
  final Map<ItemRarity, double> durationMultipliers;
  final Map<ItemRarity, double> durationMultPerLevel;
  final Map<ItemRarity, double> effectMultipliers;
  final Map<ItemRarity, double> effectMultPerLevel;
  final double costMultPerLevel;
  
  ItemRarityConfig({
    required this.durationMultipliers,
    required this.durationMultPerLevel,
    required this.effectMultipliers,
    required this.effectMultPerLevel,
    required this.costMultPerLevel,
  });
  
  // Factory method to create from JSON
  factory ItemRarityConfig.fromJson(Map<String, dynamic> json) {
    // Helper to parse rarity maps
    Map<ItemRarity, double> _parseRarityMap(Map<String, dynamic> jsonMap) {
      return jsonMap.map((key, value) {
        return MapEntry(_stringToRarity(key), (value as num).toDouble());
      });
    }
    
    return ItemRarityConfig(
      durationMultipliers: _parseRarityMap(json['durationMultipliers'] ?? {}),
      durationMultPerLevel: _parseRarityMap(json['durationMultPerLevel'] ?? {}),
      effectMultipliers: _parseRarityMap(json['effectMultipliers'] ?? {}),
      effectMultPerLevel: _parseRarityMap(json['effectMultPerLevel'] ?? {}),
      costMultPerLevel: (json['costMultPerLevel'] ?? 0.4).toDouble(),
    );
  }
  
  // Helper to convert string to ItemRarity enum
  static ItemRarity _stringToRarity(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common': return ItemRarity.common;
      case 'uncommon': return ItemRarity.uncommon;
      case 'rare': return ItemRarity.rare;
      case 'epic': return ItemRarity.epic;
      case 'legendary': return ItemRarity.legendary;
      case 'mythic': return ItemRarity.mythic;
      default: return ItemRarity.common;
    }
  }
  
  // To JSON (if needed for saving)
  Map<String, dynamic> toJson() {
    return {
      'durationMultipliers': _rarityMapToJson(durationMultipliers),
      'durationMultPerLevel': _rarityMapToJson(durationMultPerLevel),
      'effectMultipliers': _rarityMapToJson(effectMultipliers),
      'effectMultPerLevel': _rarityMapToJson(effectMultPerLevel),
      'costMultPerLevel': costMultPerLevel,
    };
  }
  
  Map<String, double> _rarityMapToJson(Map<ItemRarity, double> map) {
    return map.map((key, value) => MapEntry(key.toString().split('.').last, value));
  }
}