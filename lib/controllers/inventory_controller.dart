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

  // TimerCounter is counting every item duration tick
  int timerCounter = 0;
  // Save user inventory items info locally on every this seconds
  int userSaveInterval = 30;

  InventoryController(this._timerService);

  // Called after login happens
  void initialize(){
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
    UserService().saveCurrentUserData();
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
        UserService().saveCurrentUserData();

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
    UserService().saveCurrentUserData();
  }

  // ---------------SELL-----------------
  void sellItem(Item item){
    // No functions for now
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
      timerCounter++;
      if (timerCounter > userSaveInterval){
        timerCounter = 0;
        UserService().saveCurrentUserData();
      }

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

  bool checkInventoryLimitReached(){
    if (_inventoryItems.length >= _user.inventorySlot){
      return true;
    }
    return false;
  }
  

  void _checkAndStartTimer() {
    if (!_timerService.isRunning) {
      _timerService.startGlobalTimer();
    }
  }
}