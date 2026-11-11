import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:week_of_year/date_week_extensions.dart';
import 'data/user_repository.dart';
import 'utils/chore_assigner.dart';

/// Thrown when the WG a user still points at no longer exists.
class WgMissingException implements Exception {
  final String wgID;
  const WgMissingException(this.wgID);
  @override
  String toString() => 'WG $wgID no longer exists';
}

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
  // Display names of the other active members, and their uids at the same
  // indices. Assignment is keyed by uid (names are not unique), the names are
  // only for display.
  List<String> members = [];
  List<String> memberUids = [];
  Future<void> dataFuture = Future(() => null);
  bool active = true;
  int noRepeatWindow = 1;
  AssignmentAlgorithm algorithm = AssignmentAlgorithm.rotating;
  RoleAssigner? choreAssigner;

  MemberManager._internal();

  /// Drops every cached field so the next fetch starts clean.
  ///
  /// Must run on sign-out: this is a singleton, and without it the next
  /// account to sign in on the device keeps [currentWgID] from the previous
  /// one and loads that user's WG instead of its own.
  void reset() {
    user = null;
    userID = null;
    currentWgID = "-1";
    wgCW = -1;
    memberCount = -1;
    wgName = "-1";
    username = "-1";
    primaryIndex = -1;
    tasks = {};
    taskIcons = {};
    roleIcons = {};
    primaryRoles = [];
    otherRoles = [];
    members = [];
    memberUids = [];
    dataFuture = Future(() => null);
    active = true;
    noRepeatWindow = 1;
    algorithm = AssignmentAlgorithm.rotating;
    choreAssigner = null;
    notifyListeners();
  }

  Future<void> fetchWGData() async {
    user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    if (uid == null) {
      reset();
      return;
    }
    // Belt and braces alongside reset() on sign-out: if the signed-in account
    // changed under us, never reuse the previous user's cached WG.
    if (userID != null && userID != uid) {
      reset();
      user = FirebaseAuth.instance.currentUser;
    }
    userID = uid;

    if (currentWgID == "-1") {
      final wgID = await UserRepository.fetchWgId(uid);
      if (wgID == null) {
        // No WG yet (or the user just left one) — nothing to load.
        memberCount = -1;
        return;
      }
      currentWgID = wgID;
    }

    // Fetch WG doc and members subcollection in parallel
    final wgFuture = db.collection("wgs").doc(currentWgID).get();
    final membersFuture = db
        .collection("wgs")
        .doc(currentWgID)
        .collection("members")
        .orderBy("memberID")
        .get();

    final wgDoc = await wgFuture;
    final wgData = wgDoc.data();
    if (wgData == null) {
      // The WG was deleted (e.g. the last other member left). Detach the user
      // from it rather than null-crashing on every later read.
      final staleID = currentWgID;
      currentWgID = "-1";
      await UserRepository.clearWgId(uid);
      throw WgMissingException(staleID);
    }
    wgCW = wgData["cw"] as int;
    wgName = wgData["name"] as String;
    noRepeatWindow = (wgData["noRepeatWindow"] as int?) ?? 1;
    algorithm =
        AssignmentAlgorithm.fromString(wgData["algorithmType"] as String?);

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

    // Reset task completion if a new week has started. Every member's app
    // reaches this independently, so the check and the write have to happen
    // in one transaction or the first client back online can clobber ticks
    // another member already made in the new week.
    final currentWeek = DateTime.now().weekOfYear;
    if (wgCW != currentWeek) {
      taskMaps = await _resetTasksForNewWeek(currentWeek, taskMaps);
      wgCW = currentWeek;
    }

    tasks = taskMaps;

    // Await the members fetch that was started in parallel with the WG doc fetch
    final membersSnapshot = await membersFuture;

    members = [];
    memberUids = [];
    int j = 0;
    primaryIndex = -1;

    for (final doc in membersSnapshot.docs) {
      final data = doc.data();
      final currentID = (data["uid"] as String?) ?? doc.id;
      final currentName = data["username"] as String? ?? currentID;

      if (currentID == userID) {
        username = currentName;
        active = data["active"] as bool? ?? true;
        if (active) {
          primaryIndex = j;
        }
        continue;
      }
      if (data["active"] as bool? ?? false) {
        members.add(currentName);
        memberUids.add(currentID);
        j++;
      }
    }
    memberCount = active ? members.length + 1 : members.length;

    // Assign roles via ChoreAssigner
    _recomputeAssignments(currentWeek);
  }

  /// Clears every task tick and stamps the new week, atomically.
  ///
  /// Returns the task map that ended up in Firestore — which may be another
  /// client's reset rather than ours if they got there first.
  Future<Map<String, Map<String, bool>>> _resetTasksForNewWeek(
    int currentWeek,
    Map<String, Map<String, bool>> fallback,
  ) async {
    final ref = db.collection("wgs").doc(currentWgID);
    try {
      return await db.runTransaction((tx) async {
        final snap = await tx.get(ref);
        final data = snap.data();
        if (data == null) return fallback;
        if ((data["cw"] as int?) == currentWeek) {
          // Another member already rolled the week over; keep their state.
          final raw = data["tasks"];
          if (raw is! Map) return fallback;
          return {
            for (final role in raw.entries)
              role.key as String: {
                if (role.value is Map)
                  for (final task in (role.value as Map).entries)
                    task.key as String: task.value as bool? ?? false,
              },
          };
        }
        final raw = data["tasks"];
        final cleared = <String, Map<String, bool>>{};
        if (raw is Map) {
          for (final role in raw.entries) {
            final value = role.value;
            cleared[role.key as String] = {
              if (value is Map)
                for (final task in value.keys) task as String: false,
            };
          }
        }
        tx.update(ref, {"cw": currentWeek, "tasks": cleared});
        return cleared;
      });
    } on FirebaseException catch (e) {
      debugPrint("Week rollover failed: ${e.message}");
      return fallback;
    }
  }

  void _recomputeAssignments(int week) {
    primaryRoles = [];
    // Always keep otherRoles parallel to members (empty lists when no tasks)
    otherRoles = List.generate(members.length, (_) => <String>[]);

    if (tasks.isNotEmpty && memberCount > 0 && userID != null) {
      // Key the assigner by uid: two housemates can share a display name, and
      // name keys would collapse them into one entry — handing both the same
      // roles and skewing the fairness counter.
      final allUids = List<String>.from(memberUids);
      if (active && primaryIndex >= 0) {
        allUids.insert(primaryIndex, userID!);
      }

      choreAssigner = RoleAssigner.create(
        algorithm,
        allUids,
        tasks.keys.toList(),
        noRepeatWindow: noRepeatWindow,
      );
      final assignments = choreAssigner!.assignRoles(week);

      primaryRoles = active ? (assignments[userID] ?? []) : [];
      otherRoles =
          memberUids.map((uid) => assignments[uid] ?? <String>[]).toList();
    }
  }

  void refresh() => notifyListeners();

  Future<void> updateAlgorithm(AssignmentAlgorithm value) async {
    algorithm = value;
    _recomputeAssignments(DateTime.now().weekOfYear);
    notifyListeners();
    await db.collection("wgs").doc(currentWgID).update({
      "algorithmType": value.toFirestoreString(),
    });
  }

  Future<void> updateActive(bool value) async {
    active = value;
    notifyListeners();
    await db
        .collection("wgs")
        .doc(currentWgID)
        .collection("members")
        .doc(userID)
        .update({"active": value});
    // Re-fetch so memberCount, primaryIndex and role assignments reflect
    // the new availability instead of staying stale until a manual refresh.
    dataFuture = fetchWGData();
    await dataFuture;
    notifyListeners();
  }
}
