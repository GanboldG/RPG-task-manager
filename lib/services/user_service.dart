// services/user_service.dart
import 'package:rpg_task_manager/controllers/user_controller.dart';
import 'package:rpg_task_manager/models/user.dart';
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
      fullName: 'CaMaP',
      email: 'admin@example.com',
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
      level: 1,
      experienceThreshold: XPSystem.xpForNextLevel(1),
    );
  }
  
  void updateUser(User updatedUser) {
    _currentUser = updatedUser;
  }
}