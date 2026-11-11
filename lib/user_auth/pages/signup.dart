import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chores/data/providers/authentication_provider.dart';
import 'package:chores/user_auth/pages/login.dart';
import 'package:chores/user_auth/widgets/form_container.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:keybinder/keybinder.dart';
import '../../l10n/app_localizations.dart';
import '../../views/wg_selection.dart';
import '../../widgets/navigation_bar.dart';
import '../widgets/auth_button.dart';
import 'package:chores/data/user_repository.dart';



class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final enterButton = Keybinding.from({LogicalKeyboardKey.enter});

  @override
  void initState() {
    super.initState();
    Keybinder.bind(enterButton, onPressed);
  }

  void onPressed() {
    _signUp();
  }

  /// Shows the reason a social sign-in failed (unless the user just
  /// canceled it) instead of failing silently.
  void _showAuthError(Object e) {
    if (e is GoogleSignInException &&
        e.code == GoogleSignInExceptionCode.canceled) {
      return;
    }
    if (e is FirebaseAuthException &&
        (e.code == 'canceled' ||
            e.code == 'user-cancelled' ||
            e.code == 'web-context-canceled')) {
      return;
    }
    Fluttertoast.showToast(
      msg: e is FirebaseAuthException
          ? (e.message ?? e.code)
          : e is GoogleSignInException
              ? "Google sign-in failed: ${e.description ?? e.code.name}"
              : e.toString(),
      textColor: Theme.of(context).colorScheme.error,
      gravity: ToastGravity.CENTER,
      toastLength: Toast.LENGTH_LONG,
    );
  }


  @override
  void dispose() {
    Keybinder.remove(enterButton, onPressed);
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;

    return SelectionArea(child: Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset(
                  "assets/logo.png",
                  width: 125,
                  height: 125,
                  fit: BoxFit.cover,),
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                loc.signup,
                style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 30,
              ),
              FormContainer(
                controller: _usernameController,
                hintText: loc.uname,
                isPasswordField: false,
              ),
              const SizedBox(
                height: 10,
              ),
              FormContainer(
                controller: _emailController,
                hintText: loc.email,
                isPasswordField: false,
              ),
              const SizedBox(
                height: 10,
              ),
              FormContainer(
                controller: _passwordController,
                hintText: loc.pw,
                isPasswordField: true,
              ),
              const SizedBox(
                height: 30,
              ),
              Material(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  splashColor: Theme.of(context).colorScheme.surfaceTint.withValues(alpha: 0.75),
                  enableFeedback: true,
                  onTap: _signUp,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(child: Text(loc.signup_b, style: TextStyle(color: Theme.of(context).colorScheme.surface, fontWeight: FontWeight.bold, fontSize: 17),)),
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(loc.or, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  )
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AuthButton(imagePath: "assets/google_logo.png", onTap: _signUpWithGoogle),
                  const SizedBox(width: 25,),
                  AuthButton(imagePath: "assets/github-mark.png", onTap: _signUpWithGithub),
                ],
              ),
              const SizedBox(height: 20,),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(loc.haveAccount),
                  const SizedBox(width: 5,),
                  InkWell(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                            context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Text(loc.login_b, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),))
                ],
              )
            ],
          ),
        ),
      ),
    ),);
  }

  Future<dynamic> _signUp() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    String? message = await AuthenticationProvider(auth).signUp(email: email, password: password);
    User? user = auth.currentUser;

    if (!mounted) return null;
    if (message != null) {
      Navigator.pop(context);
      return Fluttertoast.showToast(
        msg: message,
        textColor: Theme.of(context).colorScheme.error,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
      );
    }

    Navigator.pop(context);

    Keybinder.remove(enterButton, onPressed);

    if (user != null) {
      await user.updateDisplayName(username);
    }

    await db.collection("users").doc(auth.currentUser?.uid).set({
      "username": username,
      "wg": UserRepository.noWgSentinel,
    });

    if (!mounted) return null;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => WGSelection(username: username),
        ), (route) => false
    );

    return null;
  }

  Future<dynamic> _signUpWithGoogle() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await AuthenticationProvider(auth).signInWithGoogle();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showAuthError(e);
      return;
    }

    if (!mounted) return null;
    User? user = auth.currentUser;

    if (user == null) {
      Navigator.pop(context);
      return Fluttertoast.showToast(
        msg: "Error signing in with Google. The email may already be linked to another account.",
        textColor: Theme.of(context).colorScheme.error,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_LONG,
      );
    }

    // Creates users/{uid} on first OAuth sign-in. Awaited, so
    // navigation can never outrun the write.
    final String? wgID = await UserRepository.ensureUserDoc(user);

    if (!mounted) return null;
    Navigator.pop(context);

    if (wgID == null) {
      return Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => WGSelection(
                  username: AuthenticationProvider.usernameOf(
                      FirebaseAuth.instance.currentUser!))
          ), (route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const NavBar(),
          ), (route) => false
      );
    }

    return null;
  }

  Future<dynamic> _signUpWithGithub() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await AuthenticationProvider(auth).signInWithGitHub();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showAuthError(e);
      return;
    }

    if (!mounted) return null;
    User? user = auth.currentUser;

    if (user == null) {
      Navigator.pop(context);
      return Fluttertoast.showToast(
        msg: "Error signing in with GitHub. The email may already be linked to another account.",
        textColor: Theme.of(context).colorScheme.error,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_LONG,
      );
    }

    // Creates users/{uid} on first OAuth sign-in. Awaited, so
    // navigation can never outrun the write.
    final String? wgID = await UserRepository.ensureUserDoc(user);

    if (!mounted) return null;
    Navigator.pop(context);

    if (wgID == null) {
      return Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => WGSelection(
                  username: AuthenticationProvider.usernameOf(
                      FirebaseAuth.instance.currentUser!))
          ), (route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const NavBar(),
          ), (route) => false
      );
    }

    return null;
  }
}
