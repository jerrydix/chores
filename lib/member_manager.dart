import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:week_of_year/date_week_extensions.dart';
import 'utils/chore_assigner.dart';

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
  List<String> members = [];
  Future<void> dataFuture = Future(() => null);
  bool active = true;
  int noRepeatWindow = 1; //todo add db integration

  late ChoreAssigner choreAssigner = ChoreAssigner(members, tasks.keys.toList(), noRepeatWindow);

  // total chores per member
  final Map<String, int> totalChores = {};

  // History of last assignments (week -> role -> member)
  final List<Map<String, String>> history = [];

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
      members = [];
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
          members.add(currentName);
          j++;
        }
      }
      memberCount = active ? members.length + 1 : members.length;
      choreAssigner.assignRoles(DateTime.now().weekOfYear);
    });
  }

  int setCurrentWgID() {
    db.collection("users").doc(userID).get().then((value) {
      currentWgID = value["wg"];
      return currentWgID;
    });

    return -1;
  }

  Future<void> updateActive(bool value) async {
    MemberManager.instance.active = value;
    notifyListeners();
  }

}
