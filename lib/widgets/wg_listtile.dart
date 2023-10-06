import 'package:chores/dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'navigationbar.dart';

class WGListTile extends StatefulWidget {

  final String name;
  final int count;
  final String uid;
  final String username;

  const WGListTile({super.key, required this.name, required this.count, required this.uid, required this.username});

  @override
  State<StatefulWidget> createState() => _WGListTileState();
}

class _WGListTileState extends State<WGListTile> {

  @override
  Widget build(BuildContext context) {

    return ListTile(
      title: Text(
        widget.name,
        style: const TextStyle(fontSize: 20),
      ),
      enableFeedback: false,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Center(
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    value: widget.count / 4,
                  ),
                ),
              ),
              Center(
                  widthFactor: 1.8,
                  child: Text("${widget.count}/4")
              ),
            ],
          ),
          const SizedBox(width: 15,),
          ElevatedButton(
            onPressed: () {
              if (widget.count >= 4) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("This WG is full, cannot join."),
                  duration: Duration(seconds: 1),
                ));
                return;
              }
              saveWGMemberToDatabase(uid: widget.uid);
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const NavBar(),
                  ), (route) => false
              );
            },
            child: const Icon(Icons.chevron_right_rounded),
          )
        ],
      ),
    );
  }

  Future saveWGMemberToDatabase({required String uid}) async {
    var db = FirebaseFirestore.instance;
    var auth = FirebaseAuth.instance;

    List<int> roles = [];
    int role = -1;

    db.collection("wgs").doc(uid).collection("members").get().then((querySnapshot) {
       for (var doc in querySnapshot.docs) {
         roles.add(doc["role"]);
       }
    });

    for (int i = 1; i <= 4; i++) {
      if (!roles.contains(i)) {
        role = i;
        break;
      }
    }

    await db.collection("wgs").doc(uid).collection("members").doc(auth.currentUser?.uid).set({
      "uid": auth.currentUser?.uid,
      "role": role
    });

    await db.collection("wgs").doc(uid).update({
      "count": FieldValue.increment(1)
    });

    await db.collection("users").doc(auth.currentUser?.uid).set({
      "username": widget.username,
      "wg": uid
    });
  }
}

