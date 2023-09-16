import 'package:chores/dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'navigationbar.dart';

class WGListTile extends StatefulWidget {

  final String name;
  final int count;
  final String uid;

  const WGListTile({super.key, required this.name, required this.count, required this.uid});

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
    await FirebaseFirestore.instance.collection("wgs").doc(uid).collection("members").doc(FirebaseAuth.instance.currentUser?.uid).set({
      "uid": FirebaseAuth.instance.currentUser?.uid
    });
    await FirebaseFirestore.instance.collection("wgs").doc(uid).update({
      "count": FieldValue.increment(1)
    });
  }
}

