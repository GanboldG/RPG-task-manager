import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rpg_task_manager/models/achievement.dart';
import 'package:rpg_task_manager/models/reward.dart';

class AchievementDatabase {
  static final List<Achievement> allAchievements = [
    Achievement(
      id: "starter", 
      name: "Starter", 
      description: "Reach level 2", 
      imageUrl: "assets/images/achievemets/starter.png",
      active: true,
      version: 1,
      reward: Reward(xp: 50, gold: 0, crystal: 0)
    ),

    Achievement(
      id: "nice", 
      name: "Nice", 
      description: "Reach 69 day streak", 
      imageUrl: "assets/images/achievemets/nice.png",
      active: true,
      version: 1,
      reward: Reward(xp: 6900, gold: 69, crystal: 0)
    ),

    Achievement(
      id: "mad_man", 
      name: "Mad Man", 
      description: "Complete 100 tasks in a row without abandoning any", 
      imageUrl: "assets/images/achievemets/mad_man.png",
      active: true,
      version: 1,
      reward: Reward(xp: 15000, gold: 300, crystal: 0)
    ),

    Achievement(
      id: "socialist", 
      name: "Socialist", 
      description: "Have 5 friends", 
      imageUrl: "assets/images/achievemets/socialist.png",
      active: true,
      version: 1,
      reward: Reward(xp: 400, gold: 0, crystal: 0)
    ),

    Achievement(
      id: "amnesia", 
      name: "Amnesia", 
      description: "Fill inventory with items", 
      imageUrl: "assets/images/achievemets/amnesia.png",
      active: true,
      version: 1,
      reward: Reward(xp: 1500, gold: 80, crystal: 0)
    ),
  ];



  static List<Achievement> getActiveAchievements(){
    return allAchievements.where((e) => e.active).toList();
  }


  // Only do it once after achivement list gets changed
  static Future<void> uploadToFirestore() async {
    final firestore = FirebaseFirestore.instance;

    final batch = firestore.batch();

    for (final achievement in allAchievements) {
      final docRef = firestore
          .collection('achievements')
          .doc(achievement.id);

      batch.set(
        docRef,
        achievement.toMap(),
        SetOptions(merge: true), // prevents overwriting unintended fields
      );
    }

    await batch.commit();
  }
}