import 'dart:async';
import 'package:rpg_task_manager/models/item/custom_item.dart';

class OwnedCustomItem {
  final String id;
  final CustomItem customItem;
  int stackCount;
  int remainingSeconds;
  bool isPaused;
  DateTime purchasedAt;
  Timer? timer;

  OwnedCustomItem({
    required this.id,
    required this.customItem,
    this.stackCount = 1,
    this.remainingSeconds = 0,
    this.isPaused = false,
    required this.purchasedAt,
  });

  // ================= FIRESTORE TO MAP =================
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customItem': customItem.toMap(),
      'stackCount': stackCount,
      'remainingSeconds': remainingSeconds,
      'isPaused': isPaused,
      'purchasedAt': purchasedAt,
    };
  }

  // ================= FIRESTORE FROM MAP =================
  factory OwnedCustomItem.fromMap(Map<String, dynamic> map) {
    return OwnedCustomItem(
      id: map['id'] ?? '',
      customItem: CustomItem.fromMap(map['customItem']),
      stackCount: map['stackCount'] ?? 0,
      remainingSeconds: map['remainingSeconds'] ?? 0,
      isPaused: map['isPaused'] ?? false,
      purchasedAt: map['purchasedAt']?.toDate(),
    );
  }

  bool get isActive => remainingSeconds > 0;
  
  int getRemainingDuration() => remainingSeconds;
  
  void addStack() {
    stackCount++;
    // Add extra duration when stacking (e.g., 1 hour per stack)
    remainingSeconds += 3600; // Or use custom item's base duration
  }
}