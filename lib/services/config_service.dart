import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:rpg_task_manager/models/configs/resource_config.dart';

class ConfigService {
  static ResourceConfig? _resourceConfig;
  // other configs here
  
  static Future<ResourceConfig> loadConfigs() async {
    if (_resourceConfig != null) return _resourceConfig!;
    
    try {
      // Load JSON from assets
      final jsonString = await rootBundle.loadString('assets/config/resource_rate.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      
      _resourceConfig = ResourceConfig.fromJson(jsonMap);
      return _resourceConfig!;
    } catch (e) {
      // Return default config if loading fails
      return _getDefaultResourceConfig();
    }
  }
  
  static ResourceConfig get resourceConfig {
    if (_resourceConfig == null) {
      throw Exception('Config not loaded. Call loadConfig() first.');
    }
    return _resourceConfig!;
  }
  
  static ResourceConfig _getDefaultResourceConfig() {
    return ResourceConfig(
      baseXp: 100,
      easyTaskXpMultiplier: 1,
      mediumTaskXpMultiplier: 1.5,
      hardTaskXpMultiplier: 2,
      expertTaskXpMultiplier: 3,
      baseXpPerLevel: 1.05,
      xpMaxVariance: 1.2,
      xpPerTask5Minutes: 0.08,
      baseXptoLevel: 150,
      xpGrowthFactor: 1.17,
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
}