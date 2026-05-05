import 'package:hive/hive.dart';
import 'package:rpg_task_manager/models/reward.dart';

part 'achievement.g.dart';

@HiveType(typeId: 15)
class Achievement extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String imageUrl;

  @HiveField(4)
  final int version;

  @HiveField(5)
  final Reward? reward;

  // if disabled, is invisible from app
  @HiveField(6)
  final bool active;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.version = 1,
    this.reward,
    this.active = true
  });

  /// Firestore -> Model
  factory Achievement.fromMap(Map<String, dynamic> map, String docId) {
    return Achievement(
      id: docId, // use document ID as source of truth
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      version: map['version'] ?? 1,
      reward: map['reward'] != null
          ? Reward.fromMap(Map<String, dynamic>.from(map['reward']))
          : null,
      active: map['active'] ?? true,
    );
  }

  /// Model -> Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'version': version,
      'reward': reward?.toMap(),
      'active': active
    };
  }
}