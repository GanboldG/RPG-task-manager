import 'package:hive/hive.dart';
import 'package:rpg_task_manager/models/item/item.dart';

part 'user.g.dart';

@HiveType(typeId: 3)
class User {
  // ==================== PERSONAL INFO ====================
  @HiveField(0)
  int id;
  
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
  int gems;
  
  @HiveField(10)
  int level;
  
  @HiveField(11)
  List<int> friends; // User IDs

  @HiveField(12)
  DateTime createdAt;
  
  @HiveField(13)
  DateTime lastActive;

  // ==================== STATISTICS ====================
  @HiveField(14)
  int tasksCompleted;
  
  @HiveField(15)
  Duration totalWorkTime;

  // ==================== INVENTORY ====================
  @HiveField(16)
  List<Item> ownedItems; // Item IDs or names
  
  @HiveField(17)
  List<Item> equippedItems; // slot: itemId (e.g., 'avatar_frame': 'gold_frame')
  
  @HiveField(18)
  List<int> unlockedAchievements; // Achievement IDs
  
  @HiveField(19)
  List<int> badges; // Badge IDs

  // Needed models:
  // Badge
  // Achievement
  // Item (bool isToken)

  // Constructor
  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.avatarUrl,
    this.bio,
    this.experiencePoints = 0,
    this.golds = 0,
    this.gems = 0,
    this.level = 1,
    this.ownedItems = const [],
    this.equippedItems = const [],
    this.unlockedAchievements = const [],
    this.badges = const [],
    this.tasksCompleted = 0,
    this.totalWorkTime = Duration.zero,
    this.friends = const [],
    required this.createdAt,
    required this.lastActive,
  });

  // ==================== HELPER METHODS ====================
  
  // Update user level based on XP
  void updateLevel() {
    // Simple formula: level = 1 + floor(XP / 100)
    int newLevel = 1 + (experiencePoints ~/ 100);
    if (newLevel != level) {
      level = newLevel;
    }
  }
  
  // Add experience points
  void addExperience(int xp) {
    experiencePoints += xp;
    updateLevel();
  }
  
  // Add coins
  void addCoins(int amount) {
    golds += amount;
  }
  
  // Spend coins
  bool spendCoins(int amount) {
    if (golds >= amount) {
      golds -= amount;
      return true;
    }
    return false;
  }
  
  // Add gems (premium currency)
  void addGems(int amount) {
    gems += amount;
  }
  
  // Spend gems
  bool spendGems(int amount) {
    if (gems >= amount) {
      gems -= amount;
      return true;
    }
    return false;
  }
  
  // Add item to inventory
  void addItem(Item item) {
    ownedItems.add(item);
  }
  
  // Remove item from inventory
  void removeItem(Item item) {
    ownedItems.remove(item);
    equippedItems.remove(item);
  }
  
  // Equip an item
  void equipItem(int slotIndex, Item item) {
    if (ownedItems.contains(item)) {
      equippedItems[slotIndex] = item;
    }
  }
  
  // Add work time
  void addWorkTime(Duration duration) {
    totalWorkTime += duration;
  }
  
  // Unlock achievement
  void unlockAchievement(int achievementId) {
    if (!unlockedAchievements.contains(achievementId)) {
      unlockedAchievements.add(achievementId);
    }
  }
  
  // Add badge
  void addBadge(int badgeId) {
    if (!badges.contains(badgeId)) {
      badges.add(badgeId);
    }
  }
  
  // Add friend
  void addFriend(String userId) {
    if (!friends.contains(userId)) {
      friends.add(id);
    }
  }
  
  // Remove friend
  void removeFriend(String userId) {
    friends.remove(userId);
  }
  
  // Update last active timestamp
  void updateLastActive() {
    lastActive = DateTime.now();
  }
  
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
      golds: this.golds,
      gems: this.gems,
      level: this.level,
      ownedItems: this.ownedItems,
      equippedItems: this.equippedItems,
      unlockedAchievements: this.unlockedAchievements,
      badges: this.badges,
      tasksCompleted: this.tasksCompleted,
      totalWorkTime: this.totalWorkTime,
      friends: this.friends,
      createdAt: this.createdAt,
      lastActive: this.lastActive,
    );
  }
}