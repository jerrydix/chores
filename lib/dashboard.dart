import 'dart:ui';
import 'package:chores/widgets/dashboard_1.dart';
import 'package:chores/widgets/dashboard_2.dart';
import 'package:chores/widgets/dashboard_3.dart';
import 'package:chores/widgets/dashboard_4.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collection/src/boollist.dart';


class CurrentPage extends StatefulWidget {
  const CurrentPage({super.key});

  @override
  State<CurrentPage> createState() => _CurrentPageState();
}

class _CurrentPageState extends State<CurrentPage> {
  var db = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  late int memberCount;
  late String wgName;
  late String wgID;
  late String username;
  late int primaryRole;
  late List<int> otherRoles;
  late BoolList completedTasks;

  CheckboxListTile createCheckboxTile(Icon icon, Text text, bool? checked) {
    return CheckboxListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        checkboxShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: text,
        value: checked,
        onChanged: (value) {
          setState(() {
            checked = value!;
          });
        },
        secondary: icon);
  }

  @override
  void initState() {
    super.initState();
    String userID = user!.uid;

    db.collection("users").doc(userID).get().then((value) {
      wgID = value["wg"];
    });

    db.collection("wgs").doc(wgID).get().then((value) {
        memberCount = value["count"];
    });

    db.collection("wgs").doc(wgID).get().then((value) {
        completedTasks = BoolList.of(value["tasks"]);
    });

    db.collection("wgs").doc(wgID).collection("members").doc(userID).get().then((value) {
        primaryRole = value["role"];
    });

    if (memberCount > 1) {
      db.collection("wgs").doc(wgID).collection("members").where("uid", isNotEqualTo: userID).get().then((value) {
        otherRoles = [];
        for (int i = 0; i < value.docs.length; i++) {
          otherRoles.add(value.docs[i]["role"]);
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: db.collection("wgs").doc("wgID")
            .collection("tasks")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          switch (memberCount) {
            case 1:
              return Dashboard1(tasksAmount: 10, primaryRole: primaryRole, otherRoles: otherRoles, completedTasks: completedTasks);
            case 2:
              return Dashboard2(tasksAmount: 10);
            case 3:
              return Dashboard3(tasksAmount: 10);
            case 4:
              return Dashboard4(tasksAmount: 10);
          }
          return const Text("ERROR fetching memberCount");
        });
  }
}

class CheckboxTile extends StatefulWidget {
  CheckboxTile(
      {super.key,
      required this.title,
      required this.style,
      required this.checked,
      required this.icon});

  String title = "";
  TextStyle style = const TextStyle(
    decoration: TextDecoration.none,
  );
  bool checked = false;
  Icon icon = const Icon(Icons.delete);

  @override
  State<CheckboxTile> createState() =>
      _CheckboxTileState(title, style, checked, icon);
}

class _CheckboxTileState extends State<CheckboxTile> {
  _CheckboxTileState(this.title, this.style, this.checked, this.icon);

  String title = "";
  TextStyle style = const TextStyle(
    decoration: TextDecoration.none,
  );
  bool checked = false;
  Icon icon = const Icon(Icons.delete);

  void styleSwitcher(bool value) {
    if (value) {
      style = TextStyle(
          decoration: TextDecoration.lineThrough,
          color: style.color?.withOpacity(0.75));
    } else {
      style = TextStyle(
          decoration: TextDecoration.none, color: style.color?.withOpacity(1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        checkboxShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: Text(title, style: style),
        value: checked,
        onChanged: (value) {
          setState(() {
            checked = value!;
            styleSwitcher(value);
          });
        },
        secondary: icon);
  }
}
