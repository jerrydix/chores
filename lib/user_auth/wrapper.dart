import 'package:chores/data/providers/authentication_provider.dart';
import 'package:chores/user_auth/pages/login.dart';
import 'package:chores/views/wg_selection.dart';
import 'package:chores/widgets/navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  User? user;
  bool firstRun = true;
  dynamic currentWgID;
  Future<void>? _userFuture;
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance
        .authStateChanges()
        .listen((event) => updateUserState(event));
  }

  void updateUserState(User? event) {
    if (firstRun) {
      firstRun = false;
      setState(() {
        user = event;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const LoginPage();
    }

    // Memoize so a rebuild doesn't kick off a fresh Firestore fetch.
    _userFuture ??= fetchCurrentUser();

    return FutureBuilder<void>(
        future: _userFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            default:
              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text('Error: ${snapshot.error}')),
                );
              }
              if (currentWgID == -1) {
                return WGSelection(
                    username: AuthenticationProvider.usernameOf(
                        auth.currentUser!));
              }
              return const NavBar();
          }
        });
  }

  Future<void> fetchCurrentUser() async {
    final doc = await db.collection("users").doc(auth.currentUser?.uid).get();
    currentWgID = doc["wg"];
  }
}
