import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

class FirebaseAuthentication {
  // Firebase Auth объектыг үүсгэнэ
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // google account-р баталгаажуулах класс
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isInitialized = false;

  Future<String?> createUser(String email, String password) async {
    try {
      UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return credential.user!.uid;
    } on FirebaseAuthException {
      return null;
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      // signInWithEmailAndPassword метод нь Firebase Auth-д нэвтрэхэд ашиглагддаг
      UserCredential credential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return credential.user!.uid;
    } on FirebaseAuthException {
      return null;
    }
  }

  Future<bool> logout() async {
    try {
      _firebaseAuth.signOut();
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  Future<void> _initGoogle() async {
    if (!_isInitialized) {
      await _googleSignIn.initialize(
        serverClientId: '549542210017-2vs5kphfiud5cvnir409dtk8k0dnefn8.apps.googleusercontent.com',
      );
      _isInitialized = true;
    }
  }

 Future<String?> loginWithGoogle() async {
  try {
    print("E");
    await _initGoogle();

    print("Z");
    final GoogleSignInAccount account =
        await _googleSignIn.authenticate();

    final auth = account.authentication;
    print("Auth done");

    final credential = GoogleAuthProvider.credential(
      idToken: auth.idToken,
    );
    print("Cred done");


    final userCredential =
        await _firebaseAuth.signInWithCredential(credential);

    print("User cred done");


    return userCredential.user?.uid;
  } catch (e) {
    print('Google login failed: $e');
    return null;
  }
}

  Future<bool> logoutGoogle() async {
    try {
      await _googleSignIn.signOut();  // энэ нь шинэ API-д ч ажиллана
      await FirebaseAuth.instance.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }
}