import 'package:hive_flutter/adapters.dart';
import 'package:rpg_task_manager/models/item/effect_type.dart';

part 'item_effect.g.dart';

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
  
  
  // ================= FIRESTORE TO MAP =================
  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'value': value,
      'secondaryValue': secondaryValue,
      'isStackable': isStackable,
      'maxStack': maxStack,
    };
  }

  // ================= FIRESTORE FROM MAP =================
  factory ItemEffect.fromMap(Map<String, dynamic> map) {
    return ItemEffect(
      type: EffectType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => EffectType.values.first,
      ),
      value: (map['value'] ?? 0).toDouble(),
      secondaryValue: map['secondaryValue'],
      isStackable: map['isStackable'] ?? false,
      maxStack: map['maxStack'],
    );
  }

  // Helper to get formatted percentage
  String get formattedValue => '${(value * 100).toInt()}%';
}