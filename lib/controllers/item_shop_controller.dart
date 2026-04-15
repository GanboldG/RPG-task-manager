import 'package:flutter/material.dart';
import 'package:rpg_task_manager/models/item/item.dart';
import 'package:rpg_task_manager/services/user_service.dart';
import 'package:rpg_task_manager/storage/item_database.dart';

class ItemShopController extends ChangeNotifier{

  late List<Item> _items; 
  List<Item> get items => _items;
  late ShopManager shopManager;


  ItemShopController(){
    shopManager = ShopManager();
    int shopSize = 3;
    _items = shopManager.generateShopItems(UserService().currentUser.level, shopSize);
  }

  // ------------ADD-----------------
  void addItem(Item item){

  }

  // ---------------DELETE-----------------
  void deleteItem(Item item){

  }

  // ------------REFRESH SHOP-----------------
  void refreshShop(){
    
  }
}