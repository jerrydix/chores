import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:week_of_year/date_week_extensions.dart';

class MemberManager with ChangeNotifier{
  static final MemberManager _instance = MemberManager._internal();

  static MemberManager get instance => _instance;

  var db = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  String? userID;
  String currentWgID = "-1";
  int wgCW = -1;
  int memberCount = -1;
  String wgName= "-1";
  String username = "-1";
  int primaryIndex = -1;
  Map<String, Map<String, bool>> tasks = {};
  List<String> primaryRoles = [];
  List<List<String>> otherRoles = [];
  List<String> otherNames = [];
  Future<void> dataFuture = Future(() => null);
  bool active = true;


  MemberManager._internal();

  Future<void> fetchWGData() async {
    user = FirebaseAuth.instance.currentUser;
    userID = user!.uid;

    await db.collection("users").doc(userID).get().then((value) {
      currentWgID = value["wg"];
    });

    await db.collection("wgs").doc(currentWgID).get().then((value) {
      wgCW = value["cw"];
      wgName = value["name"];
    });


    Map<String, Map<String, bool>> taskMaps = {};
    await db.collection("wgs").doc(currentWgID).get().then((value) {
      var unsortedMaps = value as Map<String, Map<String, bool>>;
      taskMaps = Map.fromEntries(unsortedMaps.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
    });

    //task reset
    if (wgCW != DateTime.now().weekOfYear) {
      taskMaps.forEach((key, value) {
        value.forEach((key, value) {
          value = false;
        });
      });

      await db.collection("wgs").doc(currentWgID).update({
        "cw": DateTime.now().weekOfYear,
        "tasks": taskMaps
      });
    }

    tasks = taskMaps;
    //

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

  List<List<int>> setRoles(int cw, bool overwrite) {
    List<List<String>> allRoles = [];

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
        List<TaskMemberElement> roleMemberList = [TaskMemberElement(0, "A"),TaskMemberElement(1, "B"),TaskMemberElement(2, "C"),TaskMemberElement(3, "A")];
        List<String> people = ["A","B","C"];

        int currentPersonIndex = cw % 3;
        int currentTaskIndex = 3 - cw % 4 + 2;

        if (currentTaskIndex > 3) {
          currentTaskIndex -= 4;
        }

        for (var x in roleMemberList) {
          x.name = people[currentPersonIndex];
          x.role = currentTaskIndex;
          currentPersonIndex++;
          if (currentPersonIndex >= 3) {
            currentPersonIndex -= 3;
          }
          currentTaskIndex++;
          if (currentTaskIndex > 3) {
            currentTaskIndex -= 4;
          }
        }

        allRoles = [[],[],[]];

        for (var x in roleMemberList) {
          if (x.name == "A") {
            allRoles[0].add(x.role);
          } else if (x.name == "B") {
            allRoles[1].add(x.role);
          } else if (x.name == "C") {
            allRoles[2].add(x.role);
          }
        }

        break;
      }
      case 4: {
        // 4-rotation
        int mod4 = cw % 4;
        allRoles = [[mod4],[mod4 + 1 > 3 ? mod4 + 1 - 4 : mod4 + 1],[mod4 + 2 > 3 ? mod4 + 2 - 4 : mod4 + 2],[mod4 + 3 > 3 ? mod4 + 3 - 4 : mod4 + 3]];
        break;
      }
      default: {
        //TODO: finish generic algorithm(s)
        allRoles = List.generate(memberCount, (index) => []);
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

  Future<void> updateActive(bool value) async {
    MemberManager.instance.active = value;
    notifyListeners();
  }

}

class TaskMemberElement {
  int role;
  String name;

  TaskMemberElement(this.role, this.name);
}