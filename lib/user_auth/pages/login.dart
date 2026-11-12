import 'package:chores/user_auth/widgets/auth_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chores/user_auth/widgets/form_container.dart';
import 'package:chores/user_auth/pages/signup.dart';
import 'package:chores/data/providers/authentication_provider.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:keybinder/keybinder.dart';
import '../../l10n/app_localizations.dart';
import 'package:chores/data/user_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _emailResetController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final enterButton = Keybinding.from({LogicalKeyboardKey.enter});

  @override
  void initState() {
    super.initState();
    Keybinder.bind(enterButton, onPressed);
  }

  void onPressed() {
    _signIn();
  }

  @override
  void dispose() {
    Keybinder.remove(enterButton, onPressed);
    _emailController.dispose();
    _emailResetController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future _resetPassword() async {
    String email = _emailResetController.text;
    await AuthenticationProvider(FirebaseAuth.instance)
        .sendPasswordResetEmail(email.trim());
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

  Future openForgotPasswordDialog() async {
    return showDialog(
        barrierDismissible: true,
        //animationType: DialogTransitionType.fade,
        //duration: const Duration(milliseconds: 300),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.reset_pw),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.reset_pw_t),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailResetController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.email,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      _emailResetController.clear();
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)!.cancel)),
                TextButton(
                    onPressed: () {
                      _resetPassword();
                      _emailResetController.clear();
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)!.reset_pw_b)),
              ],
            );
          });
        }).then((value) => _emailResetController.clear());
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;

    return SelectionArea(
      child: Scaffold(
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
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  loc.login,
                  style: const TextStyle(
                      fontSize: 27, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 30,
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
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.5, right: 2),
                    child: InkWell(
                        onTap: () {
                          openForgotPasswordDialog();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Text(
                          loc.forgot_pw,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        )),
                  ),
                ]),
                const SizedBox(
                  height: 20,
                ),
                Material(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    splashColor: Theme.of(context)
                        .colorScheme
                        .surfaceTint
                        .withValues(alpha: 0.75),
                    enableFeedback: true,
                    onTap: _signIn,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      width: double.infinity,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                          child: Text(
                        loc.login_b,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                            fontWeight: FontWeight.bold,
                            fontSize: 17),
                      )),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            loc.or,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5)),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    )),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AuthButton(
                        imagePath: "assets/google_logo.png",
                        onTap: _signUpWithGoogle),
                    const SizedBox(
                      width: 25,
                    ),
                    AuthButton(
                        imagePath: "assets/github-mark.png",
                        onTap: _signUpWithGithub),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(loc.noAccount),
                    const SizedBox(
                      width: 5,
                    ),
                    InkWell(
                        onTap: () {
                          // Push, never wipe: Wrapper owns the root
                          // route and does all post-auth routing, so
                          // removing it leaves nothing to route with.
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUpPage()));
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Text(
                          loc.signup_b,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold),
                        ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

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

    String? message = await AuthenticationProvider(FirebaseAuth.instance)
        .signIn(email: email, password: password);

    if (message != null) {
      // Failure: drop the spinner only, so the user can correct and retry.
      if (navigator.canPop()) navigator.pop();
      return Fluttertoast.showToast(
        msg: message,
        textColor: errorColor,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
      );
    }

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
