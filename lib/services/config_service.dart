import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:rpg_task_manager/models/configs/item_rarity_config.dart';
import 'package:rpg_task_manager/models/configs/resource_config.dart';
import 'package:rpg_task_manager/models/item/item_rarity.dart';

class ConfigService {
  static ResourceConfig? _resourceConfig;
  static ItemRarityConfig? _itemRarityConfig;
  
  // Load all configs
  static Future<void> loadAllConfigs() async {
    await loadResourceConfig();
    await loadItemRarityConfig();
  }
  
  // Load Resource Config
  static Future<ResourceConfig> loadResourceConfig() async {
    if (_resourceConfig != null) return _resourceConfig!;
    
    try {
      final jsonString = await rootBundle.loadString('assets/config/resource_rate.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _resourceConfig = ResourceConfig.fromJson(jsonMap);
      return _resourceConfig!;
    } catch (e) {
      print('Error loading resource config: $e, using default');
      return _getDefaultResourceConfig();
    }
  }
  
  // Load Item Config
  static Future<ItemRarityConfig> loadItemRarityConfig() async {
    if (_itemRarityConfig != null) return _itemRarityConfig!;
    
    try {
      final jsonString = await rootBundle.loadString('assets/config/item_rarity.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _itemRarityConfig = ItemRarityConfig.fromJson(jsonMap);
      return _itemRarityConfig!;
    } catch (e) {
      print('Error loading item config: $e, using default');
      return _getDefaultItemConfig();
    }
  }
  
  // Getters
  static ResourceConfig get resourceConfig {
    if (_resourceConfig == null) {
      throw Exception('Config not loaded. Call loadAllConfigs() or loadResourceConfig() first.');
    }
    return _resourceConfig!;
  }
  
  static ItemRarityConfig get itemRarityConfig {
    if (_itemRarityConfig == null) {
      throw Exception('Config not loaded. Call loadAllConfigs() or loadItemConfig() first.');
    }
    return _itemRarityConfig!;
  }
  
  // Default Resource Config
  static ResourceConfig _getDefaultResourceConfig() {
    return ResourceConfig(
      baseXp: 100,
      easyTaskXpMultiplier: 1,
      mediumTaskXpMultiplier: 1.5,
      hardTaskXpMultiplier: 2,
      expertTaskXpMultiplier: 3,
      baseXpPerLevel: 0.05,
      xpMaxVariance: 1.2,
      xpPerTask5Minutes: 0.08,
      baseXptoLevel: 100,
      xpGrowthFactor: 1.15,
      baseGold: 5,
      easyTaskGoldMultiplier: 1,
      mediumTaskGoldMultiplier: 1.5,
      hardTaskGoldMultiplier: 2,
      expertTaskGoldMultiplier: 3,
      baseGoldPerLevel: 1.05,
      goldMaxVariance: 1.1,
      goldPerTask5Minutes: 0.08,
      baseCrystalDropChance: 0.005,
      easyTaskCrystalMultiplier: 1,
      mediumTaskCrystalMultiplier: 1.5,
      hardTaskCrystalMultiplier: 2,
      expertTaskCrystalMultiplier: 3,
      itemDurationPerLevel: 1.1,
      itemDurationMaxVariance: 2,
    );
  }
  
  // Default Item Config
  static ItemRarityConfig _getDefaultItemConfig() {
    return ItemRarityConfig(
      durationMultipliers: {
        ItemRarity.common: 0,
        ItemRarity.uncommon: 0.2,
        ItemRarity.rare: 0.6,
        ItemRarity.epic: 1.4,
        ItemRarity.legendary: 2,
        ItemRarity.mythic: 3,
      },
      durationMultPerLevel: {
        ItemRarity.common: 0,
        ItemRarity.uncommon: 0.2,
        ItemRarity.rare: 0.6,
        ItemRarity.epic: 1.4,
        ItemRarity.legendary: 2,
        ItemRarity.mythic: 3,
      },
      effectMultipliers: {
        ItemRarity.common: 0,
        ItemRarity.uncommon: 0.2,
        ItemRarity.rare: 0.4,
        ItemRarity.epic: 0.8,
        ItemRarity.legendary: 1.6,
        ItemRarity.mythic: 2,
      },
      effectMultPerLevel: {
        ItemRarity.common: 0.05,
        ItemRarity.uncommon: 0.2,
        ItemRarity.rare: 0.5,
        ItemRarity.epic: 0.9,
        ItemRarity.legendary: 1.5,
        ItemRarity.mythic: 2,
      },
      costMultPerLevel: 0.4,
    );
  }
  
  // Optional: Clear configs (useful for testing)
  static void clearConfigs() {
    _resourceConfig = null;
    _itemRarityConfig = null;
  }
}