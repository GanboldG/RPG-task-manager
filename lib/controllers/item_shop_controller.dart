import 'package:flutter/material.dart';
import 'package:rpg_task_manager/models/item/item.dart';

class ItemShopController extends ChangeNotifier{

  late List<Item> _items; 
  List<Item> get items => _items;


  ItemShopController(){
    _items = [];
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