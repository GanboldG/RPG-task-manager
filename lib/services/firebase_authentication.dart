import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

class FirebaseAuthentication {
  static final FirebaseAuthentication _instance = FirebaseAuthentication._internal();
  factory FirebaseAuthentication() => _instance;
  FirebaseAuthentication._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isInitialized = false;

  Future<void> _initGoogle() async {
    if (!_isInitialized) {
      await _googleSignIn.initialize(
        serverClientId: '1031787785825-f71rk8if9896vnogi0sfljjl3cmkmsle.apps.googleusercontent.com',
      );
      _isInitialized = true;
    }
  }

  Future<String?> loginWithGoogle() async {
    try {
      await _initGoogle();

      final GoogleSignInAccount account =
          await _googleSignIn.authenticate();

      final auth = account.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      return userCredential.user?.uid;
    } catch (e) {
      return null;
    }
  }

  Future<bool> logoutGoogle() async {
    try {
      await _googleSignIn.signOut(); 
      await FirebaseAuth.instance.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }







  
  // Future<String?> createUser(String email, String password) async {
  //   try {
  //     UserCredential credential = await _firebaseAuth
  //         .createUserWithEmailAndPassword(email: email, password: password);
  //     return credential.user!.uid;
  //   } on FirebaseAuthException {
  //     return null;
  //   }
  // }

  // Future<String?> login(String email, String password) async {
  //   try {
  //     // signInWithEmailAndPassword метод нь Firebase Auth-д нэвтрэхэд ашиглагддаг
  //     UserCredential credential = await _firebaseAuth
  //         .signInWithEmailAndPassword(email: email, password: password);
  //     return credential.user!.uid;
  //   } on FirebaseAuthException {
  //     return null;
  //   }
  // }

  // Future<bool> logout() async {
  //   try {
  //     _firebaseAuth.signOut();
  //     return true;
  //   } on FirebaseAuthException {
  //     return false;
  //   }
  // }
}