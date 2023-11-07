
import 'package:chores/widgets/wg_listtile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
          return SelectionArea(
            child: Scaffold(
                appBar: AppBar(
                  title: const Text("Select WG"),
                ),
                body: const Center(child: CircularProgressIndicator())));
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