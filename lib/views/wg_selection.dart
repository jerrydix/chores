
import 'package:chores/data/providers/authentication_provider.dart';
import 'package:chores/user_auth/pages/login.dart';
import 'package:chores/widgets/navigation_bar.dart';
import 'package:chores/widgets/wg_list_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chores/l10n/app_localizations.dart';
import 'package:week_of_year/date_week_extensions.dart';

class WGSelection extends StatefulWidget {
  final String username;
  const WGSelection({super.key, required this.username});

  @override
  State<StatefulWidget> createState() => _WGSelectionState();
}

class _WGSelectionState extends State<WGSelection> {

  Map<String, int> entries = {};
  bool useWgTemplate = false;
  final _wgNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _wgNameController.dispose();
    super.dispose();
  }

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

  Future openNewWGDialog() {


    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              AppLocalizations.of(context)!.new_wg,
              style: const TextStyle(fontSize: 20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _wgNameController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.wg_name,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                StatefulBuilder(
                  builder: (context, setState) {
                    return CheckboxListTile(
                      title: Text(AppLocalizations.of(context)!.wg_use_template),
                      //contentPadding: const EdgeInsets.all(5),
                      checkboxShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      value: useWgTemplate,
                      onChanged: (var value) {
                        setState(() {
                          useWgTemplate = value!;
                        });
                      },
                    );
                  }
                )
              ],

            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.cancel)),
              TextButton(
                  onPressed: () async {

                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );

                    final nameCheck = await FirebaseFirestore.instance.collection("wgs").where("name", isEqualTo: _wgNameController.text).get();
                    if (nameCheck.docs.isNotEmpty) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(AppLocalizations.of(context)!.wg_exists),
                        duration: const Duration(seconds: 2),
                      ));
                    }

                      await FirebaseFirestore.instance.collection("wgs").add({
                        "name": _wgNameController.text,
                        "count": 1,
                        "cw": DateTime.now().weekOfYear,
                        "tasks": <String, dynamic>{},
                        "rolesConfig": <dynamic>[],
                      });

                      var wgID = "";

                      await FirebaseFirestore.instance.collection("wgs").where("name", isEqualTo: _wgNameController.text).get().then((value) {
                        for (var element in value.docs) {
                          FirebaseFirestore.instance.collection("wgs").doc(element.id).collection("members").add({
                            "uid": FirebaseAuth.instance.currentUser?.uid,
                            "username": widget.username,
                            "active": true,
                            "memberID": 0,
                          });
                          wgID = element.id;
                        }
                      });

                      await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser?.uid).update({
                        "wg": wgID,
                      });

                      if (!context.mounted) return;
                      Navigator.pop(context);
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const NavBar(),
                        ), (route) => false
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.confirm)),
            ],
          );
        });
  }

    @override
    Widget build(BuildContext context) {
      var db = FirebaseFirestore.instance;

      return StreamBuilder<QuerySnapshot>(
        stream: db.collection("wgs").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
                appBar: AppBar(
                  title: Text(AppLocalizations.of(context)!.select_wg),
                ),
                body: const Center(child: CircularProgressIndicator()));
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.select_wg),
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
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                return WGListTile(name: snapshot.data!.docs[index]["name"], count: snapshot.data!.docs[index]["count"], uid: snapshot.data!.docs[index].id, username: widget.username);
              },
              separatorBuilder: (BuildContext context, int index) => const Divider(
                indent: 10,
                endIndent: 10,
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                openNewWGDialog();
              },
              child: const Icon(Icons.add),
            ),
          );
        },
      );
    }
  }
