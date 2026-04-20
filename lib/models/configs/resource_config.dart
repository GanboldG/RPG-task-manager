// lib/models/game_config.dart
import 'dart:math';

class ResourceConfig {
  final double baseXp;
  final double easyTaskXpMultiplier;
  final double mediumTaskXpMultiplier;
  final double hardTaskXpMultiplier;
  final double expertTaskXpMultiplier;
  
  final double baseXpPerLevel;
  final double xpMaxVariance;
  final double xpPerTask5Minutes;
  
  final double baseXptoLevel;
  final double xpGrowthFactor;

  final double baseGold;
  final double easyTaskGoldMultiplier;
  final double mediumTaskGoldMultiplier;
  final double hardTaskGoldMultiplier;
  final double expertTaskGoldMultiplier;
  
  final double baseGoldPerLevel;
  final double goldMaxVariance;
  final double goldPerTask5Minutes;  
  final double baseCrystalDropChance;
  final double easyTaskCrystalMultiplier;
  final double mediumTaskCrystalMultiplier;
  final double hardTaskCrystalMultiplier;
  final double expertTaskCrystalMultiplier;
  
  final double itemDurationPerLevel;
  final double itemDurationMaxVariance;
  
  ResourceConfig({
    required this.baseXp,
    required this.easyTaskXpMultiplier,
    required this.mediumTaskXpMultiplier,
    required this.hardTaskXpMultiplier,
    required this.expertTaskXpMultiplier,
    required this.baseXpPerLevel,
    required this.xpMaxVariance,
    required this.xpPerTask5Minutes,
    required this.baseGold,
    required this.easyTaskGoldMultiplier,
    required this.mediumTaskGoldMultiplier,
    required this.hardTaskGoldMultiplier,
    required this.expertTaskGoldMultiplier,
    required this.baseGoldPerLevel,
    required this.goldMaxVariance,
    required this.goldPerTask5Minutes,
    required this.baseCrystalDropChance,
    required this.easyTaskCrystalMultiplier,
    required this.mediumTaskCrystalMultiplier,
    required this.hardTaskCrystalMultiplier,
    required this.expertTaskCrystalMultiplier,
    required this.itemDurationPerLevel,
    required this.itemDurationMaxVariance,
    required this.baseXptoLevel,
    required this.xpGrowthFactor
  });
  
  // Factory method to create from JSON
  factory ResourceConfig.fromJson(Map<String, dynamic> json) {
    return ResourceConfig(
      baseXp: (json['base_xp'] ?? 100).toDouble(),
      easyTaskXpMultiplier: (json['easy_task_xp_multiplier'] ?? 1).toDouble(),
      mediumTaskXpMultiplier: (json['medium_task_xp_multiplier'] ?? 1.5).toDouble(),
      hardTaskXpMultiplier: (json['hard_task_xp_multiplier'] ?? 2).toDouble(),
      expertTaskXpMultiplier: (json['expert_task_xp_multiplier'] ?? 3).toDouble(),
      baseXpPerLevel: (json['base_xp_per_level'] ?? 0.05).toDouble(),
      xpMaxVariance: (json['xp_max_variance'] ?? 1.2).toDouble(),
      xpPerTask5Minutes: (json['xp_per_task_5minutes'] ?? 0.08).toDouble(),
      baseXptoLevel: (json['base_xp_to_level'] ?? 100).toDouble(),
      xpGrowthFactor: (json['xp_growth_factor'] ?? 1.15).toDouble(),

      baseGold: (json['base_gold'] ?? 5).toDouble(),
      easyTaskGoldMultiplier: (json['easy_task_gold_multiplier'] ?? 1).toDouble(),
      mediumTaskGoldMultiplier: (json['medium_task_gold_multiplier'] ?? 1.5).toDouble(),
      hardTaskGoldMultiplier: (json['hard_task_gold_multiplier'] ?? 2).toDouble(),
      expertTaskGoldMultiplier: (json['expert_task_gold_multiplier'] ?? 3).toDouble(),
      baseGoldPerLevel: (json['base_gold_per_level'] ?? 1.05).toDouble(),
      goldMaxVariance: (json['gold_max_variance'] ?? 1.1).toDouble(),
      goldPerTask5Minutes: (json['gold_per_task_5minutes'] ?? 0.08).toDouble(),
      baseCrystalDropChance: (json['base_crystal_drop_chance'] ?? 0.005).toDouble(),
      easyTaskCrystalMultiplier: (json['easy_task_crystal_multiplier'] ?? 1).toDouble(),
      mediumTaskCrystalMultiplier: (json['medium_task_crystal_multiplier'] ?? 1.5).toDouble(),
      hardTaskCrystalMultiplier: (json['hard_task_crystal_multiplier'] ?? 2).toDouble(),
      expertTaskCrystalMultiplier: (json['expert_task_crystal_multiplier'] ?? 3).toDouble(),
      itemDurationPerLevel: (json['item_duration_per_level'] ?? 1.1).toDouble(),
      itemDurationMaxVariance: (json['item_duration_max_variance'] ?? 2).toDouble(),
    );
  }
  
  // Helper methods for calculations
  double calculateXp(int playerLevel, String difficulty) {
    double multiplier = _getXpMultiplier(difficulty);
    double baseWithLevel = baseXp * pow(baseXpPerLevel, playerLevel - 1);
    double result = baseWithLevel * multiplier;
    
    // Apply variance
    double variance = 1 + (xpMaxVariance - 1) * (DateTime.now().millisecondsSinceEpoch % 1000 / 1000);
    return result * variance;
  }
  
  double _getXpMultiplier(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy': return easyTaskXpMultiplier;
      case 'medium': return mediumTaskXpMultiplier;
      case 'hard': return hardTaskXpMultiplier;
      case 'expert': return expertTaskXpMultiplier;
      default: return 1;
    }
  }
}