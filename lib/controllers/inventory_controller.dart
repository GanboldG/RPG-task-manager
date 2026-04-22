import 'package:flutter/material.dart';
import 'package:rpg_task_manager/models/item/item.dart';
import 'package:rpg_task_manager/models/user.dart';
import 'package:rpg_task_manager/services/timer/item_timer_service.dart';
import 'package:rpg_task_manager/services/user_service.dart';

class InventoryController extends ChangeNotifier{

  final ItemTimerService _timerService;
  late User _user;

  // "Normal" items
  late List<Item> _inventoryItems;
  List<Item> get inventoryItems => _inventoryItems;

  late List<Item> _activatedItems;
  List<Item> get activatedItems => _activatedItems;

  InventoryController(this._timerService){
    _user = UserService().currentUser;
    _inventoryItems = _user.ownedItems;
    _activatedItems = _user.equippedItems;

    // ------------TIMER STUFF----------
    // Connect timer service to update items
    _timerService.onTick = _decrementAllActiveItems;
    // Start timer if there are active items
    _checkAndStartTimer();
  }

  // ------------ADD-----------------
  void addItem(Item item){
    _inventoryItems.add(item);

    notifyListeners();
  }

  // ---------------ACTIVATE----------------
  void equipItem(Item item) {
    debugPrint("${item.generateDescription()} ${item.getFormattedBaseDuration()}");

    if (_user.ownedItems.contains(item)) {
      if (_user.equippedItems.length < _user.maxEquippedItemAmount){
        _user.equippedItems.add(item);
        _user.ownedItems.remove(item);
        item.isActivated = true;
        notifyListeners();

        // Try to start the timer
        _checkAndStartTimer();
      }
    }
  }

  // ---------------DELETE-----------------
  void deleteItem(Item item){
    debugPrint(_inventoryItems.remove(item).toString());
    _activatedItems.remove(item);

    notifyListeners();
  }

  // ---------------SELL-----------------
  void sellItem(Item item){
    notifyListeners();
  }

  // ---------------TIMER RELATED METHODS-----------------
   void _decrementAllActiveItems() {
    bool hasChanges = false;
    
    List<Item> removingItems = [];

    for (int i = 0; i < _activatedItems.length; i++) {
      final item = _activatedItems[i];
      if (item.remainingSeconds > 0) {
        // Decrement remaining time
        _activatedItems[i].remainingSeconds--;
        hasChanges = true;
        
        // If item expired, deactivate it
        if (_activatedItems[i].remainingSeconds <= 0) {
          removingItems.add(item);
        }
      }
    }
    
    if (hasChanges) {
      notifyListeners();
    }
    
    // Remove expired items
    for (Item item in removingItems){
      deleteItem(item);
    }

    // Stop timer if no active items left
    if (_activatedItems.isEmpty) {
      _timerService.stopGlobalTimer();
    }
  }
  

  void _checkAndStartTimer() {
    if (!_timerService.isRunning) {
      _timerService.startGlobalTimer();
    }
  }
}