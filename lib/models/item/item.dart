import 'package:hive/hive.dart';
import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/models/configs/item_rarity_config.dart';
import 'package:rpg_task_manager/models/item/effect_type.dart';
import 'package:rpg_task_manager/models/item/item_effect.dart';
import 'package:rpg_task_manager/models/item/item_rarity.dart';

part 'item.g.dart';

// ==================== EFFECT BASE CLASS ====================
@HiveType(typeId: 4)
class Item {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;

  @HiveField(2)
  String description;
  
  @HiveField(3)
  String imageUrl;
  
  @HiveField(4)
  bool isPermanent;

  @HiveField(5)
  int durationSeconds;
  
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

  @HiveField(11)
  int level;

  @HiveField(12)
  DateTime acquiredDate;

  @HiveField(13)
  int remainingSeconds;

  @HiveField(14)
  bool isActivated;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.isPermanent,
    required this.durationSeconds,
    required this.priceGold,
    required this.priceCrystal,
    this.thresholdLevel = 0,
    this.effects = const [],
    required this.rarity,
    required this.level,
    required this.acquiredDate,
    required this.remainingSeconds,
    required this.isActivated,
  });

  Item copyWith({
    String? id,
    String? name,
    String? description,
    int? level,
    int? baseDurationSeconds,
    int? remainingSeconds,
    bool? isActivated,
    DateTime? acquiredDate,
    String? imageUrl,
    int? priceGold,
    bool? isPermanent,
    ItemRarity? rarity,
    int? priceCrystal,
    ItemRarityConfig? itemConfig
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      level: level ?? this.level,
      durationSeconds: baseDurationSeconds ?? this.durationSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isActivated: isActivated ?? this.isActivated,
      acquiredDate: acquiredDate ?? this.acquiredDate,
      imageUrl: imageUrl ?? this.imageUrl,
      priceGold: priceGold ?? this.priceGold,
      isPermanent: isPermanent ?? this.isPermanent,
      rarity: rarity ?? this.rarity,
      priceCrystal: priceCrystal ?? this.priceCrystal,
    );
  }

  String getFormattedBaseDuration() {
    return HelperFunctions.formatDuration(durationSeconds);
  }

  String getFormattedRemainingDuration() {
    return HelperFunctions.formatDuration(remainingSeconds);
  }

  String generateDescription(){
    String desc = "";
    for (var effect in effects) {
      switch (effect.type) {
        case EffectType.increaseXpGain:
          desc += "+${(effect.value * 100).toInt()}% XP ";
          break;
        case EffectType.increaseGoldGain:
          desc += "+${(effect.value * 100).toInt()}% Gold";
          break;
        case EffectType.increaseCrystalDropChance:
          desc += "+${(effect.value * 100).toInt()}% Crystal ";
          break;
        default:
          break;
      }
    }
    return desc;
  }
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
    required String id,
    required String name,
    required double xpBoostPercent, // 20% boost
    required int durationSeconds,
    required int priceGold,
    required int priceCrystal,
    required String imageUrl,
    required bool isPermanent,
    required int thresholdLevel,
    required ItemRarity rarity,
    required int level,
    required DateTime acquiredDate,
    required bool isActivated,
    required ItemRarityConfig itemConfig,
  }) {
    return Item(
      id: id,
      name: name,
      description: 'Increases XP gain by ${(xpBoostPercent * 100).toInt()}% for ${(durationSeconds / 60).toStringAsFixed(1)} minutes',
      imageUrl: imageUrl,
      isPermanent: isPermanent,
      durationSeconds: durationSeconds,
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
      level: level,
      acquiredDate: acquiredDate,
      remainingSeconds: durationSeconds,
      isActivated : isActivated,
    );
  }

   static Item createGoldBoostItem({
    required String id,
    required String name,
    required double goldBoostPercent, // 20% boost
    required int durationSeconds,
    required int priceGold,
    required int priceCrystal,
    required String imageUrl,
    required bool isPermanent,
    required int thresholdLevel,
    required ItemRarity rarity,
    required int level,
    required DateTime acquiredDate,
    required bool isActivated,
    required ItemRarityConfig itemConfig,
  }) {
    return Item(
      id: id,
      name: name,
      description: 'Increases gold gain by ${(goldBoostPercent * 100).toInt()}% for ${(durationSeconds / 60).toStringAsFixed(1)} minutes',
      imageUrl: imageUrl,
      isPermanent: isPermanent,
      durationSeconds: durationSeconds,
      priceGold: priceGold,
      priceCrystal: priceCrystal,
      thresholdLevel: thresholdLevel,
      effects: [
        ItemEffect(
          type: EffectType.increaseGoldGain,
          value: goldBoostPercent,
          isStackable: true,
          maxStack: 2, // Max 200% boost
        ),
      ],
      rarity: rarity,
      level: level,
      acquiredDate: acquiredDate,
      remainingSeconds: durationSeconds,
      isActivated : isActivated,
    );
  }
  
  // Lucky Crystal (increases crystal drop chance)
  static Item createCrystalChanceItem({
    required String id,
    required double crystalDropChance, // 15% increase
    required int durationSeconds,
    required int priceGold,
    required int priceCrystal ,
    required String imageUrl,
    required String name,
    required bool isPermanent,
    required int thresholdLevel,
    required ItemRarity rarity,
    required int level,
    required DateTime acquiredDate,
    required bool isActivated,
    required ItemRarityConfig itemConfig,
  }) {
    return Item(
      id: id,
      name: name,
      description: 'Increases Crystal drop chance by ${(crystalDropChance * 100).toInt()}%',
      imageUrl: imageUrl,
      isPermanent: isPermanent,
      durationSeconds: durationSeconds,
      priceGold: priceGold,
      priceCrystal: priceCrystal,
      thresholdLevel: thresholdLevel,
      effects: [
        ItemEffect(
          type: EffectType.increaseCrystalDropChance,
          value: crystalDropChance,
          isStackable: false, // Can't stack luck
        ),
      ],
      rarity: rarity,
      level: level,
      acquiredDate: acquiredDate,
      remainingSeconds: durationSeconds,
      isActivated : isActivated,
    );
  }
}