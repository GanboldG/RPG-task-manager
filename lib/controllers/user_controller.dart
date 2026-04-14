import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rpg_task_manager/models/difficulty.dart';
import 'package:rpg_task_manager/models/item/item.dart';
import 'package:rpg_task_manager/models/user.dart';
import 'package:rpg_task_manager/services/user_service.dart';

class UserController extends ChangeNotifier{

  late User user;

  UserController(){
    user = UserService().currentUser;
  }
  
  // Update user level based on XP
  void levelUp() {
    // Simple formula: level = 1 + floor(XP / 100)
    user.level++;
    user.experienceThreshold = calculateNextLevelThreshold();
    notifyListeners();
  }
  
  // Add experience points
  void addExperience(int xp) {
    user.experiencePoints += xp;

    if (user.experiencePoints >= user.experienceThreshold){  
      levelUp();
    }
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

  // If at lvl 1, calculates lvl 2's required xp
  int calculateNextLevelThreshold(){
    return XPSystem.xpForNextLevel(user.level);
  }
}

// --------------------------XP Calculator Helpers-----------------------------

class XPSystem {
  // Calculate XP from task
  static int calculateXP(Difficulty difficulty, int durationMinutes) {
    // Base XP: 1 XP per minute, minimum 5 XP
    int baseXP = durationMinutes.clamp(5, 120);
    
    // Apply difficulty multiplier
    double multipliedXP = baseXP * difficulty.xpMultiplier;
    
    // Return as integer (no decimals)
    return multipliedXP.round();
  }
  
  // Get XP needed for next level (exponential growth)
  static int xpForNextLevel(int currentLevel) {
    // Formula: 100 * (1.5 ^ level)
    // Level 1: 150 XP to reach level 2
    // Level 5: 759 XP to reach level 6
    // Level 10: 5,766 XP to reach level 11
    return (100 * pow(1.5, currentLevel)).round();
  }
  
  // Check if level up occurred
  static bool didLevelUp(int oldLevel, int newTotalXP) {
    int xpNeeded = xpForNextLevel(oldLevel);
    return newTotalXP >= xpNeeded;
  }
  
  // Get new level after gaining XP
  static int getNewLevel(int currentLevel, int currentXP, int gainedXP) {
    int newXP = currentXP + gainedXP;
    int newLevel = currentLevel;
    
    while (newXP >= xpForNextLevel(newLevel)) {
      newXP -= xpForNextLevel(newLevel);
      newLevel++;
    }
    
    return newLevel;
  }
}