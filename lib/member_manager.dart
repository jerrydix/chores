import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:week_of_year/date_week_extensions.dart';

class MemberManager {
  static final MemberManager _instance = MemberManager._internal();

  static MemberManager get instance => _instance;
  //TODO treat roles as member ids

  var db = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  String? userID;
  String currentWgID = "-1";
  int wgCW = -1;
  int memberCount = -1;
  String wgName= "-1";
  String username = "-1";
  List<int> primaryRoles = [];
  int primaryIndex = -1;
  List<List<int>> otherRoles = [];
  List<String> otherNames = [];
  List<bool> tasks = [];

  MemberManager._internal() {
    userID = user!.uid;
  }

  Future<void> fetchWGData() async {
    await db.collection("users").doc(userID).get().then((value) {
      currentWgID = value["wg"];
    });

    await db.collection("wgs").doc(currentWgID).get().then((value) {
      wgCW = value["cw"];
      memberCount = value["count"];
    });

    if (wgCW != DateTime.now().weekOfYear) {
      await db.collection("wgs").doc(currentWgID).set({
        "tasks": List.filled(22, false),
        "cw": DateTime.now().weekOfYear,
        "count": memberCount,
      });
    }

    await db.collection("wgs").doc(currentWgID).get().then((value) {
      tasks = value["tasks"].cast<bool>();
    });

    await db.collection("wgs").doc(currentWgID).collection("members").orderBy("memberID").get().then((value) { //where("active", isEqualTo: true)
      otherNames = [];
      for (int i = 0; i < value.docs.length; i++) {
        var currentID = value.docs[i]["uid"];
        var currentName = value.docs[i]["username"];

        if (currentID == userID) {
          primaryIndex = i;
          username = currentName;
          continue;
        }

        otherNames.add(currentName);
      }
      setRoles(DateTime.now().weekOfYear, true);
    });

  }

  int setCurrentWgID() {
    db.collection("users").doc(userID).get().then((value) {
      currentWgID = value["wg"];
      return currentWgID;
    });
    return -1;
  }

  int getMemberCount() {
    db.collection("wgs").doc(currentWgID).get().then((value) {
      memberCount = value["count"];
      return memberCount;
    });
    return -1;
  }

  List<bool> getTasksList() {
    db.collection("wgs").doc(currentWgID).get().then((value) {
      tasks = value["tasks"].cast<bool>();
      return tasks;
    });
    return [];
  }

  List<int> getOtherNames() {
    db.collection("wgs").doc(currentWgID).collection("members").where("uid", isNotEqualTo: userID).orderBy("memberID").get().then((value) { //where("active", isEqualTo: true)
      otherNames = [];
      for (int i = 0; i < value.docs.length; i++) {
        var currentID = value.docs[i]["uid"];
        var currentName = value.docs[i]["username"];

        if (currentID == userID) {
          primaryIndex = i;
          username = currentName;
          continue;
        }

        otherNames.add(currentName);
      }
      return otherNames;
    });
    return [];
  }

  List<List<int>> setRoles(int cw, bool overwrite) {
    List<List<int>> allRoles = [];
    if (memberCount != otherNames.length + 1) {
      if (kDebugMode) {
        print("MemberCount does not match fetched users!");
        return [];
      }
    }

    switch (memberCount) {
      case 1: {
        allRoles = [[0,1,2,3]];
        break;
      }
      case 2: {
        // all aabb permutations
        int mod6 = cw % 6;
        switch (mod6) {
          case 0: {
            allRoles = [[0,3],[1,2]];
            break;
          }
          case 1: {
            allRoles = [[1,2],[0,3]];
            break;
          }
          case 2: {
            allRoles = [[0,2],[1,3]];
            break;
          }
          case 3: {
            allRoles = [[1,3],[0,2]];
            break;
          }
          case 4: {
            allRoles = [[0,1],[2,3]];
            break;
          }
          case 5: {
            allRoles = [[2,3],[0,1]];
            break;
          }
        }
        break;
      }
      case 3: {
        allRoles = [[1,2],[3],[4]];
        break; //todo add algorithm with custom map, and after sort by ascending memberID
      }
      case 4: {
        // 4-rotation
        int mod4 = cw % 4;
        allRoles = [[mod4],[mod4 + 1 > 3 ? mod4 + 1 - 4 : mod4 + 1],[mod4 + 2 > 3 ? mod4 + 2 - 4 : mod4 + 2],[mod4 + 3 > 3 ? mod4 + 3 - 4 : mod4 + 3]];
      }
    }
    if (overwrite) {
      primaryRoles = allRoles[primaryIndex];
    }
    List<int> overviewCurrentPrimaryRoles = allRoles[primaryIndex];
    allRoles.removeAt(primaryIndex);
    if (overwrite) {
      otherRoles = allRoles;
    }
    List<List<int>> overviewResult = [];
    overviewResult.add(overviewCurrentPrimaryRoles);
    overviewResult.addAll(allRoles);
    return overviewResult;
  }

}