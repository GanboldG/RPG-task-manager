import 'package:hive/hive.dart';
import 'package:rpg_task_manager/models/item/item.dart';
import 'package:rpg_task_manager/models/item/owned_custom_item.dart';

part 'user.g.dart';

@HiveType(typeId: 3)
class User {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String fullName;
  
  @HiveField(2)
  String email;
  
  @HiveField(3)
  String? phoneNumber;
  
  @HiveField(4)
  DateTime? dateOfBirth;
  
  @HiveField(5)
  String? avatarUrl;
  
  @HiveField(6)
  String? bio;
  
  @HiveField(7)
  int experiencePoints;
  
  @HiveField(8)
  int golds;
  
  @HiveField(9)
  int crystals;
  
  @HiveField(10)
  int level;
  
  @HiveField(11)
  List<int> friends; // User IDs

  @HiveField(12)
  DateTime createdAt;
  
  @HiveField(13)
  DateTime lastActive;

  // ==================== INVENTORY ====================
  @HiveField(14)
  List<Item> ownedItems; // Item IDs or names
  
  @HiveField(15)
  List<Item> equippedItems; // slot: itemId (e.g., 'avatar_frame': 'gold_frame')
  
  @HiveField(16)
  List<int> unlockedAchievements; // Achievement IDs

  @HiveField(17)
  int experienceThreshold;

  @HiveField(18)
  List<OwnedCustomItem> ownedCustomItems;

  @HiveField(19)
  List<OwnedCustomItem> activatedCustomItems;

  @HiveField(20)
  int maxEquippedItemAmount;

  // All the additional parametes
  @HiveField(21)
  int shopSlot;

  @HiveField(22)
  int customShopSlot;

  @HiveField(23)
  int shopRerolls;

  @HiveField(24)
  int inventorySlot;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.avatarUrl,
    this.bio,
    this.experiencePoints = 0,
    this.experienceThreshold = 0,
    this.golds = 0,
    this.crystals = 0,
    this.level = 1,
    List<Item>? ownedItems,
    List<Item>? equippedItems,
    List<OwnedCustomItem>? ownedCustomItems,
    List<OwnedCustomItem>? activatedCustomItems,
    List<int>? unlockedAchievements,
    List<int>? badges,
    List<int>? friends,
    required this.createdAt,
    required this.lastActive,
    required this.maxEquippedItemAmount,
    required this.shopSlot,
    required this.customShopSlot,
    required this.shopRerolls,
    required this.inventorySlot,
  }) : ownedItems = ownedItems ?? [],
       equippedItems = equippedItems ?? [],
       activatedCustomItems = activatedCustomItems ?? [],
       ownedCustomItems = ownedCustomItems ?? [],
       unlockedAchievements = unlockedAchievements ?? [],
       friends = friends ?? [];

  // Copy with method for partial updates
  User copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? bio,
    String? themeMode,
    String? language,
    bool? notificationEnabled,
    bool? emailNotifications,
  }) {
    return User(
      id: this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: this.dateOfBirth,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      experiencePoints: this.experiencePoints,
      experienceThreshold: this.experienceThreshold,
      golds: this.golds,
      crystals: this.crystals,
      level: this.level,
      ownedItems: this.ownedItems,
      equippedItems: this.equippedItems,
      unlockedAchievements: this.unlockedAchievements,
      friends: this.friends,
      createdAt: this.createdAt,
      lastActive: this.lastActive,
      maxEquippedItemAmount: this.maxEquippedItemAmount,
      shopSlot: this.shopSlot,
      customShopSlot: this.customShopSlot,
      shopRerolls: this.shopRerolls,
      inventorySlot: this.inventorySlot
    );
  }

    // ================= FIRESTORE TO MAP =================
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'experiencePoints': experiencePoints,
      'golds': golds,
      'crystals': crystals,
      'level': level,
      'friends': friends,
      'createdAt': createdAt,
      'lastActive': lastActive,

      'ownedItems': ownedItems.map((e) => e.toMap()).toList(),
      'equippedItems': equippedItems.map((e) => e.toMap()).toList(),

      'unlockedAchievements': unlockedAchievements,

      'experienceThreshold': experienceThreshold,

      'ownedCustomItems':
          ownedCustomItems.map((e) => e.toMap()).toList(),

      'activatedCustomItems':
          activatedCustomItems.map((e) => e.toMap()).toList(),

      'maxEquippedItemAmount': maxEquippedItemAmount,
      'shopSlot': shopSlot,
      'customShopSlot': customShopSlot,
      'inventorySlot': inventorySlot,
      'shopRerolls': shopRerolls,
    };
  }

  // ================= FIRESTORE FROM MAP =================
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      dateOfBirth: map['dateOfBirth']?.toDate(),
      avatarUrl: map['avatarUrl'],
      bio: map['bio'],

      experiencePoints: map['experiencePoints'] ?? 0,
      golds: map['golds'] ?? 0,
      crystals: map['crystals'] ?? 0,
      level: map['level'] ?? 1,

      friends: List<int>.from(map['friends'] ?? []),

      createdAt: map['createdAt'].toDate(),
      lastActive: map['lastActive'].toDate(),

      ownedItems: (map['ownedItems'] as List? ?? [])
          .map((e) => Item.fromMap(e))
          .toList(),

      equippedItems: (map['equippedItems'] as List? ?? [])
          .map((e) => Item.fromMap(e))
          .toList(),

      unlockedAchievements:
          List<int>.from(map['unlockedAchievements'] ?? []),

      experienceThreshold: map['experienceThreshold'] ?? 0,

      ownedCustomItems: (map['ownedCustomItems'] as List? ?? [])
          .map((e) => OwnedCustomItem.fromMap(e))
          .toList(),

      activatedCustomItems: (map['activatedCustomItems'] as List? ?? [])
          .map((e) => OwnedCustomItem.fromMap(e))
          .toList(),

      maxEquippedItemAmount:
          map['maxEquippedItemAmount'] ?? 0,

      shopSlot: map['shopSlot'] ?? 0,
      customShopSlot: map['customShopSlot'] ?? 0,
      shopRerolls: map['shopRerolls'] ?? 0,
      inventorySlot: map['inventorySlot'] ?? 0,
    );
  }
}