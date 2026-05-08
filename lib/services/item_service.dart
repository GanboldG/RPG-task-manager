import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/models/item/custom_item.dart';
import 'package:rpg_task_manager/models/item/item.dart';
import 'package:rpg_task_manager/services/cloudinary_service.dart';

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
  

  // Delete Custom Item from storage / cloudinary
  Future<void> deleteCustomItem(String id) async {
    final item = _customShopItemsBox.get(id);
    
    // If the item has an image, you might want to delete it from disk
    if (item != null) {
      if (item.imagePath != null){
        await HelperFunctions.deleteImage(item.imagePath!);
      }
      deleteImageFromCloudinary(item);
    }
    
    await _customShopItemsBox.delete(id);
  }


  // Delete all custom items
  Future<void> deleteAllCustomItems(List<CustomItem> customItems) async {
    for (CustomItem item in customItems){
      if (item.imagePath != null){
        HelperFunctions.deleteImage(item.imagePath!);
      }
      deleteImageFromCloudinary(item);
    }

    await _customShopItemsBox.clear();
  }
  
  // Delete custom items image from cloudinary 
  Future<void> deleteImageFromCloudinary(CustomItem item) async{
    // Skips attempt at deleting if offline
    if (!await HelperFunctions.hasInternet()){
      return;
    }

    try{
      if (item.imagePublicId != null){
        final deleted = await CloudinaryService.deleteImageByPublicId(item.imagePublicId!);
        print("(Cloudinary) Deleted old image: $deleted");
      }
    } catch (e){
      print("Exception $e when trying to delete image from Cloudinary");
    }
  }

  // Check if custom item exists
  bool customItemExists(String id) {
    return _customShopItemsBox.containsKey(id);
  }
  
  // Get custom item count
  int get customItemCount => _customShopItemsBox.length;


  // ------------------------------- FIRESTORE methods ------------------------------------
  // Future<void> uploadCustomItemsToFirestore(List<CustomItem> items) async {
  //   final currentUser = FirebaseAuth.instance.currentUser;
  //   if (currentUser == null) return;

  //   final uid = currentUser.uid;

  //   try {
  //     final collectionRef = FirebaseFirestore.instance
  //         .collection("users")
  //         .doc(uid)
  //         .collection("custom_items");

  //     // ---------------- DELETE ALL EXISTING ----------------
  //     final existingSnapshot = await collectionRef.get();

  //     final deleteBatch = FirebaseFirestore.instance.batch();

  //     for (final doc in existingSnapshot.docs) {
  //       deleteBatch.delete(doc.reference);
  //     }

  //     await deleteBatch.commit();

  //     // ---------------- UPLOAD NEW ITEMS ----------------
  //     final uploadBatch = FirebaseFirestore.instance.batch();

  //     for (final item in items) {
  //       // 1) Upload image if exists
  //       if (item.imagePath != null) {
  //         final imageUrls = await CloudinaryService
  //             .uploadCustomItemImage(File(item.imagePath!));

  //         if (imageUrls != null) {
  //           item.imageUrl = imageUrls['url'];
  //           item.imagePublicId = imageUrls['publicId'];
  //         }
  //       }

  //       final docRef = collectionRef.doc(item.id);
  //       uploadBatch.set(docRef, item.toMap());
  //     }

  //     await uploadBatch.commit();
  //   } catch (e) {
  //     print("(Debug) Exception $e while replacing custom items");
  //   }
  // }

  Future<void> uploadCustomItemsToFirestore(List<CustomItem> items) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final uid = currentUser.uid;

    try {
      final docRef = FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("custom_items")
          .doc("data");

      // ---------------- READ EXISTING ITEMS ----------------
      final existingSnapshot = await docRef.get();

      if (existingSnapshot.exists) {
        final data = existingSnapshot.data();

        if (data != null && data["items"] != null) {
          final rawItems = data["items"] as List<dynamic>;

          for (final raw in rawItems) {
            final oldItem = CustomItem.fromMap(
              Map<String, dynamic>.from(raw),
            );

            // Delete old Cloudinary image
            if (oldItem.imagePublicId != null) {
              try {
                final deleted = await CloudinaryService.deleteImageByPublicId(oldItem.imagePublicId!);

                print(
                  "(Cloudinary) Deleted old custom item image from cloudinary: $deleted",
                );
              } catch (e) {
                print(
                  "(Cloudinary) Failed deleting old custom item image from cloudinary: $e",
                );
              }
            }
          }
        }
      }

      // ---------------- PREPARE NEW ITEMS ----------------
      List<Map<String, dynamic>> itemsMap = [];

      for (final item in items) {
        // Upload image if exists
        if (item.imagePath != null) {
          final imageUrls = await CloudinaryService.uploadCustomItemImage(File(item.imagePath!));

          if (imageUrls != null) {
            item.imageUrl = imageUrls['url'];
            item.imagePublicId = imageUrls['publicId'];
          }
        }

        itemsMap.add(item.toMap());
      }

      // ---------------- OVERWRITE DOCUMENT ----------------
      await docRef.set({
        "items": itemsMap,
      });

    } catch (e) {
      print("(Debug) Exception $e while replacing custom items");
    }
  }

  Future<List<CustomItem>> getCustomItemsFromFirestore() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    try {
      final uid = currentUser.uid;

      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("custom_items")
          .doc("data")
          .get();

      final data = snapshot.data();
      if (data == null) return [];

      final rawItems = data["items"] as List<dynamic>?;

      if (rawItems == null) return [];

      List<CustomItem> items = [];

      for (final raw in rawItems) {
        final item = CustomItem.fromMap(Map<String, dynamic>.from(raw));

        if (item.imageUrl != null) {
          final file = await CloudinaryService.downloadImageToFile(
            item.imageUrl!,
            "custom_item_${item.id}",
          );

          // Delete previous local image
          if (item.imagePath != null) {
            await HelperFunctions.deleteImage(item.imagePath!);
          }

          final savedPath =
              await saveCustomItemImagePermanently(file);

          item.imagePath = savedPath;
        }

        items.add(item);
      }

      return items;
    } catch (e) {
      print("(Debug) Exception $e while fetching custom items");
      return [];
    }
  }

  // Save image permanently from picked file
  Future<String?> saveCustomItemImagePermanently(File tempImageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final customItem = Directory('${appDir.path}/custom_items');
      
      if (!await customItem.exists()) {
        await customItem.create(recursive: true);
      }
      
      final fileName = 'custom_item_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${customItem.path}/$fileName';
      await tempImageFile.copy(savedPath);
      
      return savedPath;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }
}