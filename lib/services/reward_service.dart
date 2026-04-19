import 'dart:math';
import 'package:rpg_task_manager/models/configs/resource_config.dart';
import 'package:rpg_task_manager/models/difficulty.dart';
import 'package:rpg_task_manager/models/reward.dart';
import 'package:rpg_task_manager/services/config_service.dart';

class RewardService {
  static final Random _random = Random();
  static ResourceConfig config = ConfigService.resourceConfig;
  
  static Reward calculateTaskReward(
    Difficulty difficulty, 
    int durationSeconds,
    int playerLevel
  ) {
    return Reward(
      crystal: calculateTaskCrystal(difficulty, durationSeconds, playerLevel), 
      gold: calculateTaskGold(difficulty, durationSeconds, playerLevel), 
      xp: calculateTaskXP(difficulty, durationSeconds, playerLevel)
    );
  }

  // Calculate XP from task using config
  static int calculateTaskXP(
    Difficulty difficulty, 
    int durationSeconds,
    int playerLevel
  ) {
    double durationMinutes = durationSeconds / 60;
    
    // Base XP after player level scaling
    double xpAfterUserLevel = config.baseXp * (1 + config.baseXpPerLevel * playerLevel);

    // Apply duration scaling (every 5 minutes adds xpPerTask5Minutes)
    int timesToApply = (durationMinutes / 5).round();
    double xpAfterDuration = xpAfterUserLevel * (1 + (timesToApply * config.xpPerTask5Minutes));

    // Apply difficulty multiplier
    double difficultyMultiplier = _getXpMultiplier(difficulty);
    double xpAfterDifficulty = xpAfterDuration * difficultyMultiplier;

    // Apply variance: random between xpAfterDifficulty and xpAfterDifficulty * xpMaxVariance
    double finalXp = _random.nextDouble() * (xpAfterDifficulty * config.xpMaxVariance - xpAfterDifficulty) + xpAfterDifficulty;

    return max(1, finalXp.round());
  }

  // Calculate Gold from task using config (same principle as XP)
  static int calculateTaskGold(
    Difficulty difficulty, 
    int durationSeconds,
    int playerLevel
  ) {
    double durationMinutes = durationSeconds / 60;
    
    // Base gold after player level scaling
    double goldAfterUserLevel = config.baseGold * (1 + config.baseGoldPerLevel * playerLevel);

    // Apply duration scaling (every 5 minutes adds goldPerTask5Minutes)
    int timesToApply = (durationMinutes / 5).round();
    double goldAfterDuration = goldAfterUserLevel * (1 + (timesToApply * config.goldPerTask5Minutes));

    // Apply difficulty multiplier
    double difficultyMultiplier = _getGoldMultiplier(difficulty);
    double goldAfterDifficulty = goldAfterDuration * difficultyMultiplier;

    // Apply variance: random between goldAfterDifficulty and goldAfterDifficulty * goldMaxVariance
    double finalGold = _random.nextDouble() * (goldAfterDifficulty * config.goldMaxVariance - goldAfterDifficulty) + goldAfterDifficulty;

    return max(1, finalGold.round());
  }

  // Calculate Crystal from task using same principle
  static int calculateTaskCrystal(
    Difficulty difficulty, 
    int durationSeconds,
    int playerLevel
  ) {
    
    // Apply difficulty multiplier
    double difficultyMultiplier = _getCrystalMultiplier(difficulty);
    double crystalChance = config.baseCrystalDropChance * difficultyMultiplier;
    
    // Roll for crystal drop
    if (_random.nextDouble() < crystalChance) {
      return 1;
    }
    
    return 0;
  }
  
  // Helper method to get XP multiplier based on difficulty
  static double _getXpMultiplier(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return config.easyTaskXpMultiplier;
      case Difficulty.medium:
        return config.mediumTaskXpMultiplier;
      case Difficulty.hard:
        return config.hardTaskXpMultiplier;
      case Difficulty.expert:
        return config.expertTaskXpMultiplier;
    }
  }
  
  // Helper method to get Gold multiplier based on difficulty
  static double _getGoldMultiplier(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return config.easyTaskGoldMultiplier;
      case Difficulty.medium:
        return config.mediumTaskGoldMultiplier;
      case Difficulty.hard:
        return config.hardTaskGoldMultiplier;
      case Difficulty.expert:
        return config.expertTaskGoldMultiplier;
    }
  }
  
  // Helper method to get Crystal multiplier based on difficulty
  static double _getCrystalMultiplier(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return config.easyTaskCrystalMultiplier;
      case Difficulty.medium:
        return config.mediumTaskCrystalMultiplier;
      case Difficulty.hard:
        return config.hardTaskCrystalMultiplier;
      case Difficulty.expert:
        return config.expertTaskCrystalMultiplier;
    }
  }

  // ----------------XP Threshold calculation---------------------

  // Get XP needed for next level (exponential growth)
  static int xpForNextLevel(int currentLevel) {
    return (config.baseXptoLevel * pow(config.xpGrowthFactor, currentLevel)).round();
  }
}