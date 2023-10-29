import 'dart:collection';

import 'package:chores/member_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/secondary_card.dart';

import 'navigationbar.dart' as navBar;

class DashboardView extends StatefulWidget {
  final List<bool> tasks;
  final List<int> primaryRoles;
  final String username;
  final List<List<int>> otherRoles;
  final List<String> otherNames;

  const DashboardView(
      {super.key,
      required this.tasks,
      required this.primaryRoles,
      required this.otherRoles,
      required this.otherNames,
      required this.username});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  List<TextStyle> styles = [];
  List<String> primaryRoleNames = [];
  LinkedHashMap<int, int> indexCounters = LinkedHashMap<int, int>();
  int taskLength = -1;
  List<LinkedHashMap<String, Icon>> taskMaps = [];

  List<LinkedHashMap<String, Icon>> otherTaskMapList = [];
  List<List<bool>> otherCheckedLists = [];
  List<EdgeInsets> otherEdgeInsets = [];
  List<double> otherWidths = [];

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
    print("LLLLLLLLLLLLLLL");
    double actualHeight = kIsWeb
        ? MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top -
            MediaQuery.of(context).padding.bottom -
            navBar.getPaddings()
        : navBar.bodyHeight;
    double primaryHeightMultiplier =
        widget.otherRoles.isNotEmpty ? (8 / 10) : 1;

    createSecondaryData();
    SecondaryCardData data = SecondaryCardData(
        roles: roleIntToStr(widget.otherRoles),
        taskLists: otherTaskMapList,
        checkedLists: otherCheckedLists,
        edgeInsets: otherEdgeInsets,
        widths: otherWidths,
        titles: widget.otherNames);

    return Center(
      child: Column(
        children: <Widget>[
          Card(
            margin: const EdgeInsets.all(10),
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: SizedBox(
              width: clampDouble(MediaQuery.of(context).size.width, 0, 500),
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
          SecondaryCard(data: data)
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

  void createSecondaryData() {
    for (int i = 0; i < widget.otherRoles.length; i++) {
      List<int> currentRoles = widget.otherRoles[i];
      List<LinkedHashMap<String, Icon>> currentMaps =
          createTaskMap(currentRoles, false);
      LinkedHashMap<String, Icon> currentCombinedMap = currentMaps[0];
      if (currentMaps.length > 1) {
        for (int j = 1; j < currentMaps.length; j++) {
          currentCombinedMap.addAll(currentMaps[j]);
        }
      }
      otherTaskMapList.add(currentCombinedMap);
      List<bool> currentCheckList = [];
      for (var role in currentRoles) {
        switch (role) {
          case 0:
            {
              currentCheckList.addAll(createCheckedList(0, 6));
              break;
            }
          case 1:
            {
              currentCheckList.addAll(createCheckedList(6, 7));
              break;
            }
          case 2:
            {
              currentCheckList.addAll(createCheckedList(13, 4));
              break;
            }
          case 3:
            {
              currentCheckList.addAll(createCheckedList(17, 5));
              break;
            }
          default:
            {
              if (kDebugMode) {
                print("ERROR: wrong role id");
              }
              return;
            }
        }
      }
      otherCheckedLists.add(currentCheckList);
    }

    switch (widget.otherRoles.length) {
      case 1:
        {
          otherEdgeInsets
              .add(const EdgeInsets.only(left: 10, right: 10, bottom: 10));
          otherWidths
              .add(clampDouble(MediaQuery.of(context).size.width - 20, 0, 500));
          break;
        }
      case 2:
        {
          for (int i = 0; i < 2; i++) {
            otherEdgeInsets
                .add(const EdgeInsets.only(right: 5, left: 10, bottom: 10));
            otherWidths.add(clampDouble(
                MediaQuery.of(context).size.width / 2 - 15, 0, 245));
          }
          break;
        }
      case 3:
        {
          otherEdgeInsets
              .add(const EdgeInsets.only(left: 10, right: 5, bottom: 10));
          otherEdgeInsets
              .add(const EdgeInsets.only(left: 5, right: 5, bottom: 10));
          otherEdgeInsets
              .add(const EdgeInsets.only(left: 10, right: 5, bottom: 5));
          for (int i = 0; i < 2; i++) {
            otherWidths.add(clampDouble(
                MediaQuery.of(context).size.width / 3 - (13 + 1 / 3), 0, 161));
          }
          break;
        }
    }
  }

  List<bool> createCheckedList(int startIndex, int length) {
    List<bool> result = [];
    for (int i = startIndex; i < startIndex + length; i++) {
      result.add(widget.tasks[i]);
    }
    return result;
  }

  List<List<String>> roleIntToStr(List<List<int>> roles) {
    AppLocalizations loc = AppLocalizations.of(context)!;

    List<List<String>> result = [];
    for (var roleList in roles) {
      List<String> currentResult = [];
      for (var role in roleList) {
        switch (role) {
          case 0:
            {
              currentResult.add(loc.garbage);
              break;
            }
          case 1:
            {
              currentResult.add(loc.bathroom);
              break;
            }
          case 2:
            {
              currentResult.add(loc.kitchen);
              break;
            }
          case 3:
            {
              currentResult.add(loc.vacuum);
              break;
            }
          default:
            {
              if (kDebugMode) {
                print("ERROR: wrong role id");
              }
            }
        }
      }
      result.add(currentResult);
    }
    return result;
  }

  List<Widget> createPrimaryTasks() {
    taskMaps = createTaskMap(widget.primaryRoles, true);

    List<Widget> currentTasks = [];
    List<int> offsets = [];

    print(offsets);
    print(currentTasks);

    for (int i = 0; i < indexCounters.length; i++) {
      offsets.add(currentTasks.length);
      taskMaps[i].forEach((name, icon) {
        currentTasks.add(StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return CheckboxListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  checkboxShape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  title: Text(name,
                      style: styles.elementAt(
                          indexCounters.keys.elementAt(i) + currentTasks.indexOf(context.widget) - offsets[i])),
                  value: widget
                      .tasks[indexCounters.keys.elementAt(i) + currentTasks.indexOf(context.widget) - offsets[i]],
                  onChanged: (value) {
                    int indexInList = currentTasks.indexOf(context.widget);

                    setState(() {
                      widget.tasks[indexCounters.keys.elementAt(i) + indexInList - offsets[i]] = value!;
                      styleSwitcher(indexCounters.keys.elementAt(i) + indexInList - offsets[i], value);
                    });
                    saveSelectionStateToDB();
                  },
                  secondary: icon);
            }));
        //print(currentTasks);
      });
    }
    print(offsets);
    print(currentTasks);
    return currentTasks;
  }

  List<LinkedHashMap<String, Icon>> createTaskMap(List<int> roles, bool primary) {
    AppLocalizations loc = AppLocalizations.of(context)!;

    List<LinkedHashMap<String, Icon>> result = [];
    for (var role in roles) {
      LinkedHashMap<String, Icon> currentResult = LinkedHashMap<String, Icon>();
      switch (role) {
        case 0:
          {
            if (primary) {
              primaryRoleNames.add(loc.garbage);
              indexCounters[0] = 5;
            }
            currentResult.addAll({
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
            if (primary) {
              primaryRoleNames.add(loc.bathroom);
              indexCounters[6] = 12;
            }
            currentResult.addAll({
              loc.b206mirrors: const Icon(Icons.video_label),
              loc.b207sink: const Icon(Icons.soap),
              loc.b208bath: const Icon(Icons.hot_tub),
              loc.b209toilet: const Icon(Icons.airline_seat_legroom_reduced),
              loc.b210dust: const Icon(Icons.cleaning_services),
              loc.b211carpet: const Icon(Icons.calendar_view_week),
              loc.b212b_waste: const Icon(Icons.delete),
            });
            break;
          }
        case 2:
          {
            if (primary) {
              primaryRoleNames.add(loc.kitchen);
              indexCounters[13] = 16;
            }
            currentResult.addAll({
              loc.b313surfaces: const Icon(Icons.countertops),
              loc.b314stove: const Icon(Icons.outdoor_grill),
              loc.b315fridge: const Icon(Icons.kitchen),
              loc.b316cloths: const Icon(Icons.receipt),
            });
            break;
          }
        case 3:
          {
            if (primary) {
              primaryRoleNames.add(loc.vacuum);
              indexCounters[17] = 21;
            }
            currentResult.addAll({
              loc.b417v_kitchen: const Icon(Icons.countertops),
              loc.b418v_bath: const Icon(Icons.hot_tub),
              loc.b419v_living: const Icon(Icons.event_seat),
              loc.b420v_stairs: const Icon(Icons.home),
              loc.b421v_corridor: const Icon(Icons.home_mini),
            });
            break;
          }
        default:
          {
            if (kDebugMode) {
              print("ERROR: wrong role id");
            }
          }
      }
      result.add(currentResult);
    }
    return result;
  }

  @override
  void dispose() async {
    super.dispose();
    await saveSelectionStateToDB();
  }

  Future saveSelectionStateToDB() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    await db.runTransaction((transaction) async {
      final docReference =
          db.collection("wgs").doc(MemberManager.instance.currentWgID);
      final docSnapshot = await transaction.get(docReference);
      List<bool> currentTaskList = await docSnapshot["tasks"].cast<bool>();

      indexCounters.forEach((start, end) {
        for (int i = start; i < end + 1; i++) {
          currentTaskList[i] = widget.tasks[i];
        }
      });

      transaction.update(docReference, {
        "tasks": currentTaskList,
      });
    });
  }

  Text createPrimaryRolesText() {
    String text = "${widget.username} (";
    for (var element in primaryRoleNames) {
      text += "$element, ";
    }
    text = text.substring(0, text.length - 2);
    text += ")";
    return Text(text);
  }
}
