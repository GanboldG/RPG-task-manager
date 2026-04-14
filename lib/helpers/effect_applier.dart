import 'package:rpg_task_manager/models/item/item.dart';

class EffectApplier {

  // Calculate final XP with all active effects
  static double calculateXPGain(double baseXp, List<ItemEffect> activeEffects) {
    double xpMultiplier = 1.0;
    double goldMultiplier = 1.0;
    
    for (var effect in activeEffects) {
      switch (effect.type) {
        case EffectType.increaseXpGain:
          xpMultiplier += effect.value;
          break;
        default:
          break;
      }
    }
    
    return baseXp * xpMultiplier.clamp(0.5, 5.0);
  }
  

  // Calculate final Gold with all active effects
  static int calculateGoldGain(int baseGold, List<ItemEffect> activeEffects) {
    double goldMultiplier = 1.0;
    
    for (var effect in activeEffects) {
      switch (effect.type) {
        case EffectType.increaseGoldGain:
          goldMultiplier += effect.value;
          break;
        default:
          break;
      }
    }
    
    return (baseGold * goldMultiplier.clamp(0.1, 3.0)).round();
  }
  
  // Calculate final price with discounts
  static int calculateDiscountedPrice(int basePrice, List<ItemEffect> activeEffects, bool isCustomShop) {
    double discountMultiplier = 1.0;
    
    for (var effect in activeEffects) {
      if (isCustomShop && effect.type == EffectType.reduceCustomShopCost) {
        discountMultiplier -= effect.value;
      } else if (!isCustomShop && effect.type == EffectType.reduceBaseShopCost) {
        discountMultiplier -= effect.value;
      }
    }
    
    return (basePrice * discountMultiplier.clamp(0.1, 1.0)).round();
  }
  
  // Calculate which rarity item to appear in the shop
  static double calculateItemRarityChance(double baseChance, List<ItemEffect> activeEffects) {
    double chanceMultiplier = 1.0;
    
    for (var effect in activeEffects) {
      if (effect.type == EffectType.increaseItemRarity) {
        chanceMultiplier += effect.value;
      }
    }
    
    return (baseChance * chanceMultiplier).clamp(0.0, 1.0);
  }
}