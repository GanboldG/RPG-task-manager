import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rpg_task_manager/helpers/app_colors.dart';

part 'item_rarity.g.dart';

@HiveType(typeId: 5)
enum ItemRarity {
  @HiveField(0)
  common,

  @HiveField(1)
  uncommon,

  @HiveField(2)
  rare,

  @HiveField(3)
  epic,

  @HiveField(4)
  legendary,

  @HiveField(5)
  mythic;

  // Computed properties
  String get displayName {
    switch (this) {
      case ItemRarity.common:
        return 'Common';
      case ItemRarity.uncommon:
        return 'Uncommon';
      case ItemRarity.rare:
        return 'Rare';
      case ItemRarity.epic:
        return 'Epic';
      case ItemRarity.legendary:
        return 'Legendary';
      case ItemRarity.mythic:
        return 'Mythic';
    }
  }

  Color get color {
    switch (this) {
      case ItemRarity.common:
        return AppColors.rarityCommon;
      case ItemRarity.uncommon:
        return AppColors.rarityUncommon;
      case ItemRarity.rare:
        return AppColors.rarityRare;
      case ItemRarity.epic:
        return AppColors.rarityEpic;
      case ItemRarity.legendary:
        return AppColors.rarityLegendary;
      case ItemRarity.mythic:
        return AppColors.rarityMythic;
    }
  }

  // Additional useful properties
  // String get iconPath {
  //   switch (this) {
  //     case ItemRarity.common:
  //       return 'assets/icons/rarity/common.png';
  //     case ItemRarity.uncommon:
  //       return 'assets/icons/rarity/uncommon.png';
  //     case ItemRarity.rare:
  //       return 'assets/icons/rarity/rare.png';
  //     case ItemRarity.epic:
  //       return 'assets/icons/rarity/epic.png';
  //     case ItemRarity.legendary:
  //       return 'assets/icons/rarity/legendary.png';
  //     case ItemRarity.mythic:
  //       return 'assets/icons/rarity/mythic.png';
  //   }
  // }

  double get dropChance {
    switch (this) {
      case ItemRarity.common:
        return 0.5; // 50% drop chance
      case ItemRarity.uncommon:
        return 0.25; // 25% drop chance
      case ItemRarity.rare:
        return 0.12; // 12% drop chance
      case ItemRarity.epic:
        return 0.08; // 8% drop chance
      case ItemRarity.legendary:
        return 0.04; // 4% drop chance
      case ItemRarity.mythic:
        return 0.01; // 1% drop chance
    }
  }

  double get buyPriceMultiplier {
    switch (this) {
      case ItemRarity.common:
        return 1.0;
      case ItemRarity.uncommon:
        return 1.5;
      case ItemRarity.rare:
        return 2.0;
      case ItemRarity.epic:
        return 3.0;
      case ItemRarity.legendary:
        return 5.0;
      case ItemRarity.mythic:
        return 8.0;
    }
  }

  int get sellPriceMultiplier {
    switch (this) {
      case ItemRarity.common:
        return 1;
      case ItemRarity.uncommon:
        return 2;
      case ItemRarity.rare:
        return 4;
      case ItemRarity.epic:
        return 8;
      case ItemRarity.legendary:
        return 16;
      case ItemRarity.mythic:
        return 32;
    }
  }

  String get description {
    switch (this) {
      case ItemRarity.common:
        return 'Common items are frequently found and have basic stats.';
      case ItemRarity.uncommon:
        return 'Uncommon items are slightly better than common ones.';
      case ItemRarity.rare:
        return 'Rare items are hard to find and have good stats.';
      case ItemRarity.epic:
        return 'Epic items are very rare and have great stats.';
      case ItemRarity.legendary:
        return 'Legendary items are extremely rare with amazing stats.';
      case ItemRarity.mythic:
        return 'Mythic items are the rarest of all with god-like stats!';
    }
  }

  // Helper method to get rarity from string
  static ItemRarity fromString(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return ItemRarity.common;
      case 'uncommon':
        return ItemRarity.uncommon;
      case 'rare':
        return ItemRarity.rare;
      case 'epic':
        return ItemRarity.epic;
      case 'legendary':
        return ItemRarity.legendary;
      case 'mythic':
        return ItemRarity.mythic;
      default:
        return ItemRarity.common;
    }
  }

  // Get random rarity based on drop chances
  static ItemRarity getRandomRarity() {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    if (random < 1) return ItemRarity.mythic;
    if (random < 5) return ItemRarity.legendary;
    if (random < 13) return ItemRarity.epic;
    if (random < 25) return ItemRarity.rare;
    if (random < 50) return ItemRarity.uncommon;
    return ItemRarity.common;
  }

  // Get rarity tier (0-5 for sorting)
  int get tier {
    switch (this) {
      case ItemRarity.common:
        return 0;
      case ItemRarity.uncommon:
        return 1;
      case ItemRarity.rare:
        return 2;
      case ItemRarity.epic:
        return 3;
      case ItemRarity.legendary:
        return 4;
      case ItemRarity.mythic:
        return 5;
    }
  }

  // Get CSS/Hex color code (useful for web)
  String get hexColor {
    return color.value.toRadixString(16).padLeft(8, '0');
  }

  // Check if rarity is high tier (epic or above)
  bool get isHighTier {
    return this == ItemRarity.epic ||
        this == ItemRarity.legendary ||
        this == ItemRarity.mythic;
  }

  // Get emoji representation
  String get emoji {
    switch (this) {
      case ItemRarity.common:
        return '⬜';
      case ItemRarity.uncommon:
        return '🟩';
      case ItemRarity.rare:
        return '🟦';
      case ItemRarity.epic:
        return '🟪';
      case ItemRarity.legendary:
        return '🟧';
      case ItemRarity.mythic:
        return '🔴';
    }
  }
}