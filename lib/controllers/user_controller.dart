import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/models/reward.dart';
import 'package:rpg_task_manager/models/user.dart';
import 'package:rpg_task_manager/services/reward_service.dart';
import 'package:rpg_task_manager/services/user_service.dart';

class UserController extends ChangeNotifier{

  late User user;

  UserController(){
    user = UserService().currentUser;
  }
  
  void addReward(Reward reward){
    addExperience(reward.xp);
    addCrystals(reward.crystal);
    addGolds(reward.gold);
  }

  // By deleting task, you risk losing your gold and xp
  void reduceReward(Reward reward){
    reduceExperience(reward.xp);
    reduceGolds(reward.gold);
  }

  // Update user level based on XP
  void levelUp() {
    user.level++;
    user.experienceThreshold = calculateNextLevelThreshold();
    notifyListeners();
  }
  
  // Add experience points
  void addExperience(int xp) {
    user.experiencePoints += xp;

    while (user.experiencePoints >= user.experienceThreshold){  
      user.experiencePoints = user.experiencePoints - user.experienceThreshold;
      levelUp();
    }
    notifyListeners();
  }

  void reduceExperience(int xp){
    user.experiencePoints = max(user.experiencePoints - xp, 0);
    notifyListeners();
  }

  // Add coins
  void addGolds(int amount) {
    user.golds += amount;
    notifyListeners();
  }

  void reduceGolds(int amount){
    user.golds -= amount;
    notifyListeners();
  }
  
  // Spend coins
  bool spendGolds(int amount) {
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
  
  // Add work time
  void addWorkTime(Duration duration) {
    user.totalWorkTime += duration;
    notifyListeners();
  }
  
  // Unlock achievement
  void unlockAchievement(int achievementId) {
    if (user.unlockedAchievements.contains(achievementId)) {
      user.unlockedAchievements.add(achievementId);
      notifyListeners();
    }
  }
  
  // Add badge
  void addBadge(int badgeId) {
    if (user.badges.contains(badgeId)) {
      user.badges.add(badgeId);
      notifyListeners();
    }
  }
  
  // Add friend
  void addFriend(int userId) {
    if (user.friends.contains(userId)) {
      user.friends.add(userId);
      notifyListeners();
    }
  }
  
  // Remove friend
  void removeFriend(String userId) {
    user.friends.remove(userId);
    notifyListeners();
  }
  
  // Update last active timestamp
  void updateLastActive() {
    user.lastActive = DateTime.now();
    notifyListeners();
  }

  // If at lvl 1, calculates lvl 2's required xp
  int calculateNextLevelThreshold(){
    return RewardService.xpForNextLevel(user.level);
  }

  // Returns string for resource bar on top
  String getExperienceString(){
    return "${HelperFunctions.formatNumberSuffix(user.experiencePoints)}/${HelperFunctions.formatNumberSuffix(user.experienceThreshold)}";
  }
}