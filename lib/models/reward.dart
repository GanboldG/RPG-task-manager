import 'package:hive/hive.dart';
// Use this object for any type of reward situation

part 'reward.g.dart';  // Generated file

@HiveType(typeId: 2)  // Each class needs unique typeId

class Reward{
  @HiveField(0)
  int xp;

  @HiveField(1)
  int gold;

  @HiveField(2)
  int crystal;
  // Items etc in the future

  Reward({required this.xp,
         required this.gold,
         required this.crystal});
}