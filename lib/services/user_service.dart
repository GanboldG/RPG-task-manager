import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:rpg_task_manager/models/user.dart';
import 'package:rpg_task_manager/services/reward_service.dart';

class UserService {

  //--------------Singleton Variables---------------
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();
  
  User? _currentUser;
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;
  
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


  // ----------------FIRESTORE METHODS---------------------
  Future<User?> getFromFirestore() async {
    try {
      final uid = fb.FirebaseAuth.instance.currentUser!.uid;

      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      if (!doc.exists) return null;

      return User.fromMap(doc.data()!);
    } catch (e) {
      print("Exception $e while getting user from firestore");
      return null;
    }
  }


  Future<void> uploadToFirestore(User user) async {
    try {
      final uid = fb.FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(user.toMap());
    } catch (e) {
      print("Exception $e while uploading user to firestore");
    }
  }



  /// Check if user is logged in
  Future<bool> hasUser() async {
    return _auth.currentUser != null || loadUserData() != null;
  }
}