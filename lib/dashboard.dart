import 'dart:ui';
import 'package:chores/widgets/dashboard_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collection/src/boollist.dart';
import 'package:chores/member_manager.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var db = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  int memberCount = -1;
  String wgName = "-1";
  String wgID = "-1";
  String username = "-1";
  List<int> primaryRoles = [];
  List<List<int>> otherRoles = [];
  List<String> otherNames = [];
  List<bool> tasks = [];

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
  Widget build(BuildContext context) {
    MemberManager manager = MemberManager.instance;
    return FutureBuilder<void>(
      future: manager.fetchWGData(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            const Center(child: CircularProgressIndicator());
            break;
          default:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            memberCount = manager.memberCount;
            tasks = manager.tasks;
            primaryRoles = manager.primaryRoles;
            otherRoles = manager.otherRoles;
            username = manager.username;
            otherNames = manager.otherNames;

            return DashboardView(tasks: tasks,
              primaryRoles: primaryRoles,
              otherRoles: otherRoles, otherNames: otherNames, username: username,);
        }
        return const Center(child: CircularProgressIndicator());
    });
  }
}
