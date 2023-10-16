import 'dart:collection';

import 'package:animations/animations.dart';
import 'package:chores/member_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../dashboard.dart';
import 'checklist.dart';

import 'navigationbar.dart' as navBar;

class Dashboard1 extends StatefulWidget {

  final List<bool> tasks;
  final int primaryRole;
  final List<int> otherRoles;

  const Dashboard1({super.key, required this.tasks, required this.primaryRole, required this.otherRoles});

  @override
  State<Dashboard1> createState() => _Dashboard1State();
}

class _Dashboard1State extends State<Dashboard1> {

  List<TextStyle> styles = [];
  String roleName = "-1";
  int indexCounter = -1;
  int taskLength = -1;
  LinkedHashMap<String, Icon> taskMap = LinkedHashMap<String, Icon>();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    for (int i = 0; i < widget.tasks.length; i++) {
      if (!widget.tasks[i]) {
        styles.add(const TextStyle(
        decoration: TextDecoration.none,
      ));
      } else {
        styles.add(const TextStyle(
          decoration: TextDecoration.lineThrough,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    double actualHeight = kIsWeb ? MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - navBar.getPaddings() : navBar.bodyHeight;
    double primaryHeightMultiplier = widget.otherRoles.isNotEmpty ? (8/10) : 1;

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
              height: (actualHeight - 20) * primaryHeightMultiplier,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Scrollbar(
                  radius: const Radius.circular(10),
                  thickness: 3,
                  child: SingleChildScrollView(
                      child: Column(
                        children: createPrimaryTasks(),
                      )),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    //TODO ADD ROW FOR SECONDARY; POPULATE IT
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

  List<Widget> createPrimaryTasks() {
    AppLocalizations loc = AppLocalizations.of(context)!;

    switch(widget.primaryRole) {
      case 0:
        {
          roleName = loc.garbage;
          indexCounter = 0;
          taskMap.addAll({
            loc.g100plastic: const Icon(Icons.recycling),
            loc.g101residual: const Icon(Icons.delete),
            loc.g102organic: const Icon(Icons.eco),
            loc.g103paper: const Icon(Icons.library_books),
            loc.g104glass: const Icon(Icons.liquor),
            loc.g105bottles: const Icon(Icons.request_page),
          });
          break;
        }
      case 1:
        {
          roleName = loc.bathroom;
          indexCounter = 6;
          taskMap.addAll({
            loc.b206mirrors: const Icon(Icons.video_label),
            loc.b207sink: const Icon(Icons.soap),
            loc.b208bath:  const Icon(Icons.hot_tub),
            loc.b209toilet: const Icon(Icons.airline_seat_legroom_reduced),
            loc.b210dust: const Icon(Icons.cleaning_services),
            loc.b211carpet: const Icon(Icons.calendar_view_week),
            loc.b212b_waste: const Icon(Icons.delete),
          });
          break;
        }
      case 2:
        {
          roleName = loc.kitchen;
          indexCounter = 13;
          taskMap.addAll({
            loc.b313surfaces: const Icon(Icons.countertops),
            loc.b314stove: const Icon(Icons.outdoor_grill),
            loc.b315fridge: const Icon(Icons.kitchen),
            loc.b316cloths: const Icon(Icons.receipt),
          });
          break;
        }
      case 3:
        {
          roleName = loc.vacuum;
          indexCounter = 17;
          taskMap.addAll({
            loc.b417v_kitchen: const Icon(Icons.countertops),
            loc.b418v_bath: const Icon(Icons.hot_tub),
            loc.b419v_living: const Icon(Icons.event_seat),
            loc.b420v_stairs: const Icon(Icons.home),
            loc.b421v_corridor: const Icon(Icons.home_mini),
          });
          break;
        }

    }
    List<Widget> currentTasks = [];
    int i = indexCounter;
    taskLength = taskMap.keys.length;

    taskMap.forEach((name, icon) {

      currentTasks.add(StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return CheckboxListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                checkboxShape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                title: Text(name, style: styles.elementAt(indexCounter + currentTasks.indexOf(context.widget))),
                value: widget.tasks[indexCounter + currentTasks.indexOf(context.widget)],
                onChanged: (value) {
                  int indexInList = currentTasks.indexOf(context.widget);
                  setState(() {
                    widget.tasks[indexCounter + indexInList] = value!;
                    styleSwitcher(indexCounter + indexInList, value);
                  });
                  saveSelectionStateToDB();
                },
                secondary: icon);
          }
      ));
      i++;
    });

    return currentTasks;
  }

  @override
  void dispose() async {
    super.dispose();
    await saveSelectionStateToDB();
  }

  Future saveSelectionStateToDB() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    
    await db.runTransaction((transaction) async {
      final docReference = db.collection("wgs").doc(MemberManager.instance.currentWgID);
      final docSnapshot = await transaction.get(docReference);
      List<bool> currentTaskList = await docSnapshot["tasks"].cast<bool>();

      for (int i = indexCounter; i < indexCounter + taskLength; i++) {
        currentTaskList[i] = widget.tasks[i];
      }

      transaction.update(docReference, {
        "tasks": currentTaskList,
      });
    });
  }

}