import 'package:hive_flutter/hive_flutter.dart';
import 'package:rpg_task_manager/models/difficulty.dart';
import 'package:rpg_task_manager/models/item/custom_item.dart';
import 'package:rpg_task_manager/models/item/effect_type.dart';
import 'package:rpg_task_manager/models/item/item.dart';
import 'package:rpg_task_manager/models/item/item_effect.dart';
import 'package:rpg_task_manager/models/item/item_rarity.dart';
import 'package:rpg_task_manager/models/reward.dart';
import 'package:rpg_task_manager/models/task/task.dart';
import 'package:rpg_task_manager/models/task/task_type.dart';
import 'package:rpg_task_manager/models/user.dart';

class HiveService{
  static Map<String, Type> boxes = {
    'active_tasks' : Task,
    'completed_tasks' : Task,
    'abandoned_tasks' : Task,
    'user' : User,
    'shop_items' : Item,
    'custom_shop_items' : CustomItem
  };

  // Initialize Hive
  static Future<void> initializeHive() async{
    await Hive.initFlutter();

    // Register your adapters
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(DifficultyAdapter());
    Hive.registerAdapter(RewardAdapter());
    Hive.registerAdapter(ItemRarityAdapter());
    Hive.registerAdapter(CustomItemAdapter());
    Hive.registerAdapter(TaskTypeAdapter());
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(ItemAdapter());
    Hive.registerAdapter(ItemEffectAdapter());
    Hive.registerAdapter(EffectTypeAdapter());

    // Open boxes (or creates boxes on disk)
    await Hive.openBox<Task>('active_tasks');
    await Hive.openBox<Task>('completed_tasks');
    await Hive.openBox<Task>('abandoned_tasks');
    await Hive.openBox<User>('user');
    await Hive.openBox<Item>('shop_items');
    await Hive.openBox<CustomItem>('custom_shop_items');
  }
}