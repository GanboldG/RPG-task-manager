import 'package:hive/hive.dart';
import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/models/item/custom_item.dart';
import 'package:rpg_task_manager/models/item/item.dart';

class ItemService {
  // Singleton instance
  static final ItemService _instance = ItemService._internal();
  
  // Private constructor
  ItemService._internal();
  
  // Factory constructor to return the same instance
  factory ItemService() => _instance;
  
  final Box<Item> _shopItemsBox = Hive.box<Item>('shop_items');
  final Box<CustomItem> _customShopItemsBox = Hive.box<CustomItem>('custom_shop_items');


  // ============ ITEM CRUD Operations ============
  
  // Create / Add Item
  Future<void> addItem(Item item) async {
    await _shopItemsBox.put(item.id, item);
  }
  
  // Add multiple items
  Future<void> addItems(List<Item> items) async {
    final Map<String, Item> itemsMap = {
      for (var item in items) item.id: item
    };
    await _shopItemsBox.putAll(itemsMap);
  }
  
  // Read / Get Item by ID
  Item? getItem(String id) {
    return _shopItemsBox.get(id);
  }
  
  // Get all items
  List<Item> getAllItems() {
    return _shopItemsBox.values.toList();
  }
  
  // Update Item
  Future<void> updateItem(Item updatedItem) async {
    await _shopItemsBox.put(updatedItem.id, updatedItem);
  }
  
  // Delete Item
  Future<void> deleteItem(String id) async {
    await _shopItemsBox.delete(id);
  }
  
  // Delete multiple items
  Future<void> deleteItems(List<String> ids) async {
    await _shopItemsBox.deleteAll(ids);
  }
  
  // Delete all items
  Future<void> deleteAllItems() async {
    await _shopItemsBox.clear();
  }
  
  // Check if item exists
  bool itemExists(String id) {
    return _shopItemsBox.containsKey(id);
  }
  
  // Get item count
  int get itemCount => _shopItemsBox.length;
  


  // ============ CUSTOM ITEM CRUD Operations ============
  
  // Create / Add Custom Item
  Future<void> addCustomItem(CustomItem customItem) async {
    print("Trying to add custom item");
    await _customShopItemsBox.put(customItem.id, customItem);
  }
  
  // Add multiple custom items
  Future<void> addCustomItems(List<CustomItem> customItems) async {
    final Map<String, CustomItem> itemsMap = {
      for (var item in customItems) item.id: item
    };
    await _customShopItemsBox.putAll(itemsMap);
  }
  
  // Read / Get Custom Item by ID
  CustomItem? getCustomItem(String id) {
    return _customShopItemsBox.get(id);
  }
  
  // Get all custom items
  List<CustomItem> getAllCustomItems() {
    return _customShopItemsBox.values.toList();
  }
  
  // Update Custom Item
  Future<void> updateCustomItem(CustomItem updatedCustomItem) async {
    await _customShopItemsBox.put(updatedCustomItem.id, updatedCustomItem);
  }
  
  // Delete Custom Item
  Future<void> deleteCustomItem(String id) async {
    final item = _customShopItemsBox.get(id);
    
    // If the item has an image, you might want to delete it from disk
    if (item != null && item.imagePath != null) {
      await HelperFunctions.deleteImage(item.imagePath!);
    }
    
    await _customShopItemsBox.delete(id);
  }

  
  // Delete multiple custom items
  Future<void> deleteCustomItems(List<String> ids) async {
    await _customShopItemsBox.deleteAll(ids);
  }
  
  // Delete all custom items
  Future<void> deleteAllCustomItems() async {
    await _customShopItemsBox.clear();
  }
  
  // Check if custom item exists
  bool customItemExists(String id) {
    return _customShopItemsBox.containsKey(id);
  }
  
  // Get custom item count
  int get customItemCount => _customShopItemsBox.length;
}