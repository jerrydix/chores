
import 'package:chores/user_auth/authentication_provider.dart';
import 'package:chores/user_auth/pages/login.dart';
import 'package:chores/widgets/wg_listtile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:chores/settings.dart';

class WGSelection extends StatefulWidget {
  final String username;
  const WGSelection({super.key, required this.username});

  @override
  State<StatefulWidget> createState() => _WGSelectionState();
}

class _WGSelectionState extends State<WGSelection> {

  Map<String, int> entries = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var db = FirebaseFirestore.instance;

    Future openLogoutDialog() => showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              AppLocalizations.of(context)!.logout_t,
              style: const TextStyle(fontSize: 20),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.cancel)),
              TextButton(
                  onPressed: () {
                    AuthenticationProvider(FirebaseAuth.instance).signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ), (route) => false
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.confirm)),
            ],
          );
        });

    return StreamBuilder<QuerySnapshot>(
      stream: db.collection("wgs").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return SelectionArea(
            child: Scaffold(
                appBar: AppBar(
                  title: Text(AppLocalizations.of(context)!.select_wg),
                ),
                body: const Center(child: CircularProgressIndicator())));
        }

        return SelectionArea(
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Select WG"),
              actions: <Widget>[
                Container(
                  padding: const EdgeInsets.only(right: 10),
                  child: ElevatedButton(onPressed: () {
                    openLogoutDialog();
                  }, child: Text(AppLocalizations.of(context)!.logout)),
                ),
              ],
            ),
            body: ListView.separated(
              //padding: const EdgeInsets.all(8),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                return WGListTile(name: snapshot.data!.docs[index]["name"], count: snapshot.data!.docs[index]["count"], uid: snapshot.data!.docs[index].id, username: widget.username);
              },
              separatorBuilder: (BuildContext context, int index) => const Divider(
                indent: 10,
                endIndent: 10,
              ),
            ),
          )
        );
      },
    );
  }
}