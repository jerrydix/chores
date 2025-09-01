
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationProvider {
  final FirebaseAuth firebaseAuth;
  AuthenticationProvider(this.firebaseAuth);
  Stream<User?> get authState => firebaseAuth.idTokenChanges();

  Future<String?> signUp({required String email, required String password}) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signIn({required String email, required String password}) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Future<UserCredential> signInWithGoogle() async {

    await GoogleSignIn.instance.initialize();

    if (kIsWeb) {
      return await firebaseAuth.signInWithPopup(GoogleAuthProvider());
    }

    GoogleSignInAccount gUser = await GoogleSignIn.instance.authenticate();

    final GoogleSignInAuthentication gAuth = gUser.authentication;
    final credential = GoogleAuthProvider.credential(idToken: gAuth.idToken);
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

}