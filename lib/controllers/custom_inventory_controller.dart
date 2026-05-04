import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rpg_task_manager/models/item/custom_item.dart';
import 'package:rpg_task_manager/models/item/owned_custom_item.dart';
import 'package:rpg_task_manager/models/user.dart';
import 'package:rpg_task_manager/services/user_service.dart';

class CustomItemInventoryController extends ChangeNotifier {
  late User _user;

  late List<OwnedCustomItem> _ownedCustomItems;
  List<OwnedCustomItem> get ownedCustomItems => List.unmodifiable(_ownedCustomItems);

  late List<OwnedCustomItem> _activatedCustomItems;
  List<OwnedCustomItem> get activatedCustomItems => List.unmodifiable(_activatedCustomItems);
  
  // Timer update stream for real-time UI updates
  final _timerUpdateController = StreamController<void>.broadcast();
  Stream<void> get timerUpdateStream => _timerUpdateController.stream;

  // Save user data on every 30 tick
  int timerCounter = 0;
  int userSaveInterval = 30;

  // Called after login
  void initialize(){
     _user = UserService().currentUser;
    _activatedCustomItems = _user.activatedCustomItems;
    _ownedCustomItems = _user.ownedCustomItems;

    _startGlobalTimer();
  }

  void _startGlobalTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      bool updated = false;
      List<OwnedCustomItem> expiredItems = [];

      for (var item in _ownedCustomItems) {
        if (item.isActive && !item.isPaused && item.remainingSeconds > 0) {
          item.remainingSeconds--;
          updated = true;

          if (item.remainingSeconds <= 0) {expiredItems.add(item);}
        }
      }
      if (updated) {
        _timerUpdateController.add(null);

        timerCounter++;
        if (timerCounter > userSaveInterval){
          timerCounter = 0;
          UserService().saveCurrentUserData();
        }

        notifyListeners();
      }

      for (var item in expiredItems){
        deleteCustomItem(item.id);
      }
    });
  }

  void addCustomItem(CustomItem item) {
    final existing = _ownedCustomItems.firstWhere(
      (i) => i.customItem.id == item.id,
      orElse: () => OwnedCustomItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customItem: item,
        remainingSeconds: item.durationMinutes * 60,
        purchasedAt: DateTime.now(),
      ),
    );
    
    if (_ownedCustomItems.contains(existing)) {
      existing.addStack();
    } else {
      _ownedCustomItems.add(OwnedCustomItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customItem: item,
        remainingSeconds: item.durationMinutes * 60,
        purchasedAt: DateTime.now(),
      ));
    }

    notifyListeners();
    UserService().saveCurrentUserData();
  }

  void addStackToCustomItem(String ownedItemId) {
    final index = _ownedCustomItems.indexWhere((i) => i.id == ownedItemId);
    if (index != -1) {
      _ownedCustomItems[index].addStack();

      notifyListeners();
      UserService().saveCurrentUserData();
    }
  }

  void pauseCustomItem(String ownedItemId) {
    final index = _ownedCustomItems.indexWhere((i) => i.id == ownedItemId);
    if (index != -1) {
      _ownedCustomItems[index].isPaused = true;

      notifyListeners();
      UserService().saveCurrentUserData();
    }
  }

  void resumeCustomItem(String ownedItemId) {
    final index = _ownedCustomItems.indexWhere((i) => i.id == ownedItemId);
    if (index != -1) {
      _ownedCustomItems[index].isPaused = false;

      notifyListeners();
      UserService().saveCurrentUserData();
    }
  }

  void deleteCustomItem(String ownedItemId) {
    _ownedCustomItems.removeWhere((i) => i.id == ownedItemId);
    _activatedCustomItems.removeWhere((i) => i.id == ownedItemId);

    notifyListeners();
    UserService().saveCurrentUserData();
  }

  @override
  void dispose() {
    _timerUpdateController.close();
    super.dispose();
  }
}