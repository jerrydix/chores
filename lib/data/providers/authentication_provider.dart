
import 'package:firebase_auth/firebase_auth.dart';
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

  signInWithGoogle() async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication gAuth = await gUser!.authentication;

      final credential = GoogleAuthProvider.credential(
          idToken: gAuth.idToken,
          accessToken: gAuth.accessToken
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (error) {
      print("error: $error");
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

}