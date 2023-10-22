import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chores/user_auth/authentication_provider.dart';
import 'package:chores/user_auth/pages/login.dart';
import 'package:chores/user_auth/widgets/form_container.dart';
import 'package:chores/widgets/navigationbar.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:keybinder/keybinder.dart';

import '../../wg_selection.dart';



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


  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(child: Scaffold(
      body: Center(
        child: Padding(
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
              const Text(
                "Sign Up to Chores",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 30,
              ),
              FormContainer(
                controller: _usernameController,
                hintText: "Username",
                isPasswordField: false,
              ),
              const SizedBox(
                height: 10,
              ),
              FormContainer(
                controller: _emailController,
                hintText: "Email",
                isPasswordField: false,
              ),
              const SizedBox(
                height: 10,
              ),
              FormContainer(
                controller: _passwordController,
                hintText: "Password",
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
                  splashColor: Theme.of(context).colorScheme.surfaceTint.withOpacity(0.75),
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
                    child: Center(child: Text("Sign Up", style: TextStyle(color: Theme.of(context).colorScheme.surface, fontWeight: FontWeight.bold, fontSize: 17),)),
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  const SizedBox(width: 5,),
                  InkWell(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                            context, MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
                      },
                      borderRadius: BorderRadius.circular(5),
                      child: Text("Login", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),))
                ],
              )
            ],
          ),
        ),
      ),
    ),);
  }

  Future<Future<bool?>?> _signUp() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    FirebaseAuth auth = FirebaseAuth.instance;
    const CircularProgressIndicator();
    String? message = await AuthenticationProvider(auth).signUp(email: email, password: password);
    User? user = auth.currentUser;

    if (message != null) {
      return Fluttertoast.showToast(
        msg: message,
        textColor: Theme.of(context).colorScheme.error,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
    Keybinder.remove(enterButton, onPressed);

    if (user != null) {
      await user.updateDisplayName(username);
    }

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => WGSelection(username: username),
        ), (route) => false
    );

    return null;
  }
}
