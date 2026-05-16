import 'dart:collection';

import 'package:chores/member_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/secondary_card.dart';

import 'navigation_bar.dart' as navBar;

class DashboardView extends StatefulWidget {
  Map<String, Map<String, bool>> tasks;
  Map<String, Map<String, IconData?>> taskIcons;
  List<String> primaryRoles;
  String username;
  List<List<String>> otherRoles;
  List<String> otherNames;
  bool active;

  final ValueNotifier<bool> allTasksDone = ValueNotifier<bool>(false);

  DashboardView({
    super.key,
    required this.tasks,
    required this.taskIcons,
    required this.primaryRoles,
    required this.otherRoles,
    required this.otherNames,
    required this.username,
    required this.active,
  });

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  List<EdgeInsets> otherEdgeInsets = [];
  List<double> otherWidths = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double actualHeight = kIsWeb
        ? MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top -
            MediaQuery.of(context).padding.bottom -
            navBar.getPaddings()
        : navBar.bodyHeight;
    double primaryHeightMultiplier =
        widget.otherRoles.isNotEmpty ? (8 / 10) : 1;

    _computeSecondaryLayout();
    final secondaryData = _buildSecondaryCardData();

    Widget primaryWidget;
    final scrollController = ScrollController();
    final primaryTasks = _createPrimaryTasks();

    Widget primaryActiveWidget = primaryTasks.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_alt,
                    size: 56,
                    color: Theme.of(context).colorScheme.outlineVariant),
                const SizedBox(height: 16),
                Text(
                  'No tasks yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add roles & chores in Settings',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.outline),
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Scrollbar(
              radius: const Radius.circular(16),
              thickness: 3,
              controller: scrollController,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(children: primaryTasks),
              ),
            ),
          );

    Widget primaryInactiveWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppLocalizations.of(context)!.noPrimaryRoles),
        Text(AppLocalizations.of(context)!.noPrimaryRoles2),
      ],
    );

    primaryWidget =
        widget.active ? primaryActiveWidget : primaryInactiveWidget;

    return RefreshIndicator(
      onRefresh: () async {
        await MemberManager.instance.fetchWGData();
        final m = MemberManager.instance;
        widget.tasks = m.tasks;
        widget.taskIcons = m.taskIcons;
        widget.primaryRoles = m.primaryRoles;
        widget.otherRoles = m.otherRoles;
        widget.otherNames = m.members;
        widget.username = m.username;
        widget.active = m.active;
        otherEdgeInsets.clear();
        otherWidths.clear();
        setState(() {});
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: Column(
            children: <Widget>[
              Card(
                margin: const EdgeInsets.all(10),
                elevation: 0,
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: SizedBox(
                  width: clampDouble(
                      MediaQuery.of(context).size.width, 0, 500),
                  height:
                      (actualHeight - 20) * primaryHeightMultiplier,
                  child: Column(
                    children: [
                      Expanded(child: primaryWidget),
                      Divider(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.2),
                        indent: 15,
                        endIndent: 15,
                        height: 20,
                      ),
                      ValueListenableBuilder(
                        valueListenable: widget.allTasksDone,
                        builder: (context, value, child) => Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, bottom: 10),
                          child: CheckboxListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            checkboxShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                            title: Text(
                                AppLocalizations.of(context)!.finAllTasks),
                            onChanged: (value) {
                              if (value == null) return;
                              widget.allTasksDone.value = value;
                              for (final role in widget.primaryRoles) {
                                final taskMap = widget.tasks[role];
                                if (taskMap == null) continue;
                                for (final taskName in taskMap.keys.toList()) {
                                  widget.tasks[role]![taskName] = value;
                                }
                              }
                              setState(() {});
                              saveSelectionStateToDB();
                            },
                            secondary: const Icon(Icons.done_all),
                            value: widget.allTasksDone.value,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SecondaryCard(data: secondaryData),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _createPrimaryTasks() {
    final List<Widget> widgets = [];

    for (final role in widget.primaryRoles) {
      final taskMap = widget.tasks[role];
      if (taskMap == null || taskMap.isEmpty) continue;

      widgets.add(Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(role,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ));

      for (final taskName in taskMap.keys) {
        final icon = widget.taskIcons[role]?[taskName];

        widgets.add(StatefulBuilder(
          builder: (context, setItem) {
            final done = widget.tasks[role]![taskName] ?? false;
            return CheckboxListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              checkboxShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              secondary: icon != null ? Icon(icon) : null,
              title: Text(
                taskName,
                style: TextStyle(
                  decoration: done
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              value: done,
              onChanged: (value) {
                if (value == null) return;
                setItem(() {
                  widget.tasks[role]![taskName] = value;
                });
                _syncAllTasksDone();
                saveSelectionStateToDB();
              },
            );
          },
        ));
      }
    }

    return widgets;
  }

  void _computeSecondaryLayout() {
    otherEdgeInsets = [];
    otherWidths = [];

    final count = widget.otherRoles.length;
    if (count == 0) return;

    final sw = MediaQuery.of(context).size.width;

    if (count == 1) {
      otherEdgeInsets.add(const EdgeInsets.only(left: 10, right: 10, bottom: 10));
      otherWidths.add(clampDouble(sw - 20, 0, 500));
    } else if (count == 2) {
      otherEdgeInsets.add(const EdgeInsets.only(left: 10, right: 5, bottom: 10));
      otherEdgeInsets.add(const EdgeInsets.only(left: 5, right: 10, bottom: 10));
      for (int i = 0; i < 2; i++) {
        otherWidths.add(clampDouble(sw / 2 - 15, 0, 245));
      }
    } else if (count == 3) {
      otherEdgeInsets.add(const EdgeInsets.only(left: 10, right: 5, bottom: 10));
      otherEdgeInsets.add(const EdgeInsets.only(left: 5, right: 5, bottom: 10));
      otherEdgeInsets.add(const EdgeInsets.only(left: 5, right: 10, bottom: 10));
      for (int i = 0; i < 3; i++) {
        otherWidths.add(clampDouble(sw / 3 - (13 + 1 / 3), 0, 161));
      }
    } else {
      // 4+ users: fixed-width cards, SecondaryCard will scroll horizontally
      for (int i = 0; i < count; i++) {
        otherEdgeInsets.add(EdgeInsets.only(
          left: i == 0 ? 10 : 5,
          right: i == count - 1 ? 10 : 5,
          bottom: 10,
        ));
        otherWidths.add(160.0);
      }
    }
  }

  SecondaryCardData _buildSecondaryCardData() {
    final List<LinkedHashMap<String, Icon>> taskMaps = [];
    final List<List<bool>> checkedLists = [];

    for (int i = 0; i < widget.otherRoles.length; i++) {
      final roles = widget.otherRoles[i];
      final taskMap = LinkedHashMap<String, Icon>();
      final checked = <bool>[];

      for (final role in roles) {
        final roleTasks = widget.tasks[role] ?? {};
        final roleIcons = widget.taskIcons[role] ?? {};
        for (final entry in roleTasks.entries) {
          final icon = roleIcons[entry.key];
          taskMap[entry.key] =
              Icon(icon ?? Icons.task_alt);
          checked.add(entry.value);
        }
      }

      taskMaps.add(taskMap);
      checkedLists.add(checked);
    }

    return SecondaryCardData(
      roles: widget.otherRoles,
      taskLists: taskMaps,
      checkedLists: checkedLists,
      edgeInsets: otherEdgeInsets,
      widths: otherWidths,
      titles: widget.otherNames,
    );
  }

  void _syncAllTasksDone() {
    final allDone = widget.primaryRoles.every((role) {
      final taskMap = widget.tasks[role];
      if (taskMap == null || taskMap.isEmpty) return true;
      return taskMap.values.every((done) => done);
    });
    widget.allTasksDone.value = allDone;
  }

  @override
  void dispose() {
    saveSelectionStateToDB();
    super.dispose();
  }

  Future<void> saveSelectionStateToDB() async {
    await FirebaseFirestore.instance
        .collection("wgs")
        .doc(MemberManager.instance.currentWgID)
        .update({"tasks": widget.tasks});
  }
}
