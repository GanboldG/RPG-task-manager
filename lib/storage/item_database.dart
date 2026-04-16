import 'dart:math';
import 'package:rpg_task_manager/models/item/item.dart';
import 'package:rpg_task_manager/models/item/item_rarity.dart';

// ==================== 1. ITEM DATABASE (Hardcoded Items) ====================
class ItemDatabase {
  static final Random _random = Random();

  // Pre-defined items - like a catalog
  static final List<Item> allItems = [
    // Common Items
    ItemFactory.createXpBoostItem(
      id: 1001,
      name: 'Minor XP Potion',
      xpBoostPercent: 0.10, // Base value (will be randomized)
      durationSeconds: 15,
      priceGold: 50,
      priceCrystal: 0,
      imageUrl: 'assets/images/items/minor_xp_potion.png',
      isPermanent: false,
      thresholdLevel: 0,
      rarity: ItemRarity.common,
      level: 1,
      isActivated: false,
      acquiredDate: DateTime.now(),
    ),
    
    ItemFactory.createGoldBoostItem(
      id: 1002,
      name: 'Gold Charm',
      goldBoostPercent: 0.08,
      durationSeconds: 20,
      priceGold: 40,
      priceCrystal: 0,
      imageUrl: 'assets/images/items/gold_charm.png',
      isPermanent: false,
      thresholdLevel: 0,
      rarity: ItemRarity.common,
      level: 1,
      isActivated: false,
      acquiredDate: DateTime.now(),
    ),
    
    ItemFactory.createCrystalChanceItem(
      id: 2003,
      name: 'Crystal Shard',
      crystalDropChance: 0.08,
      durationSeconds: 60,
      priceGold: 180,
      priceCrystal: 10,
      imageUrl: 'assets/images/items/crystal_shard.png',
      isPermanent: false,
      thresholdLevel: 5,
      rarity: ItemRarity.uncommon,    
      level: 1,
      isActivated: false,
      acquiredDate: DateTime.now(),
    ),
    
    // Rare Items
    // ItemFactory.createXpBoostItem(
    //   id: 3001,
    //   name: 'Tome of Knowledge',
    //   xpBoostPercent: 0.35,
    //   durationMinutes: 60,
    //   priceGold: 500,
    //   priceCrystal: 25,
    //   imageUrl: 'assets/images/items/rare/xp_tome.png',
    //   isPermanent: false,
    //   thresholdLevel: 10,
    //   rarity: ItemRarity.rare,
    // ),
    
    // // Epic Items
    // ItemFactory.createXpBoostItem(
    //   id: 4001,
    //   name: "Dragon's Essence",
    //   xpBoostPercent: 0.75,
    //   durationMinutes: 120,
    //   priceGold: 2000,
    //   priceCrystal: 100,
    //   imageUrl: 'assets/images/items/epic/dragon_essence.png',
    //   isPermanent: false,
    //   thresholdLevel: 20,
    //   rarity: ItemRarity.epic,
    // ),
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
  static Item randomizeItem(Item original, int userLevel) {
    // Generate new unique ID
    final newId = DateTime.now().millisecondsSinceEpoch + _random.nextInt(10000);
    
    // Randomize effect values (±30% variance)
    final randomizedEffects = original.effects.map((effect) {
      double variance = 0.7 + _random.nextDouble() * 0.6; // 70% to 130%
      double newValue = (effect.value * variance).clamp(0.01, 3.0);
      
      String? newSecondaryValue;
      if (effect.secondaryValue != null) {
        double secondary = double.parse(effect.secondaryValue!);
        double newSecondary = (secondary * variance).clamp(0.01, 1.0);
        newSecondaryValue = newSecondary.toString();
      }
      
      return ItemEffect(
        type: effect.type,
        value: newValue,
        secondaryValue: newSecondaryValue,
        isStackable: effect.isStackable,
        maxStack: effect.maxStack,
      );
    }).toList();
    
    // Randomize duration (±30%)
    int originalDurationMinutes = (original.durationSeconds / 60).round();

    late int newDurationMin;
    if (original.durationSeconds > 0) {
      double durationVariance = 0.7 + _random.nextDouble() * 0.6;
      newDurationMin = (originalDurationMinutes * durationVariance).round();
      newDurationMin = newDurationMin.clamp(5, 240); // Min 5 min, Max 4 hours
    }
    
    // Randomize price based on item strength
    double totalEffectValue = randomizedEffects.fold(0.0, (sum, e) => sum + e.value);
    int basePrice = (original.priceGold * (1 + totalEffectValue)).round();
    
    // Add level scaling and variance
    double priceVariance = 0.8 + _random.nextDouble() * 0.4;
    int newPriceGold = (basePrice * priceVariance).round();
    newPriceGold += (userLevel * 5); // Scale with level
    
    int newPriceCrystal = original.priceCrystal;
    if (newPriceCrystal > 0) {
      newPriceCrystal = (newPriceCrystal * priceVariance).round();
      newPriceCrystal += (userLevel ~/ 10);
    }
    
    // Create new item with randomized values
    return Item(
      id: newId,
      name: original.name,
      description: _generateDescription(randomizedEffects, newDurationMin),
      imageUrl: original.imageUrl,
      isPermanent: newDurationMin == 0,
      durationSeconds: newDurationMin * 60,
      priceGold: newPriceGold,
      priceCrystal: newPriceCrystal,
      thresholdLevel: original.thresholdLevel,
      effects: randomizedEffects,
      rarity: original.rarity,
      level: original.level,
      isActivated: original.isActivated,
      acquiredDate: original.acquiredDate
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
        default:
          break;
      }
    }
    // if (durationMinutes > 0) {
    //   desc += "Duration: $durationMinutes min";
    // } else {
    //   desc += "Permanent";
    // }
    return desc;
  }
}

// ==================== 3. SHOP MANAGER (Simplified) ====================
class ShopManager {
  final Random _random = Random();
  
  // Generate shop items
  List<Item> generateShopItems(int userLevel, int shopSize) {
    List<Item> shopItems = [];
    
    for (int i = 0; i < shopSize; i++) {
      // 1. Pick random rarity based on level
      final rarity = _selectRarityByLevel(userLevel);
      
      // 2. Get random item of that rarity from master list
      final availableItems = ItemDatabase.itemsByRarity[rarity]!
          .where((item) => item.thresholdLevel <= userLevel)
          .toList();
      
      if (availableItems.isEmpty) continue;
      
      final originalItem = availableItems[_random.nextInt(availableItems.length)];
      
      // 3. Clone and randomize values
      final randomizedItem = ItemDatabase.randomizeItem(originalItem, userLevel);
      
      shopItems.add(randomizedItem);
    }
    
    return shopItems;
  }
  
  ItemRarity _selectRarityByLevel(int userLevel) {
    // Same weighting logic as before
    if (userLevel < 5) {
      final rarities = [ItemRarity.common, ItemRarity.common, ItemRarity.common, ItemRarity.uncommon];
      return rarities[_random.nextInt(rarities.length)];
    } else if (userLevel < 10) {
      final rarities = [
        ItemRarity.common, ItemRarity.common, ItemRarity.uncommon, 
        ItemRarity.uncommon, ItemRarity.rare
      ];
      return rarities[_random.nextInt(rarities.length)];
    } else if (userLevel < 20) {
      final rarities = [
        ItemRarity.common, ItemRarity.uncommon, ItemRarity.uncommon, 
        ItemRarity.rare, ItemRarity.rare, ItemRarity.epic
      ];
      return rarities[_random.nextInt(rarities.length)];
    } else {
      final rarities = [
        ItemRarity.uncommon, ItemRarity.rare, ItemRarity.rare, 
        ItemRarity.epic, ItemRarity.epic, ItemRarity.legendary
      ];
      return rarities[_random.nextInt(rarities.length)];
    }
  }
}

// ==================== 4. USAGE ====================
    // final shopManager = ShopManager();
    // final user = User(level: 15); // Example user
    
    // // Generate shop items (refreshes every 24h)
    // List<Item> shopItems = shopManager.generateShopItems(user.level, 6);
    
    // // Each item has random values:
    // // - XP Potion might be 15-25% instead of base 10%
    // // - Duration might be 12-18 minutes instead of 15
    // // - Price adjusted based on new power level
    
    // for (var item in shopItems) {
    //   print('Item: ${item.name}');
    //   print('Effect: ${item.effects.first.value * 100}%');
    //   print('Duration: ${item.durationMinutes}min');
    //   print('Price: ${item.priceGold} gold');
    //   print('---');
    // }