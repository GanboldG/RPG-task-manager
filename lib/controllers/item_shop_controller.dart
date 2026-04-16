import 'package:flutter/material.dart';
import 'package:rpg_task_manager/controllers/inventory_controller.dart';
import 'package:rpg_task_manager/models/item/item.dart';
import 'package:rpg_task_manager/services/user_service.dart';
import 'package:rpg_task_manager/storage/item_database.dart';

class ItemShopController extends ChangeNotifier{

  late List<Item> _items; 
  List<Item> get items => _items;
  late ShopManager shopManager;
  int shopSize = 3;
  late final InventoryController _inventoryController;

  ItemShopController(InventoryController inventoryController){
    shopManager = ShopManager();
    _items = shopManager.generateShopItems(UserService().currentUser.level, shopSize);
    _inventoryController = inventoryController;
  }

  // ------------BUY-----------------
  void buyItem(Item item){
    if (_items.remove(item)){
      _inventoryController.addItem(item);
      notifyListeners();
    }
  }

  // ---------------DELETE-----------------
  void removeItem(Item item){
    if (_items.contains(item)){
      _items.remove(item);
      notifyListeners();
    }  
  }

  // ------------REFRESH SHOP-----------------
  void refreshShop(){
    _items = shopManager.generateShopItems(UserService().currentUser.level, shopSize);
    notifyListeners();
  }
}