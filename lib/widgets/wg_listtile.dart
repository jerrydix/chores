import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

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
          SimpleCircularProgressBar(
            backColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            progressColors: [Theme.of(context).colorScheme.primary],
            mergeMode: true,
            size: 35,
            progressStrokeWidth: 3,
            backStrokeWidth: 3,
            maxValue: 4,
            animationDuration: 1,
            fullProgressColor: Theme.of(context).colorScheme.error,
            onGetText: (_) {
              return Text("${widget.count}/4");
            },
            valueNotifier: ValueNotifier(widget.count.toDouble()),
          ),
          const SizedBox(width: 15,),
          ElevatedButton(
            onPressed: () async {
              if (widget.count >= 4) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("This WG is full, cannot join."),
                  duration: Duration(seconds: 1),
                ));
                return;
              }
              await saveWGMemberToDatabase(uid: widget.uid, username: widget.username);
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

  Future saveWGMemberToDatabase({required String uid, required String username}) async {
    var db = FirebaseFirestore.instance;
    var auth = FirebaseAuth.instance;

    List<int> roles = [];
    int role = -1;

    await db.collection("wgs").doc(uid).collection("members").get().then((querySnapshot) {
       for (var doc in querySnapshot.docs) {
         roles.add(doc["memberID"]);
       }
    });


    for (int i = 0; i <= 3; i++) {
      if (!roles.contains(i)) {
        role = i;
        break;
      }
    }

    await db.collection("wgs").doc(uid).collection("members").doc(auth.currentUser?.uid).set({
      "uid": auth.currentUser?.uid,
      "memberID": role,
      "username": username,
      "active": true
    });

    await db.collection("wgs").doc(uid).update({
      "count": FieldValue.increment(1)
    });

    await db.collection("users").doc(auth.currentUser?.uid).update({
      "wg": uid,
    });

  }
}

