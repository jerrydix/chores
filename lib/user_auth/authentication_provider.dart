
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

    await GoogleSignIn.instance.initialize(
        //serverClientId: "173688729888-6dbdlbqtinkdtqh1dp2dugml754pf320.apps.googleusercontent.com"
    );

    if (kIsWeb) {
      return await firebaseAuth.signInWithPopup(GoogleAuthProvider());
    }

    final gUser = await GoogleSignIn.instance.authenticate();

    final gAuth = gUser.authentication;
    if (gAuth.idToken == null) {
      throw Exception("Google ID Token is null");
    }

    final credential = GoogleAuthProvider.credential(
      idToken: gAuth.idToken,
    );

    return await firebaseAuth.signInWithCredential(credential);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

}