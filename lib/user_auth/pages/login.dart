import 'package:chores/user_auth/pages/forgot_password.dart';
import 'package:chores/user_auth/widgets/AuthButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chores/user_auth/widgets/form_container.dart';
import 'package:chores/user_auth/pages/signup.dart';
import 'package:chores/user_auth/authentication_provider.dart';
import 'package:chores/widgets/navigationbar.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:keybinder/keybinder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../wg_selection.dart';


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
    _emailController.dispose();
    _emailResetController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future _resetPassword() async {
    String email = _emailResetController.text;
    await AuthenticationProvider(FirebaseAuth.instance).sendPasswordResetEmail(email.trim());
  }

  Future openForgotPasswordDialog() async {
    return showDialog(
        barrierDismissible: true,
        //animationType: DialogTransitionType.fade,
        //duration: const Duration(milliseconds: 300),
        context: context,
        builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.reset_pw),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.reset_pw_t),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailResetController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.email,
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
        }
    );}).then((value) => _emailResetController.clear());
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
                borderRadius: BorderRadius.circular(20),
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
                loc.login,
                style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 30,
              ),
              FormContainer(
                controller: _emailController,
                hintText: loc.email,
                isPasswordField: false,
              ),
              const SizedBox(height: 10,),
              FormContainer(
                controller: _passwordController,
                hintText: loc.pw,
                isPasswordField: true,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.5, right: 2),
                    child: InkWell(
                        onTap: () {
                          openForgotPasswordDialog();
                        },
                        borderRadius: BorderRadius.circular(5),
                        child: Text(loc.forgot_pw, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold,), textAlign: TextAlign.right,)),
                  ),
                  ]
              ),
              const SizedBox(height: 20,),
              Material(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  splashColor: Theme.of(context).colorScheme.surfaceTint.withOpacity(0.75),
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
                    child: Center(child: Text(loc.login_b, style: TextStyle(color: Theme.of(context).colorScheme.surface, fontWeight: FontWeight.bold, fontSize: 17),)),
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
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(loc.or, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
                  Text(loc.noAccount),
                  const SizedBox(width: 5,),
                  InkWell(
                      onTap: (){
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const SignUpPage()), (route) => false);
                      },
                      borderRadius: BorderRadius.circular(5),
                      child: Text(loc.signup_b, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),))
                ],
              ),
            ],
          ),
        ),
      ),
    ),);
  }

  Future<dynamic> _signIn() async {

    String email = _emailController.text;
    String password = _passwordController.text;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    String? message = await AuthenticationProvider(FirebaseAuth.instance).signIn(email: email, password: password);

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

    dynamic currentWgID;
    await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser?.uid).get().then((value) {
      currentWgID = value["wg"];
    });

    if (currentWgID == -1) {
      return Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => WGSelection(
                  username: FirebaseAuth.instance.currentUser!.displayName!)
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

  Future<dynamic> _signUpWithGoogle() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;

    await AuthenticationProvider(auth).signInWithGoogle();

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

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

    dynamic currentWgID;
    await db.collection("users").doc(auth.currentUser?.uid).get().then((snap) => {
      if (snap.exists) {
        currentWgID = snap["wg"]
      } else {
        db.collection("users").doc(auth.currentUser?.uid).set({
          "username": user.displayName,
          "wg": -1,
        }),
        currentWgID = -1
      }
    });

    Navigator.pop(context);

    if (currentWgID == -1) {
      return Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => WGSelection(
                  username: FirebaseAuth.instance.currentUser!.displayName!)
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
    FirebaseFirestore db = FirebaseFirestore.instance;

    GithubAuthProvider githubProvider = GithubAuthProvider();

    try {
      await auth.signInWithPopup(githubProvider);
    } catch (e) {
      print(e);
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

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

    dynamic currentWgID;
    await db.collection("users").doc(auth.currentUser?.uid).get().then((snap) => {
      if (snap.exists) {
        currentWgID = snap["wg"]
      } else {
        db.collection("users").doc(auth.currentUser?.uid).set({
          "username": user.displayName,
          "wg": -1,
        }),
        currentWgID = -1
      }
    });

    Navigator.pop(context);

    if (currentWgID == -1) {
      return Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => WGSelection(
                  username: FirebaseAuth.instance.currentUser!.displayName!)
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