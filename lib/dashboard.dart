import 'dart:ui';
import 'package:chores/widgets/dashboard_1.dart';
import 'package:chores/widgets/dashboard_2.dart';
import 'package:chores/widgets/dashboard_3.dart';
import 'package:chores/widgets/dashboard_4.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collection/src/boollist.dart';
import 'package:chores/member_manager.dart';


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
  late List<bool> tasks;

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

    MemberManager manager = MemberManager.instance;
    manager.fetchWGData();

    memberCount = manager.memberCount;
    tasks = manager.tasks;
    primaryRole = manager.primaryRole;
    otherRoles = manager.otherRoles;
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
              return Dashboard1(tasks: tasks, primaryRole: primaryRole, otherRoles: otherRoles, tasksAmount: 10,);
            case 2:
              //return Dashboard2(tasks: tasks, primaryRole: primaryRole, otherRoles: otherRoles);
            case 3:
              //return Dashboard3(tasks: tasks, primaryRole: primaryRole, otherRoles: otherRoles);
            case 4:
              //return Dashboard4(tasks: tasks, primaryRole: primaryRole, otherRoles: otherRoles);
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
