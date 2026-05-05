import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rpg_task_manager/app_state.dart';
import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/models/reward.dart';
import 'package:rpg_task_manager/models/user.dart';
import 'package:rpg_task_manager/services/reward_service.dart';
import 'package:rpg_task_manager/services/user_service.dart';
import 'package:path_provider/path_provider.dart';


class UserController extends ChangeNotifier{

  late User user;
  
  void initialize(){
    user = UserService().currentUser;
  }

  // XP, crystals, golds can only be added via this method
  // XP, crystals, golds can only be added via this method
  // XP, crystals, golds can only be added via this method
  void addReward(Reward reward){
    addExperience(reward.xp);
    addCrystals(reward.crystal);
    addGolds(reward.gold);

    notifyListeners();
    UserService().saveCurrentUserData();
  }

  // XP, crystals, golds can only be reduced via this method
  // XP, crystals, golds can only be reduced via this method
  // By deleting task, you risk losing your gold and xp
  void reduceReward(Reward reward){
    reduceExperience(reward.xp);
    reduceGolds(reward.gold);

    notifyListeners();
    UserService().saveCurrentUserData();
  }

  // Update user level based on XP
  void levelUp() {
    user.level++;
    user.experienceThreshold = calculateNextLevelThreshold();

    notifyListeners();
    UserService().saveCurrentUserData();
  }
  
  // Add experience points
  void addExperience(int xp) {
    user.experiencePoints += xp;

    while (user.experiencePoints >= user.experienceThreshold){  
      user.experiencePoints = user.experiencePoints - user.experienceThreshold;
      levelUp();
    }
  }

  void reduceExperience(int xp){
    user.experiencePoints = max(user.experiencePoints - xp, 0);
  }

  // Add coins
  void addGolds(int amount) {
    user.golds += amount;
  }

  void reduceGolds(int amount){
    user.golds -= amount;
  }
  
  // Spend coins
  bool spendGolds(int amount) {
    if (user.golds >= amount) {
      user.golds -= amount;

      notifyListeners();
      UserService().saveCurrentUserData();

      return true;
    }
    return false;
  }
  
  // Add gems (premium currency)
  void addCrystals(int amount) {
    user.crystals += amount;
  }
  
  // Spend gems
  bool spendCrystals(int amount) {
    if (user.crystals >= amount) {
      user.crystals -= amount;

      notifyListeners();
      UserService().saveCurrentUserData();

      return true;
    }
    return false;
  }
  
  // Unlock achievement
  void unlockAchievement(String achievementId) {
    if (user.unlockedAchievements.contains(achievementId)) {
      user.unlockedAchievements.add(achievementId);

      notifyListeners();
      UserService().saveCurrentUserData();
    }
  }
  
  // Add friend
  void addFriend(String userId) {
    if (user.friends.contains(userId)) {
      user.friends.add(userId);

      notifyListeners();
      UserService().saveCurrentUserData();
    }
  }
  
  // Remove friend
  void removeFriend(String userId) {
    user.friends.remove(userId);

    notifyListeners();
    UserService().saveCurrentUserData();
  }
  
  // Update last active timestamp
  void updateLastActive() {
    user.lastActive = DateTime.now();

    notifyListeners();
    UserService().saveCurrentUserData();
  }

  Future<void> updateUserImage(File tempImageFile) async{
    // Delete the old image
    if (user.avatarPath != null){
      HelperFunctions.deleteImage(user.avatarPath!);
    }

    // Permanently save avatar
    final imagePath = await saveImagePermanently(tempImageFile); 
    if (imagePath != null){
      user.avatarPath = imagePath;
      notifyListeners();
      UserService().saveCurrentUserData();
    }
  }

    // Save image permanently from picked file
  Future<String?> saveImagePermanently(File tempImageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final userDir = Directory('${appDir.path}/user_avatar');
      
      if (!await userDir.exists()) {
        await userDir.create(recursive: true);
      }
      
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${userDir.path}/$fileName';
      await tempImageFile.copy(savedPath);
      
      return savedPath;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
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