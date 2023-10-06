import 'dart:collection';

import 'package:chores/widgets/wg_listtile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class WGSelection extends StatefulWidget {
  final String username;
  const WGSelection({super.key, required this.username});

  @override
  State<StatefulWidget> createState() => _WGSelectionState();
}

class _WGSelectionState extends State<WGSelection> {

  Map<String, int> entries = {};

  @override
  void initState() {
    super.initState();
  }

  //Map<String, int> entries = {'StraßfeldWG': 1, 'LOL': 2, 'Test': 3, 'StraßfeldWG2': 1, 'LOL2': 2, 'Test2': 3, 'Straßfeld3WG': 1, 'LO3L': 2, 'T3est': 3, 'Straßf3eldWG2': 1, 'L3OL2': 2, '3Test2': 3};

  @override
  Widget build(BuildContext context) {
    var db = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: db.collection("wgs").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return SelectionArea(
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Select WG"),
            ),
            body: ListView.separated(
              //padding: const EdgeInsets.all(8),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                return WGListTile(name: snapshot.data!.docs[index]["name"], count: snapshot.data!.docs[index]["count"], uid: snapshot.data!.docs[index].id, username: widget.username);
              },
              separatorBuilder: (BuildContext context, int index) => const Divider(
                indent: 10,
                endIndent: 10,
              ),
            ),
          )
        );
      },
    );
  }
}