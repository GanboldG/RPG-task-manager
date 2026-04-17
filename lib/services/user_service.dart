// services/user_service.dart
import 'package:rpg_task_manager/models/user.dart';
import 'package:rpg_task_manager/services/reward_service.dart';
import 'package:rpg_task_manager/services/user_id_counter.dart';

// Add user file read / write operations in here, in the future!

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();
  
  User? _currentUser;
  
  User get currentUser {
    if (_currentUser == null) {
      throw Exception('User not initialized');
    }
    return _currentUser!;
  }
  
  Future<void> initializeUser() async {
    _currentUser = User(
      id: await UserIdCounter.getNextId(),
      fullName: 'GanaaPlayzXD',
      email: 'admin@example.com',
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
      level: 1,
      experienceThreshold: RewardService.xpForNextLevel(1),
      golds: 999,
      crystals: 999,
      maxEquippedItemAmount: 3
    );
  }
  
  void updateUser(User updatedUser) {
    _currentUser = updatedUser;
  }
}