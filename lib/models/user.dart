import 'package:hive/hive.dart';
import 'package:rpg_task_manager/controllers/custom_inventory_controller.dart';
import 'package:rpg_task_manager/models/item/item.dart';

part 'user.g.dart';

@HiveType(typeId: 3)
class User {
  // ==================== PERSONAL INFO ====================
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
  List<int> badges; // Badge IDs

  @HiveField(18)
  int experienceThreshold;

  @HiveField(19)
  List<OwnedCustomItem> ownedCustomItems;

  @HiveField(20)
  List<OwnedCustomItem> activatedCustomItems;

  @HiveField(21)
  int maxEquippedItemAmount;

  // All the additional parametes
  @HiveField(22)
  int shopSize;

  @HiveField(23)
  int shopRerolls;

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
    required this.shopSize,
    required this.shopRerolls
  }) : ownedItems = ownedItems ?? [],
       equippedItems = equippedItems ?? [],
       ownedCustomItems = ownedCustomItems ?? [],
       activatedCustomItems = activatedCustomItems ?? [],
       unlockedAchievements = unlockedAchievements ?? [],
       badges = badges ?? [],
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
      badges: this.badges,
      friends: this.friends,
      createdAt: this.createdAt,
      lastActive: this.lastActive,
      maxEquippedItemAmount: this.maxEquippedItemAmount,
      shopSize: this.shopSize,
      shopRerolls: this.shopRerolls
    );
  }
}