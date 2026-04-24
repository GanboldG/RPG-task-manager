import 'package:hive/hive.dart';
import 'package:rpg_task_manager/models/user.dart';
import 'package:rpg_task_manager/services/reward_service.dart';

class UserService {

  //--------------Singleton Variables---------------
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
  
  //----------------Hive Stuff---------------
  final Box<User> _userBox = Hive.box<User>('user');
  
  User? loadUserData() {
    if (hasUserData()){
      _currentUser = _userBox.get('user');
    }
    else {
      _currentUser = getFirstTimeUser();
    }

    return currentUser;
  }
  
  bool hasUserData() {
    return _userBox.containsKey('user');
  }

  Future<void> saveCurrentUserData() async {
    await _userBox.put('user', currentUser);
  }

  //----------------Init for the first time---------------
  User getFirstTimeUser() {
    return User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: '[NoName]',
      email: 'noname@example.com',
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
      level: 1,
      experienceThreshold: RewardService.xpForNextLevel(1),
      golds: 999,
      crystals: 999,
      maxEquippedItemAmount: 3,
      shopSize: 5,
      shopRerolls: 5
    );
  }
}