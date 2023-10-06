import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../dashboard.dart';
import 'checklist.dart';

import 'package:collection/src/boollist.dart';

import 'navigationbar.dart' as navBar;

class Dashboard1 extends StatefulWidget {

  final int tasksAmount;
  const Dashboard1({super.key, required this.tasksAmount, required int primaryRole, required List<int> otherRoles, required BoolList completedTasks});

  @override
  State<Dashboard1> createState() => _Dashboard1State();
}

class _Dashboard1State extends State<Dashboard1> {

  List<TextStyle> styles = [];
  late BoolList checked;

  @override
  void initState() {
    super.initState();
    checked = BoolList(widget.tasksAmount);
    init();
  }

  Future<void> init() async {
    for (int i = 0; i < widget.tasksAmount; i++) {
      styles.add(const TextStyle(
        decoration: TextDecoration.none,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {

    double actualHeight = kIsWeb ? MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - navBar.getPaddings() : navBar.bodyHeight;

    return Center(
      child: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(10),
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: SizedBox(
              width:
              clampDouble(MediaQuery.of(context).size.width, 0, 500),
              height: actualHeight - 20,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Scrollbar(
                  radius: const Radius.circular(10),
                  thickness: 3,
                  child: SingleChildScrollView(
                      child: Column(
                        children: [
                          CheckboxTile(
                              title: "test",
                              style: styles.elementAt(0),
                              checked: checked[0],
                              icon: const Icon(Icons.abc)),
                          CheckboxTile(
                              title: "test",
                              style: styles.elementAt(1),
                              checked: checked[1],
                              icon: const Icon(Icons.delete)),
                          CheckboxTile(
                              title: "test",
                              style: styles.elementAt(2),
                              checked: checked[2],
                              icon: const Icon(Icons.airplane_ticket)),
                          CheckboxTile(
                              title: "test",
                              style: styles.elementAt(3),
                              checked: checked[3],
                              icon: const Icon(Icons.traffic_sharp)),
                        ],
                      )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void styleSwitcher(int i, bool value) {
    if (value) {
      styles[i] = TextStyle(
          decoration: TextDecoration.lineThrough,
          color: styles[i].color?.withOpacity(0.75));
    } else {
      styles[i] = TextStyle(
          decoration: TextDecoration.none,
          color: styles[i].color?.withOpacity(1));
    }
  }

}