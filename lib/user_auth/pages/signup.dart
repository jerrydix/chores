import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chores/data/providers/authentication_provider.dart';
import 'package:chores/user_auth/widgets/form_container.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:keybinder/keybinder.dart';
import '../../l10n/app_localizations.dart';
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
                        // Step back to the login page underneath rather
                        // than stacking a second copy of it over Wrapper.
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
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

    // Captured before the await. A successful sign-in makes Wrapper swap this
    // page out for its own loader, so this State can be unmounted by the time
    // the spinner has to come down — and a `mounted` guard would then skip the
    // pop, stranding the dialog above the next screen.
    final NavigatorState navigator = Navigator.of(context);
    final Color errorColor = Theme.of(context).colorScheme.error;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    String? message = await AuthenticationProvider(auth)
        .signUp(email: email, password: password);

    if (message != null) {
      if (navigator.canPop()) navigator.pop();
      return Fluttertoast.showToast(
        msg: message,
        textColor: errorColor,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
      );
    }

    final User? user = auth.currentUser;
    if (user == null) {
      // No error but no session either: nothing to route to, let them retry.
      if (navigator.canPop()) navigator.pop();
      return null;
    }

    // The profile write has to happen whether or not this page survived: it
    // carries the chosen username, Wrapper routes on it, and WgRepository
    // later updates it — an update on a missing document fails.
    await user.updateDisplayName(username);
    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "username": username,
      "wg": UserRepository.noWgSentinel,
    });

    // Unwind to the root route, where Wrapper lives: it has already seen the
    // new auth state and renders WGSelection or NavBar. This takes the spinner
    // dialog with it, and is a no-op when this page is Wrapper's own child.
    navigator.popUntil((route) => route.isFirst);

    return null;
  }

  Future<dynamic> _signUpWithGoogle() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    // Captured before the await. A successful sign-in makes Wrapper swap this
    // page out for its own loader, so this State can be unmounted by the time
    // the spinner has to come down — and a `mounted` guard would then skip the
    // pop, stranding the dialog above the next screen.
    final NavigatorState navigator = Navigator.of(context);
    final Color errorColor = Theme.of(context).colorScheme.error;

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
      if (navigator.canPop()) navigator.pop();
      if (!mounted) return;
      _showAuthError(e);
      return;
    }

    final User? user = auth.currentUser;

    if (user == null) {
      if (navigator.canPop()) navigator.pop();
      return Fluttertoast.showToast(
        msg:
            "Error signing in with Google. The email may already be linked to another account.",
        textColor: errorColor,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_LONG,
      );
    }

    // Creates users/{uid} on first OAuth sign-in. Deliberately not behind a
    // `mounted` check: Wrapper routes on this document, so it has to be
    // written even when this page is already gone.
    await UserRepository.ensureUserDoc(user);

    // Unwind to the root route, where Wrapper lives: it has already seen the
    // new auth state and renders WGSelection or NavBar. This takes the spinner
    // dialog with it, and is a no-op when this page is Wrapper's own child.
    navigator.popUntil((route) => route.isFirst);

    return null;
  }

  Future<dynamic> _signUpWithGithub() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    // Captured before the await. A successful sign-in makes Wrapper swap this
    // page out for its own loader, so this State can be unmounted by the time
    // the spinner has to come down — and a `mounted` guard would then skip the
    // pop, stranding the dialog above the next screen.
    final NavigatorState navigator = Navigator.of(context);
    final Color errorColor = Theme.of(context).colorScheme.error;

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
      if (navigator.canPop()) navigator.pop();
      if (!mounted) return;
      _showAuthError(e);
      return;
    }

    final User? user = auth.currentUser;

    if (user == null) {
      if (navigator.canPop()) navigator.pop();
      return Fluttertoast.showToast(
        msg:
            "Error signing in with GitHub. The email may already be linked to another account.",
        textColor: errorColor,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_LONG,
      );
    }

    // Creates users/{uid} on first OAuth sign-in. Deliberately not behind a
    // `mounted` check: Wrapper routes on this document, so it has to be
    // written even when this page is already gone.
    await UserRepository.ensureUserDoc(user);

    // Unwind to the root route, where Wrapper lives: it has already seen the
    // new auth state and renders WGSelection or NavBar. This takes the spinner
    // dialog with it, and is a no-op when this page is Wrapper's own child.
    navigator.popUntil((route) => route.isFirst);

    return null;
  }
}
