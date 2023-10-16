import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/src/boollist.dart';

class MemberManager {
  static final MemberManager _instance = MemberManager._internal();

  static MemberManager get instance => _instance;

  var db = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  String? userID;
  String currentWgID = "-1";
  int memberCount = -1;
  String wgName= "-1";
  String username = "-1";
  int primaryRole= -1;
  List<int> otherRoles = [];
  List<bool> tasks = [];


  MemberManager._internal() {
    userID = user!.uid;
    //fetchWGData();
  }

  Future<void> fetchWGData() async {
    //print("User ID: " + userID!);
    await db.collection("users").doc(userID).get().then((value) {
      currentWgID = value["wg"];
      //print("WG id: " + currentWgID);
    });

    //print("WG id: " + currentWgID);
    await db.collection("wgs").doc(currentWgID).get().then((value) {
      memberCount = value["count"];
      tasks = value["tasks"].cast<bool>();
    });

    await db.collection("wgs").doc(currentWgID).collection("members").doc(userID).get().then((value) {
      primaryRole = value["role"];
    });

    if (memberCount > 1) {
      await db.collection("wgs").doc(currentWgID).collection("members").where("uid", isNotEqualTo: userID).get().then((value) {
        for (int i = 0; i < value.docs.length; i++) {
          otherRoles.add(value.docs[i]["role"]);
        }
      });
    }
    print("FINISHED");
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
      primaryRole = value["role"];
      return primaryRole;
    });
    return -1;
  }

  List<int> getOtherRoles() {
    db.collection("wgs").doc(currentWgID).collection("members").where("uid", isNotEqualTo: userID).get().then((value) {
      for (int i = 0; i < value.docs.length; i++) {
        otherRoles.add(value.docs[i]["role"]);
        return otherRoles;
      }
    });
    return [];
  }

}