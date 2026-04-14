import 'dart:math';
import 'package:rpg_task_manager/models/difficulty.dart';
import 'package:rpg_task_manager/models/reward.dart';

class RewardService {
  static final Random _random = Random();
  
  static Reward calculateTaskReward(Difficulty difficulty, int durationMinutes){
    return Reward(
      crystal: calculateTaskCrystal(difficulty, durationMinutes), 
      gold: calculateTaskGold(difficulty, durationMinutes), 
      xp: calculateTaskXP(difficulty, durationMinutes)
    );
  }

  // Calculate XP from task
  // Base: 1 XP per 5 minutes (0.2 XP per minute)
  static int calculateTaskXP(Difficulty difficulty, int durationMinutes) {
    // Base XP: 1 XP per 5 minutes, minimum 1 XP
    int baseXP = (durationMinutes / 5).ceil(); // Ceil so 5 min = 1 XP, 10 min = 2 XP
    
    // Apply difficulty multiplier
    double multipliedXP = baseXP * difficulty.xpMultiplier;
    
    // Return as integer (no decimals)
    return multipliedXP.round();
  }

  static int calculateTaskGold(Difficulty difficulty, int durationMinutes) {
    // Base gold: 2 gold per minute, minimum 10 gold
    int baseGold = durationMinutes.clamp(5, 120) * 2;
    
    // Apply difficulty multiplier
    double multipliedGold = baseGold * difficulty.goldMultiplier;
    
    // Return as integer
    return multipliedGold.round();
  }

  static int calculateTaskCrystal(Difficulty difficulty, int durationMinutes) {
    // Get drop chance based on difficulty
    double dropChance = _getCrystalDropChance(difficulty);
    
    // Optional: duration bonus (longer tasks slightly better chance)
    // 3000 min task = 2x bonus, 5 min task = 1x
    double durationBonus = 1.0 + ((durationMinutes.clamp(5, 3000) - 5) / 2995);
    double finalChance = (dropChance * durationBonus).clamp(0, 0.5);
    
    // Roll for crystal drop
    if (_random.nextDouble() < finalChance) {
      return 1; // Crystal drops
    }
    
    return 0; // No crystal
  }
  
  // Helper method to get crystal drop chance based on difficulty
  static double _getCrystalDropChance(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 0.001; // 1 in 1000 (0.1%)
      case Difficulty.medium:
        return 0.01;   // 1 in 100 (1%)
      case Difficulty.hard:
        return 0.10;   // 1 in 10 (10%)
      case Difficulty.expert:
        return 0.20;   // 1 in 5 (20%)
      default:
        return 0.01;   // Default to medium
    }
  }
}