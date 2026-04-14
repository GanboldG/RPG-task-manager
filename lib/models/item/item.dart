import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rpg_task_manager/models/item/item_rarity.dart';
import 'package:rpg_task_manager/services/task_id_counter.dart';
import 'package:rpg_task_manager/services/user_id_counter.dart';

part 'item.g.dart';

// ==================== EFFECT BASE CLASS ====================
@HiveType(typeId: 4)
class Item {
  @HiveField(0)
  int id;
  
  @HiveField(1)
  String name;

  @HiveField(2)
  String description;
  
  @HiveField(3)
  String imageUrl;
  
  @HiveField(4)
  bool isPermanent;

  @HiveField(5)
  int durationMinutes;
  
  @HiveField(6)
  int priceGold;
  
  @HiveField(7)
  int priceCrystal;

  @HiveField(8)
  int thresholdLevel;
  
  @HiveField(9)
  List<ItemEffect> effects; // List of effects this item provides

  @HiveField(10)
  ItemRarity rarity;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.isPermanent,
    this.durationMinutes = 5,
    required this.priceGold,
    required this.priceCrystal,
    this.thresholdLevel = 0,
    this.effects = const [],
    required this.rarity,
  });
}

// ==================== EFFECT TYPES ====================
@HiveType(typeId: 10)
enum EffectType {
  @HiveField(0)
  increaseXpGain,
  
  @HiveField(1)
  increaseGoldGain,
  
  @HiveField(2)
  increaseCrystalDropChance,
  
  @HiveField(3)
  reduceGoldGain, // Trade-off effect
  
  @HiveField(4)
  reduceCustomShopCost,
  
  @HiveField(5)
  reduceBaseShopCost,
  
  @HiveField(6)
  rerollBaseShop,
  
  @HiveField(7)
  increaseItemRarity,
  
  @HiveField(8)
  reduceTaskDuration,
  
  @HiveField(9)
  increaseTaskReward,
  
  @HiveField(10)
  passiveIncomeBonus,

  @HiveField(11)
  reduceXpGain,
}

// ==================== EFFECT MODEL ====================
@HiveType(typeId: 11)
class ItemEffect {
  @HiveField(0)
  EffectType type;
  
  @HiveField(1)
  double value; // Percentage as decimal (0.1 = 10%)
  
  @HiveField(2)
  String? secondaryValue; // For trade-off effects (e.g., -5% gold)
  
  @HiveField(3)
  bool isStackable; // Can multiple items with same effect stack?
  
  @HiveField(4)
  int? maxStack; // Maximum stack percentage

  ItemEffect({
    required this.type,
    required this.value,
    this.secondaryValue,
    this.isStackable = true,
    this.maxStack,
  });
  
  // Helper to get formatted percentage
  String get formattedValue => '${(value * 100).toInt()}%';
}

// ==================== HELPER EXTENSIONS ====================
extension ItemEffectExtensions on List<ItemEffect> {
  // Get total percentage for a specific effect type
  double getTotalPercentage(EffectType type) {
    return where((e) => e.type == type)
        .fold(0.0, (sum, e) => sum + e.value)
        .clamp(-1.0, 5.0); // Max 500% increase, 100% decrease
  }
  
  // Check if has specific effect
  bool hasEffect(EffectType type) {
    return any((e) => e.type == type);
  }
}

// ==================== FACTORY METHODS FOR COMMON ITEMS ====================
class ItemFactory {
  // XP Boost Item
  static Item createXpBoostItem({
    required int id,
    required String name,
    required double xpBoostPercent, // 20% boost
    required int durationMinutes,
    required int priceGold,
    required int priceCrystal,
    required String imageUrl,
    required bool isPermanent,
    required int thresholdLevel,
    required ItemRarity rarity,
  }) {
    return Item(
      id: id,
      name: name,
      description: 'Increases XP gain by ${(xpBoostPercent * 100).toInt()}% for $durationMinutes minutes',
      imageUrl: imageUrl,
      isPermanent: isPermanent,
      durationMinutes: durationMinutes,
      priceGold: priceGold,
      priceCrystal: priceCrystal,
      thresholdLevel: thresholdLevel,
      effects: [
        ItemEffect(
          type: EffectType.increaseXpGain,
          value: xpBoostPercent,
          isStackable: true,
          maxStack: 2, // Max 200% boost
        ),
      ],
      rarity: rarity,
    );
  }
  
  // Lucky Crystal (increases crystal drop chance)
  static Item createCrystalChanceItem({
    required int id,
    required double dropChance, // 15% increase
    required int durationMinutes,
    required int priceGold,
    required int priceCrystal ,
    required String imageUrl,
    required String name,
    required bool isPermanent,
    required int thresholdLevel,
    required ItemRarity rarity,
  }) {
    return Item(
      id: id,
      name: name,
      description: 'Increases Crystal drop chance by ${(dropChance * 100).toInt()}%',
      imageUrl: imageUrl,
      isPermanent: isPermanent,
      durationMinutes: durationMinutes,
      priceGold: priceGold,
      priceCrystal: priceCrystal,
      thresholdLevel: thresholdLevel,
      effects: [
        ItemEffect(
          type: EffectType.increaseCrystalDropChance,
          value: dropChance,
          isStackable: false, // Can't stack luck
        ),
      ],
      rarity: rarity,
    );
  }
  
  // // Trade-off Amulet (more XP, less gold)
  // static Item createTradeOffAmulet({
  //   required int id,
  //   double xpIncrease = 0.5, // 50% more XP
  //   double goldDecrease = 0.25, // 25% less gold
  //   int priceGold = 500,
  // }) {
  //   return Item(
  //     id: id,
  //     name: 'Amulet of Greed',
  //     description: '+${(xpIncrease * 100).toInt()}% XP, -${(goldDecrease * 100).toInt()}% Gold',
  //     icon: Icon(Icons.auto_mode_outlined),
  //     isPermanent: true,
  //     priceGold: priceGold,
  //     priceCrystal: 0,
  //     thresholdLevel: 20,
  //     effects: [
  //       ItemEffect(
  //         type: EffectType.increaseGoldGain,
  //         value: xpIncrease,
  //         secondaryValue: goldDecrease.toString(),
  //         isStackable: false,
  //       ),
  //     ],
  //     rarity: ItemRarity.common,
  //   );
  // }
  
  // // Permanent Membership Card (reduces shop prices)
  // static Item createMembershipCard({
  //   required int id,
  //   double discount = 0.1, // 10% discount
  //   int priceCrystal = 200,
  // }) {
  //   return Item(
  //     id: id,
  //     name: 'Premium Membership',
  //     description: 'Permanently reduces all shop prices by ${(discount * 100).toInt()}%',
  //     icon: Icon(Icons.card_giftcard),
  //     isPermanent: true,
  //     priceGold: 0,
  //     priceCrystal: priceCrystal,
  //     thresholdLevel: 15,
  //     effects: [
  //       ItemEffect(
  //         type: EffectType.reduceBaseShopCost,
  //         value: discount,
  //         isStackable: false, // Membership doesn't stack
  //       ),
  //       ItemEffect(
  //         type: EffectType.reduceCustomShopCost,
  //         value: discount,
  //         isStackable: false,
  //       ),
  //     ],
  //     rarity: ItemRarity.common,
  //   );
  // }
}