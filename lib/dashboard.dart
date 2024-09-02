import 'package:chores/widgets/dashboard_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chores/member_manager.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var db = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  String wgName = "-1";
  String wgID = "-1";
  String username = "-1";
  List<String> primaryRoles = [];
  List<List<String>> otherRoles = [];
  List<String> otherNames = [];
  Map<String, Map<String, bool>> tasks = {};
  MemberManager manager = MemberManager.instance;
  bool active = true;

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
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MemberManager.instance,
      builder: (BuildContext context, Widget? child) {
        manager.dataFuture = manager.fetchWGData();
        return FutureBuilder<void>(
            future: manager.dataFuture,
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  const Center(child: CircularProgressIndicator());
                  break;
                default:
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  tasks = manager.tasks;
                  primaryRoles = manager.primaryRoles;
                  otherRoles = manager.otherRoles;
                  username = manager.username;
                  otherNames = manager.otherNames;
                  active = manager.active;

                  return DashboardView(tasks: tasks,
                    primaryRoles: primaryRoles,
                    otherRoles: otherRoles, otherNames: otherNames, username: username, active: active);
              }
              return const Center(child: CircularProgressIndicator());
            });
      },
    );
  }

  void dashboardStateCallback() {
    setState(() {
      username = manager.username;
    });
  }
}
