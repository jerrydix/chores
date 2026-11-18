import 'dart:async';

import 'package:chores/data/providers/authentication_provider.dart';
import 'package:chores/data/user_repository.dart';
import 'package:chores/member_manager.dart';
import 'package:chores/user_auth/pages/login.dart';
import 'package:chores/views/wg_selection.dart';
import 'package:chores/widgets/navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  User? user;
  String? _loadedForUid;
  Stream<({bool exists, String? wgId})>? _wgStream;
  StreamSubscription<User?>? _authSubscription;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    user = auth.currentUser;
    // Every auth change matters, not just the first: signing out has to fall
    // back to the login page, and signing in as somebody else has to re-read
    // that account's WG rather than reusing the previous user's.
    _authSubscription = auth.authStateChanges().listen(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _onAuthStateChanged(User? event) {
    if (!mounted) return;
    if (event?.uid == user?.uid) return;
    if (event == null) {
      // Signed out — drop the cached household with the session.
      MemberManager.instance.reset();
    }
    setState(() {
      user = event;
      _wgStream = null;
      _loadedForUid = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = user;
    if (currentUser == null) {
      return const LoginPage();
    }

    // Memoized per uid: building the stream inside build() would resubscribe
    // on every rebuild, while a different account still gets its own listener.
    if (_wgStream == null || _loadedForUid != currentUser.uid) {
      _loadedForUid = currentUser.uid;
      _wgStream = UserRepository.watchWgState(currentUser.uid);
    }

    return StreamBuilder<({bool exists, String? wgId})>(
        stream: _wgStream,
        builder: (BuildContext context,
            AsyncSnapshot<({bool exists, String? wgId})> snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          }
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.requireData.wgId == null) {
            return WGSelection(
                username: AuthenticationProvider.usernameOf(currentUser));
          }
          return const NavBar();
        });
  }
}
