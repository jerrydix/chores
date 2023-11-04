import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  Future<void> dataFuture = Future(() => null);
  bool active = true;
  
  MemberManager._internal() {
    userID = user!.uid;
  }

  Future<void> fetchWGData() async {
    user = FirebaseAuth.instance.currentUser;
    print("CURRENT USER: ${user?.displayName}");

    await db.collection("users").doc(userID).get().then((value) {
      currentWgID = value["wg"];
    });

    await db.collection("wgs").doc(currentWgID).get().then((value) {
      wgCW = value["cw"];
      wgName = value["name"];
    });

    if (wgCW != DateTime.now().weekOfYear) {
      await db.collection("wgs").doc(currentWgID).update({
        "cw": DateTime.now().weekOfYear,
        "tasks": List.filled(22, false),
      });
    }

    await db.collection("wgs").doc(currentWgID).get().then((value) {
      tasks = value["tasks"].cast<bool>();
    });

    await db.collection("wgs").doc(currentWgID).collection("members").orderBy("memberID").get().then((value) {
      otherNames = [];
      int j = 0;
      for (int i = 0; i < value.docs.length; i++) {
        QueryDocumentSnapshot doc = value.docs[i];
        var currentID = doc["uid"];
        var currentName = doc["username"];

        if (currentID == userID) {
          username = currentName;
          active = doc["active"];
          if (active) {
            primaryIndex = j;
          }
          continue;
        }
        if (doc["active"]) {
          otherNames.add(currentName);
          j++;
        }
      }
      memberCount = active ? otherNames.length + 1 : otherNames.length;
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

  List<bool> getTasksList() {
    db.collection("wgs").doc(currentWgID).get().then((value) {
      tasks = value["tasks"].cast<bool>();
      return tasks;
    });
    return [];
  }

  List<List<int>> setRoles(int cw, bool overwrite) {
    List<List<int>> allRoles = [];

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
        break; // todo add algorithm with custom map, and after sort by ascending memberID
      }
      case 4: {
        // 4-rotation
        int mod4 = cw % 4;
        allRoles = [[mod4],[mod4 + 1 > 3 ? mod4 + 1 - 4 : mod4 + 1],[mod4 + 2 > 3 ? mod4 + 2 - 4 : mod4 + 2],[mod4 + 3 > 3 ? mod4 + 3 - 4 : mod4 + 3]];
      }
    }

    if (overwrite && active) {
      primaryRoles = allRoles[primaryIndex];
    }

    List<int> overviewCurrentPrimaryRoles = [];
    if (active) {
      overviewCurrentPrimaryRoles = allRoles[primaryIndex];
      allRoles.removeAt(primaryIndex);
    }
    if (overwrite) {
      otherRoles = allRoles;
    }
    List<List<int>> overviewResult = [];
    if (active) {
      overviewResult.add(overviewCurrentPrimaryRoles);
    }
    overviewResult.addAll(allRoles);
    return overviewResult;
  }

}