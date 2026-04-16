import 'package:flutter/material.dart';
import 'package:rpg_task_manager/models/item/item.dart';
import 'package:rpg_task_manager/models/user.dart';
import 'package:rpg_task_manager/services/user_service.dart';

class InventoryController extends ChangeNotifier{

  late User _user;
  User get user => _user;
  late List<Item> _inventoryItems;
  List<Item> get inventoryItems => _inventoryItems;
  late List<Item> _activatedItems;
  List<Item> get activatedItems => _activatedItems;

  InventoryController(){
    _user = UserService().currentUser;
    _inventoryItems = _user.ownedItems;
    _activatedItems = _user.equippedItems;
  }

  // ------------ADD-----------------
  void addItem(Item item){
    _inventoryItems.add(item);

    notifyListeners();
  }

  // ---------------ACTIVATE----------------
  void activateItem(Item item){
    if (_inventoryItems.contains(item)){
      _inventoryItems.remove(item);
      _activatedItems.add(item);

      notifyListeners();
    }
    else {
      // User doesn't own this item
    }
  }

  // ---------------DELETE-----------------
  void deleteItem(Item item){
    _inventoryItems.remove(item);
    _activatedItems.remove(item);

    notifyListeners();
  }

  // ---------------SELL-----------------
  void sellItem(Item item){
    notifyListeners();
  }
}