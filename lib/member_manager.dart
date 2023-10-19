import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
  int memberCount = -1;
  String wgName= "-1";
  String username = "-1";
  List<int> primaryRoles = [];
  int primaryID = -1;
  List<int> otherIDs = [];
  List<List<int>> otherRoleLists = [];
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
      memberCount = value["count"];
      tasks = value["tasks"].cast<bool>();
    });

    await db.collection("wgs").doc(currentWgID).collection("members").doc(userID).get().then((value) {
      primaryID = value["role"];
      username = value["username"];
    });

    if (memberCount > 1) {
      await db.collection("wgs").doc(currentWgID).collection("members").where("uid", isNotEqualTo: userID).get().then((value) {
        otherIDs = [];
        otherNames = [];
        for (int i = 0; i < value.docs.length; i++) {
          otherIDs.add(value.docs[i]["role"]);
          otherNames.add(value.docs[i]["username"]);
        }
      });
    }
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

  int getPrimaryRole() {
    db.collection("wgs").doc(currentWgID).collection("members").doc(userID).get().then((value) {
      primaryID = value["role"];
      return primaryID;
    });
    return -1;
  }

  List<int> getOtherIDs() {
    db.collection("wgs").doc(currentWgID).collection("members").where("uid", isNotEqualTo: userID).get().then((value) {
      otherIDs = [];
      otherNames = [];
      for (int i = 0; i < value.docs.length; i++) {
        otherIDs.add(value.docs[i]["role"]);
        otherNames.add(value.docs[i]["username"]);
      }
      return otherIDs;
    });
    return [];
  }

  void setRoles() {
    var cw = DateTime.now().weekOfYear;
    switch (memberCount) {
      case 1: {
        primaryRoles = [0,1,2,3];
        break;
      }
      case 2: {
        // all aabb permutations
        int mod6 = cw % 6;
        switch (mod6) {
          case 0: {
            primaryRoles = [0,3];
            otherRoleLists = [[1,2]];
            break;
          }
          case 1: {
            primaryRoles = [1,2];
            otherRoleLists = [[0,3]];
            break;
          }
          case 2: {
            primaryRoles = [0,2];
            otherRoleLists = [[1,3]];
            break;
          }
          case 3: {
            primaryRoles = [1,3];
            otherRoleLists = [[0,2]];
            break;
          }
          case 4: {
            primaryRoles = [0,1];
            otherRoleLists = [[2,3]];
            break;
          }
          case 5: {
            primaryRoles = [2,3];
            otherRoleLists = [[0,1]];
            break;
          }
        }
        break;
      }
      case 3: {
        primaryRoles = [0,3];
        otherRoleLists = [[1],[2]];
        break; //todo add algorithm
      }
      case 4: {
        // 4-rotation
        int mod4 = cw % 4;
        primaryRoles = [mod4];
        otherRoleLists = [[mod4 + 1 > 3 ? mod4 + 1 - 4 : mod4 + 1],[mod4 + 2 > 3 ? mod4 + 2 - 4 : mod4 + 2],[mod4 + 3 > 3 ? mod4 + 3 - 4 : mod4 + 3]];
      }
    }
  }

}