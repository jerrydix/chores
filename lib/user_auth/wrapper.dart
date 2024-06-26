import 'package:chores/user_auth/pages/login.dart';
import 'package:chores/wg_selection.dart';
import 'package:chores/widgets/navigationbar.dart';
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
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance
        .authStateChanges()
        .listen((event) => updateUserState(event));
  }

  updateUserState(event) {
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

    return FutureBuilder<void>(
        future: fetchCurrentUser(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
              break;
            default:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (currentWgID == -1) {
                return WGSelection(username: auth.currentUser!.displayName!);
              }
              return const NavBar();
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        });
  }

  Future<void> fetchCurrentUser() async {
    await db.collection("users").doc(auth.currentUser?.uid).get().then((value) {
      currentWgID = value["wg"];
    });
  }

}