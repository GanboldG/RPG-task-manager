import 'package:flutter/material.dart';
import 'package:rpg_task_manager/models/item/item.dart';
import 'package:rpg_task_manager/models/user.dart';
import 'package:rpg_task_manager/services/user_service.dart';

class UserController extends ChangeNotifier{

  late User user;

  UserController(){
    user = UserService().currentUser;
  }
  
  // Update user level based on XP
  void updateLevel() {
    // Simple formula: level = 1 + floor(XP / 100)
    int newLevel = 1 + (user.experiencePoints ~/ 100);
    if (newLevel != user.level) {
      user.level = newLevel;
      notifyListeners();
    }
  }
  
  // Add experience points
  void addExperience(int xp) {
    user.experiencePoints += xp;
    updateLevel();
    notifyListeners();
  }
  
  // Add coins
  void addCoins(int amount) {
    user.golds += amount;
    notifyListeners();
  }
  
  // Spend coins
  bool spendCoins(int amount) {
    if (user.golds >= amount) {
      user.golds -= amount;
      notifyListeners();
      return true;
    }
    return false;
  }
  
  // Add gems (premium currency)
  void addCrystals(int amount) {
    user.crystals += amount;
    notifyListeners();
  }
  
  // Spend gems
  bool spendCrystals(int amount) {
    if (user.crystals >= amount) {
      user.crystals -= amount;
      notifyListeners();
      return true;
    }
    return false;
  }
  
  // Add item to inventory
  void addItem(Item item) {
    user.ownedItems.add(item);
  }
  
  // Remove item from inventory
  void removeItem(Item item) {
    user.ownedItems.remove(item);
    user.equippedItems.remove(item);
  }
  
  // Equip an item
  void equipItem(int slotIndex, Item item) {
    if (user.ownedItems.contains(item)) {
      user.equippedItems[slotIndex] = item;
    }
  }
  
  // Add work time
  void addWorkTime(Duration duration) {
    user.totalWorkTime += duration;
  }
  
  // Unlock achievement
  void unlockAchievement(int achievementId) {
    if (user.unlockedAchievements.contains(achievementId)) {
      user.unlockedAchievements.add(achievementId);
    }
  }
  
  // Add badge
  void addBadge(int badgeId) {
    if (user.badges.contains(badgeId)) {
      user.badges.add(badgeId);
    }
  }
  
  // Add friend
  void addFriend(int userId) {
    if (user.friends.contains(userId)) {
      user.friends.add(userId);
    }
  }
  
  // Remove friend
  void removeFriend(String userId) {
    user.friends.remove(userId);
  }
  
  // Update last active timestamp
  void updateLastActive() {
    user.lastActive = DateTime.now();
  }
}