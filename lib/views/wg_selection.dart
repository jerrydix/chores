
import 'package:chores/data/providers/authentication_provider.dart';
import 'package:chores/user_auth/pages/login.dart';
import 'package:chores/widgets/navigation_bar.dart';
import 'package:chores/widgets/wg_list_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chores/l10n/app_localizations.dart';
import '../data/wg_repository.dart';
import 'package:week_of_year/date_week_extensions.dart';

/// Default roles & chores seeded into a new WG when "use template" is checked.
List<Map<String, dynamic>> buildTemplateRolesConfig(AppLocalizations loc) {
  Map<String, dynamic> task(String name, IconData icon) => {
        "name": name,
        "codePoint": icon.codePoint,
        "fontFamily": icon.fontFamily,
      };
  Map<String, dynamic> role(
          String name, IconData icon, List<Map<String, dynamic>> tasks) =>
      {
        "name": name,
        "iconCodePoint": icon.codePoint,
        "iconFontFamily": icon.fontFamily,
        "tasks": tasks,
      };

  return [
    role(loc.garbage, Icons.delete, [
      task(loc.g100plastic, Icons.recycling),
      task(loc.g101residual, Icons.delete_outline),
      task(loc.g102organic, Icons.compost),
      task(loc.g103paper, Icons.newspaper),
      task(loc.g104glass, Icons.wine_bar),
      task(loc.g105bottles, Icons.local_drink),
    ]),
    role(loc.bathroom, Icons.bathtub, [
      task(loc.b206mirrors, Icons.cleaning_services),
      task(loc.b207sink, Icons.wash),
      task(loc.b208bath, Icons.bathtub),
      task(loc.b209toilet, Icons.wc),
      task(loc.b210dust, Icons.cleaning_services),
      task(loc.b211carpet, Icons.layers),
      task(loc.b212towel, Icons.dry_cleaning),
      task(loc.b213b_waste, Icons.delete_outline),
    ]),
    role(loc.kitchen, Icons.countertops, [
      task(loc.b314surfaces, Icons.cleaning_services),
      task(loc.b315stove, Icons.microwave),
      task(loc.b316fridge, Icons.kitchen),
      task(loc.b317cloths, Icons.local_laundry_service),
    ]),
    role(loc.vacuum, Icons.cleaning_services, [
      task(loc.b418v_kitchen, Icons.countertops),
      task(loc.b419v_bath, Icons.bathtub),
      task(loc.b420v_living, Icons.weekend),
      task(loc.b421v_stairs, Icons.stairs),
      task(loc.b422v_corridor, Icons.meeting_room),
      task(loc.b423wipe, Icons.water_drop),
    ]),
  ];
}

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
                    final loc = AppLocalizations.of(context)!;
                    final wgName = _wgNameController.text.trim();
                    if (wgName.isEmpty) return;

                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );

                    final db = FirebaseFirestore.instance;
                    final nameCheck = await db
                        .collection("wgs")
                        .where("name", isEqualTo: wgName)
                        .get();
                    if (nameCheck.docs.isNotEmpty) {
                      if (!context.mounted) return;
                      Navigator.pop(context); // close loading indicator
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(loc.wg_exists),
                        duration: const Duration(seconds: 2),
                      ));
                      return;
                    }

                    final rolesConfig = useWgTemplate
                        ? buildTemplateRolesConfig(loc)
                        : <Map<String, dynamic>>[];
                    final tasks = {
                      for (final role in rolesConfig)
                        role["name"] as String: {
                          for (final task in role["tasks"] as List)
                            task["name"] as String: false,
                        },
                    };

                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    final wgRef = await db.collection("wgs").add({
                      "name": wgName,
                      "count": 1,
                      // Member slots live on the WG doc so joins can allocate
                      // one inside a transaction (see WgRepository.join).
                      "memberIDs": [0],
                      "maxMembers": kDefaultMaxWgMembers,
                      "cw": DateTime.now().weekOfYear,
                      "tasks": tasks,
                      "rolesConfig": rolesConfig,
                      "algorithmType": "rotating",
                      "noRepeatWindow": 1,
                    });

                    // Key the member doc by uid so leaving the WG (which
                    // deletes members/<uid>) also works for the creator.
                    await wgRef.collection("members").doc(uid).set({
                      "uid": uid,
                      "username": widget.username,
                      "active": true,
                      "memberID": 0,
                    });

                    await db.collection("users").doc(uid).update({
                      "wg": wgRef.id,
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
