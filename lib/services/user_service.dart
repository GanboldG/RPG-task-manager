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
  
  bool currentUserisNull(){
    print("(Debug) Current user is null: ${_currentUser == null}}");
    return _currentUser == null;
  }

  User get currentUser {
    return _currentUser!;
  }

  void setCurrentUser(User user){
    _currentUser = user;
  }
  
  //----------------Hive Stuff---------------
  final Box<User> _userBox = Hive.box<User>('user');
  
  Future<bool> loadUserData() async {
    final stored = _userBox.get('user');

    if (stored == null) {
      return false;
    }

    _currentUser = stored;
    return true;
  }
  
  bool hasUserData() {
    return _userBox.containsKey('user');
  }

  Future<void> saveCurrentUserData() async {
    await _userBox.put('user', currentUser);
  }

  //----------------Init for the first time---------------
  User getFirstTimeUser(String fullname, String email) {
    print("(Debug) Returning first time user");
    return User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: fullname,
      email: email,
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
      level: 1,
      experienceThreshold: RewardService.xpForNextLevel(1),
      golds: 0,
      crystals: 0,
      maxEquippedItemAmount: 3,
      shopSize: 3,
      shopRerolls: 1
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
      print("(Debug) Exception $e while getting user from firestore");
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
      print("(Debug) Exception $e while uploading user to firestore");
    }
  }


  /// Check if user is logged in
  bool hasUser(){
    final data = _userBox.get('user');
    return data != null;
  }

  // Check if user already has an account in firestore
  Future<bool> userExistInFirestore(String uid) async {
    final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

    return doc.exists;
  }

  // Create account using info from creation screen
  // Store account info in firestore and hive
  Future<bool> initializeFirstTimeUser(String fullname, bool isOffline) async {

    final user = fb.FirebaseAuth.instance.currentUser;
    final email = user?.email;

    final newUser = getFirstTimeUser(fullname, email ?? "");
    setCurrentUser(newUser);

    try{
      await _userBox.put('user', newUser);
    } catch (e){
        print("(Debug) User local save failed");
        return false;
    }

    if (!isOffline){
      try{
          await uploadToFirestore(newUser);
      } catch (e){
        print("(Debug) User Firestore save failed");
          return false;
      }
    }
 
    print("(Debug) Current user: ${currentUser.fullName}");
    return true;
  }
}