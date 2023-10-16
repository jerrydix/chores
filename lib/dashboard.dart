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
  int memberCount = -1;
  String wgName = "";
  String wgID = "";
  String username = "";
  int primaryRole = -1;
  List<int> otherRoles = [];
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
            primaryRole = manager.primaryRole;
            otherRoles = manager.otherRoles;
            print(memberCount);
            switch (memberCount) {
              case 1:
                return Dashboard1(tasks: tasks,
                  primaryRole: primaryRole,
                  otherRoles: otherRoles,);
              case 2:
              //return Dashboard2(tasks: tasks, primaryRole: primaryRole, otherRoles: otherRoles);
              case 3:
              //return Dashboard3(tasks: tasks, primaryRole: primaryRole, otherRoles: otherRoles);
              case 4:
              //return Dashboard4(tasks: tasks, primaryRole: primaryRole, otherRoles: otherRoles);

            }
            return Text("ERROR fetching data (data is $memberCount; $tasks; $primaryRole; $otherRoles)");
        }
        return const Center(child: CircularProgressIndicator());
    });
  }
}
