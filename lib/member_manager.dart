import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:week_of_year/date_week_extensions.dart';
import 'utils/chore_assigner.dart';

class MemberManager with ChangeNotifier {
  static final MemberManager _instance = MemberManager._internal();
  static MemberManager get instance => _instance;

  var db = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  String? userID;
  String currentWgID = "-1";
  int wgCW = -1;
  int memberCount = -1;
  String wgName = "-1";
  String username = "-1";
  int primaryIndex = -1;
  Map<String, Map<String, bool>> tasks = {};
  // role → task → icon (loaded from rolesConfig)
  Map<String, Map<String, IconData?>> taskIcons = {};
  // role → role icon (loaded from rolesConfig)
  Map<String, IconData?> roleIcons = {};
  List<String> primaryRoles = [];
  List<List<String>> otherRoles = [];
  List<String> members = [];
  Future<void> dataFuture = Future(() => null);
  bool active = true;
  int noRepeatWindow = 1;
  ChoreAssigner? choreAssigner;

  MemberManager._internal();

  Future<void> fetchWGData() async {
    user = FirebaseAuth.instance.currentUser;
    userID = user!.uid;

    final userDoc = await db.collection("users").doc(userID).get();
    currentWgID = userDoc["wg"] as String;

    final wgDoc = await db.collection("wgs").doc(currentWgID).get();
    final wgData = wgDoc.data()!;
    wgCW = wgData["cw"] as int;
    wgName = wgData["name"] as String;

    // Load role/task definitions and icon data from rolesConfig
    final Map<String, Map<String, IconData?>> iconMaps = {};
    final Map<String, IconData?> roleIconMap = {};
    final rawConfig = wgData["rolesConfig"];
    if (rawConfig is List) {
      for (final roleEntry in rawConfig) {
        final roleName = roleEntry["name"] as String;
        final roleIconCodePoint = roleEntry["iconCodePoint"] as int?;
        final roleIconFontFamily = roleEntry["iconFontFamily"] as String?;
        roleIconMap[roleName] = roleIconCodePoint != null
            ? IconData(roleIconCodePoint,
                fontFamily: roleIconFontFamily ?? 'MaterialIcons')
            : null;
        iconMaps[roleName] = {};
        final rawTasks = roleEntry["tasks"] as List?;
        if (rawTasks != null) {
          for (final taskEntry in rawTasks) {
            final taskName = taskEntry["name"] as String;
            final codePoint = taskEntry["codePoint"] as int?;
            final fontFamily = taskEntry["fontFamily"] as String?;
            iconMaps[roleName]![taskName] = codePoint != null
                ? IconData(codePoint, fontFamily: fontFamily ?? 'MaterialIcons')
                : null;
          }
        }
      }
    }
    taskIcons = iconMaps;
    roleIcons = roleIconMap;

    // Parse tasks completion map from Firestore
    Map<String, Map<String, bool>> taskMaps = {};
    final rawTasks = wgData["tasks"];
    if (rawTasks is Map) {
      for (final roleEntry in rawTasks.entries) {
        final roleKey = roleEntry.key as String;
        final roleValue = roleEntry.value;
        if (roleValue is Map) {
          taskMaps[roleKey] = {};
          for (final taskEntry in roleValue.entries) {
            taskMaps[roleKey]![taskEntry.key as String] =
                taskEntry.value as bool? ?? false;
          }
        }
      }
    }

    // Reset task completion if a new week has started
    final currentWeek = DateTime.now().weekOfYear;
    if (wgCW != currentWeek) {
      for (final role in taskMaps.values) {
        for (final key in role.keys.toList()) {
          role[key] = false;
        }
      }
      await db.collection("wgs").doc(currentWgID).update({
        "cw": currentWeek,
        "tasks": taskMaps,
      });
      wgCW = currentWeek;
    }

    tasks = taskMaps;

    // Load members ordered by memberID
    final membersSnapshot = await db
        .collection("wgs")
        .doc(currentWgID)
        .collection("members")
        .orderBy("memberID")
        .get();

    members = [];
    int j = 0;
    primaryIndex = -1;

    for (final doc in membersSnapshot.docs) {
      final currentID = doc["uid"] as String;
      final currentName = doc["username"] as String;

      if (currentID == userID) {
        username = currentName;
        active = doc["active"] as bool? ?? true;
        if (active) {
          primaryIndex = j;
        }
        continue;
      }
      if (doc["active"] as bool? ?? false) {
        members.add(currentName);
        j++;
      }
    }
    memberCount = active ? members.length + 1 : members.length;

    // Assign roles via ChoreAssigner
    primaryRoles = [];
    // Always keep otherRoles parallel to members (empty lists when no tasks)
    otherRoles = List.generate(members.length, (_) => <String>[]);

    if (tasks.isNotEmpty && memberCount > 0) {
      final allMembers = List<String>.from(members);
      if (active && primaryIndex >= 0) {
        allMembers.insert(primaryIndex, username);
      }

      choreAssigner =
          ChoreAssigner(allMembers, tasks.keys.toList(), noRepeatWindow);
      final assignments = choreAssigner!.assignRoles(currentWeek);

      primaryRoles = active ? (assignments[username] ?? []) : [];
      otherRoles =
          members.map((m) => assignments[m] ?? <String>[]).toList();
    }
  }

  void refresh() => notifyListeners();

  Future<void> updateActive(bool value) async {
    active = value;
    notifyListeners();
    db
        .collection("wgs")
        .doc(currentWgID)
        .collection("members")
        .doc(userID)
        .update({"active": value});
  }
}
