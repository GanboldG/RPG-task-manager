import 'dart:async';
import 'package:flutter/material.dart';
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

  bool get isActive => remainingSeconds > 0;
  
  int getRemainingDuration() => remainingSeconds;
  
  void addStack() {
    stackCount++;
    // Add extra duration when stacking (e.g., 1 hour per stack)
    remainingSeconds += 3600; // Or use custom item's base duration
  }
}

class CustomItemInventoryController extends ChangeNotifier {
  List<OwnedCustomItem> _ownedCustomItems = [];
  
  List<OwnedCustomItem> get ownedCustomItems => List.unmodifiable(_ownedCustomItems);
  
  // Timer update stream for real-time UI updates
  final _timerUpdateController = StreamController<void>.broadcast();
  Stream<void> get timerUpdateStream => _timerUpdateController.stream;

  CustomItemInventoryController() {
    _startGlobalTimer();
  }

  void _startGlobalTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      bool updated = false;
      for (var item in _ownedCustomItems) {
        if (item.isActive && !item.isPaused && item.remainingSeconds > 0) {
          item.remainingSeconds--;
          updated = true;
        }
      }
      if (updated) {
        _timerUpdateController.add(null);
        notifyListeners();
      }
    });
  }

  void addCustomItem(CustomItem item) {
    final existing = _ownedCustomItems.firstWhere(
      (i) => i.customItem.id == item.id,
      orElse: () => OwnedCustomItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customItem: item,
        remainingSeconds: 3600, // 1 hour default
        purchasedAt: DateTime.now(),
      ),
    );
    
    if (_ownedCustomItems.contains(existing)) {
      existing.addStack();
    } else {
      _ownedCustomItems.add(OwnedCustomItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customItem: item,
        remainingSeconds: 3600,
        purchasedAt: DateTime.now(),
      ));
    }
    notifyListeners();
  }

  void addStackToCustomItem(String ownedItemId) {
    final index = _ownedCustomItems.indexWhere((i) => i.id == ownedItemId);
    if (index != -1) {
      _ownedCustomItems[index].addStack();
      notifyListeners();
    }
  }

  void pauseCustomItem(String ownedItemId) {
    final index = _ownedCustomItems.indexWhere((i) => i.id == ownedItemId);
    if (index != -1) {
      _ownedCustomItems[index].isPaused = true;
      notifyListeners();
    }
  }

  void resumeCustomItem(String ownedItemId) {
    final index = _ownedCustomItems.indexWhere((i) => i.id == ownedItemId);
    if (index != -1) {
      _ownedCustomItems[index].isPaused = false;
      notifyListeners();
    }
  }

  void deleteCustomItem(String ownedItemId) {
    _ownedCustomItems.removeWhere((i) => i.id == ownedItemId);
    notifyListeners();
  }

  @override
  void dispose() {
    _timerUpdateController.close();
    super.dispose();
  }
}