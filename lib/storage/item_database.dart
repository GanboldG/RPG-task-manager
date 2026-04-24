import 'dart:math';
import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/models/configs/item_rarity_config.dart';
import 'package:rpg_task_manager/models/item/item.dart';
import 'package:rpg_task_manager/models/item/item_effect.dart';
import 'package:rpg_task_manager/models/item/item_rarity.dart';
import 'package:rpg_task_manager/models/user.dart';
import 'package:rpg_task_manager/services/config_service.dart';
import 'package:rpg_task_manager/services/user_service.dart';
import 'package:rpg_task_manager/models/item/effect_type.dart';

// ==================== 1. ITEM DATABASE (Hardcoded Items) ====================
class ItemDatabase {
  static final ItemRarityConfig _itemConfig = ItemRarityConfig(
    durationMultipliers: {  // Applied last
      ItemRarity.common: 0,
      ItemRarity.uncommon: 0.2,
      ItemRarity.rare: 0.6,
      ItemRarity.epic: 1.4,
      ItemRarity.legendary: 2,
      ItemRarity.mythic: 3
    },
    durationMultPerLevel: { // Applied per user level
      ItemRarity.common: 0,
      ItemRarity.uncommon: 0.2,
      ItemRarity.rare: 0.6,
      ItemRarity.epic: 1.4,
      ItemRarity.legendary: 2,
      ItemRarity.mythic: 3
    },
    effectMultipliers: {
      ItemRarity.common: 0,
      ItemRarity.uncommon: 0.2,
      ItemRarity.rare: 0.4,
      ItemRarity.epic: 0.8,
      ItemRarity.legendary: 1.6,
      ItemRarity.mythic: 2
    },
    effectMultPerLevel: {
      ItemRarity.common: 0.05,
      ItemRarity.uncommon: 0.2,
      ItemRarity.rare: 0.5,
      ItemRarity.epic: 0.9,
      ItemRarity.legendary: 1.5,
      ItemRarity.mythic: 2
    },
    costMultPerLevel: 0.4
  );

  // Pre-defined items - like a catalog
  static final List<Item> allItems = [
    // Common Items
    ItemFactory.createXpBoostItem(
      id: "1",
      name: 'Minor XP Potion',
      xpBoostPercent: 0.10, // Base value (will be randomized)
      durationSeconds: 360,
      priceGold: 30,
      priceCrystal: 0,
      imageUrl: 'assets/images/items/minor_xp_potion.png',
      isPermanent: false,
      thresholdLevel: 0,
      rarity: ItemRarity.common,
      level: 1,
      isActivated: false,
      acquiredDate: DateTime.now(),
      itemConfig: _itemConfig,
    ),
    
    ItemFactory.createGoldBoostItem(
      id: "2",
      name: 'Gold Charm',
      goldBoostPercent: 0.08,
      durationSeconds: 360,
      priceGold: 40,
      priceCrystal: 0,
      imageUrl: 'assets/images/items/gold_charm.png',
      isPermanent: false,
      thresholdLevel: 0,
      rarity: ItemRarity.common,
      level: 1,
      isActivated: false,
      acquiredDate: DateTime.now(),
      itemConfig: _itemConfig,
    ),
    
    ItemFactory.createCrystalChanceItem(
      id: "3",
      name: 'Crystal Shard',
      crystalDropChance: 0.08,
      durationSeconds: 360,
      priceGold: 20,
      priceCrystal: 10,
      imageUrl: 'assets/images/items/crystal_shard.png',
      isPermanent: false,
      thresholdLevel: 0,
      rarity: ItemRarity.common,    
      level: 1,
      isActivated: false,
      acquiredDate: DateTime.now(),
      itemConfig: _itemConfig,
    ),
    
    ItemFactory.createGoldBoostItem(
      id: "4",
      name: 'Money Seed',
      goldBoostPercent: 0.01,
      durationSeconds: 1000,
      priceGold: 30,
      priceCrystal: 0,
      imageUrl: 'assets/images/items/money_seed.png',
      isPermanent: false,
      thresholdLevel: 0,
      rarity: ItemRarity.common,    
      level: 1,
      isActivated: false,
      acquiredDate: DateTime.now(),
      itemConfig: _itemConfig,
    ),

    ItemFactory.createXpBoostItem(
      id: "5",
      name: 'Suspicious Cocktail',
      xpBoostPercent: 0.10,
      durationSeconds: 900,
      priceGold: 80,
      priceCrystal: 0,
      imageUrl: 'assets/images/items/suspicious_cocktail.png',
      isPermanent: false,
      thresholdLevel: 0,
      rarity: ItemRarity.common,    
      level: 1,
      isActivated: false,
      acquiredDate: DateTime.now(),
      itemConfig: _itemConfig,
    ),

    ItemFactory.createCrystalChanceItem(
      id: "6",
      name: 'Protector',
      crystalDropChance: 0.2,
      durationSeconds: 1200,
      priceGold: 90,
      priceCrystal: 0,
      imageUrl: 'assets/images/items/protector.png',
      isPermanent: false,
      thresholdLevel: 0,
      rarity: ItemRarity.common,    
      level: 1,
      isActivated: false,
      acquiredDate: DateTime.now(),
      itemConfig: _itemConfig,
    ),
  ];
  
  // Group items by rarity for easy access
  static Map<ItemRarity, List<Item>> get itemsByRarity {
    final map = <ItemRarity, List<Item>>{};
    for (var item in allItems) {
      map.putIfAbsent(item.rarity, () => []).add(item);
    }
    return map;
  }

  // ==================== CLONE & RANDOMIZE METHODS ====================
  
  // Clone an item with randomized values
  static Item randomizeItem(Item original, int userLevel, ItemRarity rarity) {
    final config = ConfigService.itemRarityConfig;

    // 1. Generate new unique ID
    final newId = DateTime.now().millisecondsSinceEpoch.toString();

    // 2. Assign Rarity
    final ItemRarity newRarity = rarity;

    // 3. Calculate new duration
    final double durationMult = config.durationMultipliers[rarity] ?? 0;
    final double durMultLvl = config.durationMultPerLevel[rarity] ?? 0;

    final int minDuration = (original.durationSeconds + userLevel * durMultLvl).round();
    final int maxDuration = (minDuration * (1 + durationMult)).round();
    final int newDurationSec = HelperFunctions.randomInt(minDuration, maxDuration);
    final int newDurationMin = (newDurationSec / 60).round();

    // 4. Calculate new effect value
    final double effectMult = config.effectMultipliers[rarity] ?? 0;
    final double effectMultLvl = config.effectMultPerLevel[rarity] ?? 0;

    List<ItemEffect> newEffects = [];

    for (ItemEffect effect in original.effects) {
      double minValue = effect.value + userLevel * effectMultLvl;
      double maxValue = minValue * (1 + effectMult);
      double randomValue = HelperFunctions.randomDouble(minValue, maxValue);
      
      // Create a new effect instance with the random value
      newEffects.add(ItemEffect(
        type: effect.type,
        value: randomValue,
      ));
    }

    // 5. Calculate new cost
    final costMultPerlevel = config.costMultPerLevel;
    final int minCost = original.priceGold;
    final int maxCost = (minCost * (1 + costMultPerlevel * userLevel)).round();
    final int newCost = HelperFunctions.randomInt(minCost, maxCost);

    // Create new item with randomized values
    return Item(
      id: newId,
      name: original.name,
      description: _generateDescription(original.effects, newDurationMin),
      imageUrl: original.imageUrl,
      isPermanent: newDurationMin == 0,
      durationSeconds: newDurationSec,
      remainingSeconds: newDurationSec,
      priceGold: newCost,
      priceCrystal: original.priceCrystal,
      thresholdLevel: original.thresholdLevel,
      effects: newEffects,
      rarity: newRarity,
      level: original.level,
      isActivated: original.isActivated,
      acquiredDate: original.acquiredDate,
    );
  }
  
  static String _generateDescription(List<ItemEffect> effects, int durationMinutes) {
    String desc = "";
    for (var effect in effects) {
      switch (effect.type) {
        case EffectType.increaseXpGain:
          desc += "+${(effect.value * 100).toInt()}% XP";
          break;
        case EffectType.increaseGoldGain:
          desc += "+${(effect.value * 100).toInt()}% Gold";
          break;
        case EffectType.increaseCrystalDropChance:
          desc += "+${(effect.value * 100).toInt()}% Crystal";
          break;
        default:
          break;
      }
    }
    return desc;
  }
}

// ==================== 3. SHOP MANAGER (Simplified) ====================
class ShopManager {
  final Random _random = Random();
  
  // Generate shop items
  List<Item> generateShopItems() {
    final User user = UserService().currentUser;

    List<Item> shopItems = [];
    
    for (int i = 0; i < user.shopSize; i++) {
      // 1. Get a random item
      final originalItem = ItemDatabase.allItems[_random.nextInt(ItemDatabase.allItems.length)];
      
      // 2. Clone and randomize values
      Item randomizedItem = ItemDatabase.randomizeItem(originalItem, user.level, _getItemRarity());

      // 3. Generate shop item
      shopItems.add(randomizedItem);
    }
    
    return shopItems;
  }
  

  ItemRarity _getItemRarity(){
    Map<ItemRarity, double> rarities = 
      {ItemRarity.common: 0.4,
      ItemRarity.uncommon: 0.3,
      ItemRarity.rare: 0.1,
      ItemRarity.epic: 0.05,
      ItemRarity.legendary: 0.03,
      ItemRarity.mythic: 0.02};
    

    // Calculate cumulative probabilities
    double total = rarities.values.reduce((a, b) => a + b);
    double random = Random().nextDouble() * total;
    
    double cumulative = 0.0;
    for (var entry in rarities.entries) {
      cumulative += entry.value;
      if (random <= cumulative) {
        return entry.key;
      }
    }
    
    // Fallback (should never reach here if probabilities sum to 1.0)
    return ItemRarity.common;
  }
}