
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationProvider {
  final FirebaseAuth firebaseAuth;
  AuthenticationProvider(this.firebaseAuth);
  Stream<User?> get authState => firebaseAuth.idTokenChanges();

  // OAuth client IDs of this Firebase project.
  // Android ignores `clientId` (apps are identified by package name +
  // signing SHA-1) and instead needs the *web* client ID as
  // `serverClientId` to mint an ID token Firebase accepts.
  static const String _webServerClientId =
      '173688729888-6dbdlbqtinkdtqh1dp2dugml754pf320.apps.googleusercontent.com';
  static const String _iosClientId =
      '173688729888-p0kiaemtugiu7smd9ouodcoqbvuvnbeh.apps.googleusercontent.com';

  static bool _googleInitialized = false;

  /// OAuth providers (especially GitHub) may not supply a display name.
  static String usernameOf(User user) =>
      user.displayName ?? user.email?.split('@').first ?? 'User';

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
    // There may be no Google session at all (email or GitHub users) —
    // never let disconnect() failing block the Firebase sign-out.
    try {
      if (!kIsWeb && _googleInitialized) {
        await GoogleSignIn.instance.disconnect();
      }
    } catch (e) {
      debugPrint("Google disconnect failed: $e");
    }
    await firebaseAuth.signOut();
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      return await firebaseAuth.signInWithPopup(GoogleAuthProvider());
    }

    if (!_googleInitialized) {
      final isApple = defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS;
      await GoogleSignIn.instance.initialize(
        clientId: isApple ? _iosClientId : null,
        serverClientId: _webServerClientId,
      );
      _googleInitialized = true;
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

  Future<UserCredential> signInWithGitHub() async {
    final githubProvider = GithubAuthProvider();
    if (kIsWeb) {
      return await firebaseAuth.signInWithPopup(githubProvider);
    }
    return await firebaseAuth.signInWithProvider(githubProvider);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
    }
  }

}