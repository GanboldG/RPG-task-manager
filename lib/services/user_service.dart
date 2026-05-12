import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/models/user.dart';
import 'package:rpg_task_manager/services/cloudinary_service.dart';
import 'package:rpg_task_manager/services/reward_service.dart';
import 'dart:io';
import 'dart:convert';

class UserService {
  //--------------Singleton Variables---------------
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  User? _currentUser;
  fb.FirebaseAuth? _auth;
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;

  bool currentUserisNull() {
    // print("(Debug) Current user is null: ${_currentUser == null}}");
    return _currentUser == null;
  }

  User get currentUser {
    return _currentUser!;
  }

  void setCurrentUser(User user) async {
    _currentUser = user;
    await saveCurrentUserData();
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
      shopSlot: 3,
      customShopSlot: 5,
      inventorySlot: 15,
      shopRerolls: 1,
    );
  }

  // ----------------FIRESTORE METHODS---------------------
  // This downloads user avatar image every time it's called
  Future<User?> getFromFirestore() async {
    if (fb.FirebaseAuth.instance.currentUser == null) {
      return null;
    }

    try {
      // 1) Get User data from firestore
      final uid = fb.FirebaseAuth.instance.currentUser!.uid;

      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      if (!doc.exists) return null;

      final User user = User.fromMap(doc.data()!);

      // 2) Download image from cloudinary
      if (user.avatarUrl != null) {
        File userAvatarImg = await CloudinaryService.downloadImageToFile(
          user.avatarUrl!,
          "user_avatar",
        );

        // Delete the old user image (if exists)
        if (user.avatarPath != null) {
          HelperFunctions.deleteImage(user.avatarPath!);
        }

        String? userAvatarUrl = await saveUserAvatarPermanently(userAvatarImg);

        // 3) Set user avatar local path
        user.avatarPath = userAvatarUrl;
      }

      return user;
    } catch (e) {
      print("(Debug) Exception $e while getting user from firestore");
      return null;
    }
  }

  // Save image permanently from picked file
  Future<String?> saveUserAvatarPermanently(File tempImageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final avatar = Directory('${appDir.path}/user_avatar');

      if (!await avatar.exists()) {
        await avatar.create(recursive: true);
      }

      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${avatar.path}/$fileName';
      await tempImageFile.copy(savedPath);

      return savedPath;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  Future<void> uploadToFirestore(User user) async {
    if (fb.FirebaseAuth.instance.currentUser == null) {
      return;
    }

    try {
      // 1) Upload image to cloudinary (if there is an image), and set imageUrl
      if (user.avatarPath != null) {
        // returns
        // 'url': json['secure_url'],
        // 'publicId': json['public_id'],
        Map<String, dynamic>? imageUrls =
            await CloudinaryService.uploadUserAvatarImage(
              File(user.avatarPath!),
            );

        print("Cloudinary image Url: $imageUrls");
        if (imageUrls != null) {
          // 1.5) Remove the old image, if exists
          if (user.avatarUrl != null && user.avatarPublicId != null) {
            final deleted = await CloudinaryService.deleteImageByPublicId(
              user.avatarPublicId!,
            );
            print("(Cloudinary) Deleted old image: $deleted");
          }

          user.avatarUrl = imageUrls['url'];
          user.avatarPublicId = imageUrls['publicId'];
        }
      }

      // 2) Upload user to firestore
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
  bool hasUser() {
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
    final email = '';

    final newUser = getFirstTimeUser(fullname, email ?? "");
    setCurrentUser(newUser);

    try {
      await _userBox.put('user', newUser);
    } catch (e) {
      print("(Debug) User local save failed");
      return false;
    }

    if (!isOffline) {
      try {
        await uploadToFirestore(newUser);
      } catch (e) {
        print("(Debug) User Firestore save failed");
        return false;
      }
    }

    print("(Debug) Current user: ${currentUser.fullName}");
    return true;
  }

  // Downloads the user json file to phone's download folder
  Future<void> downloadUserDateAsJson() async {
    final data = currentUser.toMap();
    final encoder = JsonEncoder.withIndent('  ', (object) {
      if (object is DateTime) {
        return object.toIso8601String();
      }
      if (object is DateTime?) {
        return object?.toIso8601String();
      }
      return object.toString();
    });

    final jsonString = encoder.convert(currentUser.toMap());

    final dir = Directory('/storage/emulated/0/Download');
    final file = File('${dir.path}/debug_user.json');

    await file.writeAsString(jsonString);
    print(file.absolute.path);
  }
}
