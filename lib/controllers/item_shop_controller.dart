import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rpg_task_manager/controllers/custom_inventory_controller.dart';
import 'package:rpg_task_manager/controllers/inventory_controller.dart';
import 'package:rpg_task_manager/models/item/custom_item.dart';
import 'package:rpg_task_manager/models/item/item.dart';
import 'package:rpg_task_manager/services/item_service.dart';
import 'package:rpg_task_manager/services/user_service.dart';
import 'package:rpg_task_manager/storage/item_database.dart';
import 'package:path_provider/path_provider.dart';

class ItemShopController extends ChangeNotifier{

  late ShopManager shopManager;
  int shopSize = 3;
  late final InventoryController _inventoryController;
  late final CustomItemInventoryController _customInventoryController;

  // Normal items
  late List<Item> _items; 
  List<Item> get items => _items;

  // Custom items
  List<CustomItem> _customItems = [];
  List<CustomItem> get customItems => List.unmodifiable(_customItems);

  ItemShopController(InventoryController inventoryController, CustomItemInventoryController customController){
    _inventoryController = inventoryController;
    _customInventoryController = customController;
  }

  // Called after login
  void initialize(){
    shopManager = ShopManager();
    _items = shopManager.generateShopItems();
    loadCustomItems();
  }

  // ------------BUY-----------------
  String buyItem(Item item){
    if (_inventoryController.checkInventoryLimitReached()){
      return "Inventory limit (${UserService().currentUser.inventorySlot}) reached";
    }

    if (_items.remove(item)){
      _inventoryController.addItem(item);
      notifyListeners();
    }

    return "";
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
    _items = shopManager.generateShopItems();
    notifyListeners();
  }

  // -----------------------------CUSTOM ITEMS-------------------------------

  // Get most popular custom items (purchased at least once, top 2)
  List<CustomItem> get bestSellers {
    final sorted = [..._customItems]..sort((a, b) => b.purchaseCount.compareTo(a.purchaseCount));
    return sorted.where((e) => e.purchaseCount > 0).take(2).toList();
  }

  // Get IDs of best sellers for quick lookup
  Set<String> get bestSellerIds => bestSellers.map((e) => e.id).toSet();

  // Get remaining custom items (not in best sellers), sorted by newest first
  List<CustomItem> get otherCustomItems {
    final items = _customItems.where((e) => !bestSellerIds.contains(e.id)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  // Check if a custom item is new (created within last 7 days)
  bool isNewItem(CustomItem item) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return item.createdAt.isAfter(sevenDaysAgo);
  }

  // Save image permanently from picked file
  Future<String?> saveImagePermanently(File tempImageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final customItemsDir = Directory('${appDir.path}/custom_items');
      
      if (!await customItemsDir.exists()) {
        await customItemsDir.create(recursive: true);
      }
      
      final fileName = 'custom_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${customItemsDir.path}/$fileName';
      await tempImageFile.copy(savedPath);
      
      return savedPath;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  // Add a new custom item
  Future<void> addCustomItem({
    required String name,
    required int durationMinutes,
    required String description,
    required int priceGold,
    required File? imageFile,
  }) async {
    String? permanentImagePath;
    
    if (imageFile != null) {
      permanentImagePath = await saveImagePermanently(imageFile);
    }
    
    final newItem = CustomItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      durationMinutes: durationMinutes,
      description: description.trim(),
      priceGold: priceGold,
      createdAt: DateTime.now(),
      imagePath: permanentImagePath,
    );
    
    _customItems.add(newItem);

    await ItemService().addCustomItem(newItem);
    notifyListeners();
  }

  // Purchase a custom item (increment purchase count)
  void purchaseCustomItem(String itemId) {
    final index = _customItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _customItems[index] = _customItems[index].copyWith(
        purchaseCount: _customItems[index].purchaseCount + 1,
      );
      _customInventoryController.addCustomItem(_customItems[index]); 
      // _saveCustomItems();
      notifyListeners();
    }
  }

  // Get a custom item by ID
  CustomItem? getCustomItemById(String id) {
    try {
      return _customItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Delete a custom item and its associated image
  Future<void> deleteCustomItem(String itemId) async {
    final item = getCustomItemById(itemId);
    if (item != null) {
      // Delete the image file if it exists
      if (item.imagePath != null) {
        await _deleteImageFile(item.imagePath!);
      }
      
      _customItems.removeWhere((i) => i.id == itemId);

      await ItemService().deleteCustomItem(itemId);
      notifyListeners();
    }
  }

  // Delete all images created from custom items
  Future<void> deleteAllCustomItemImages() async {
    for (final item in _customItems) {
      if (item.imagePath != null) {
        await _deleteImageFile(item.imagePath!);
      }
    }
    debugPrint('All custom item images deleted from device storage');
  }

  // Delete a single image file
  Future<void> _deleteImageFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Deleted image: $path');
      }
    } catch (e) {
      debugPrint('Error deleting image $path: $e');
    }
  }

  // Delete the entire custom items directory
  Future<void> deleteAllCustomItemsAndImages() async {
    // First delete all image files
    await deleteAllCustomItemImages();
    
    // Clear the list
    _customItems.clear();

    await ItemService().deleteAllCustomItems();
    notifyListeners();
    
    // Delete the directory if empty
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final customItemsDir = Directory('${appDir.path}/custom_items');
      if (await customItemsDir.exists()) {
        await customItemsDir.delete();
        debugPrint('Deleted custom items directory');
      }
    } catch (e) {
      debugPrint('Error deleting custom items directory: $e');
    }
  }

  // Refresh/load from storage
  Future<void> loadCustomItems() async {
    _customItems = ItemService().getAllCustomItems();
    notifyListeners();
  }
}

// Extended CustomItem model with copyWith method
extension CustomItemExtension on CustomItem {
  CustomItem copyWith({
    String? id,
    String? name,
    int? durationMinutes,
    String? description,
    int? priceGold,
    DateTime? createdAt,
    String? imagePath,
    int? purchaseCount,
  }) {
    return CustomItem(
      id: id ?? this.id,
      name: name ?? this.name,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      description: description ?? this.description,
      priceGold: priceGold ?? this.priceGold,
      createdAt: createdAt ?? this.createdAt,
      imagePath: imagePath ?? this.imagePath,
      purchaseCount: purchaseCount ?? this.purchaseCount,
    );
  }
}