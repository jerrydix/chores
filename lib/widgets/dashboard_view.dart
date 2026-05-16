import 'package:chores/member_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/secondary_card.dart';

import 'navigation_bar.dart' as nav_bar;

class DashboardView extends StatefulWidget {
  final Map<String, Map<String, bool>> tasks;
  final Map<String, Map<String, IconData?>> taskIcons;
  final List<String> primaryRoles;
  final String username;
  final List<List<String>> otherRoles;
  final List<String> otherNames;
  final bool active;

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
  late Map<String, Map<String, bool>> tasks;
  late Map<String, Map<String, IconData?>> taskIcons;
  late List<String> primaryRoles;
  late List<List<String>> otherRoles;
  late List<String> otherNames;
  late String username;
  late bool active;
  List<EdgeInsets> otherEdgeInsets = [];
  List<double> otherWidths = [];

  @override
  void initState() {
    super.initState();
    _syncFromWidget();
  }

  @override
  void didUpdateWidget(DashboardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncFromWidget();
  }

  void _syncFromWidget() {
    tasks = widget.tasks;
    taskIcons = widget.taskIcons;
    primaryRoles = widget.primaryRoles;
    otherRoles = widget.otherRoles;
    otherNames = widget.otherNames;
    username = widget.username;
    active = widget.active;
  }

  @override
  Widget build(BuildContext context) {
    double actualHeight = kIsWeb
        ? MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top -
            MediaQuery.of(context).padding.bottom -
            nav_bar.getPaddings()
        : nav_bar.bodyHeight;
    double primaryHeightMultiplier =
        otherRoles.isNotEmpty ? (8 / 10) : 1;

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
        active ? primaryActiveWidget : primaryInactiveWidget;

    return RefreshIndicator(
      onRefresh: () async {
        await MemberManager.instance.fetchWGData();
        final m = MemberManager.instance;
        setState(() {
          tasks = m.tasks;
          taskIcons = m.taskIcons;
          primaryRoles = m.primaryRoles;
          otherRoles = m.otherRoles;
          otherNames = m.members;
          username = m.username;
          active = m.active;
          otherEdgeInsets.clear();
          otherWidths.clear();
        });
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
                            .withValues(alpha: 0.2),
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
                              for (final role in primaryRoles) {
                                final taskMap = tasks[role];
                                if (taskMap == null) continue;
                                for (final taskName in taskMap.keys.toList()) {
                                  tasks[role]![taskName] = value;
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

    for (final role in primaryRoles) {
      final taskMap = tasks[role];
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
        final icon = taskIcons[role]?[taskName];

        widgets.add(StatefulBuilder(
          builder: (context, setItem) {
            final done = tasks[role]![taskName] ?? false;
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
                  tasks[role]![taskName] = value;
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

    final count = otherRoles.length;
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
    final List<Map<String, Icon>> taskMaps = [];
    final List<List<bool>> checkedLists = [];

    for (int i = 0; i < otherRoles.length; i++) {
      final roles = otherRoles[i];
      final taskMap = <String, Icon>{};
      final checked = <bool>[];

      for (final role in roles) {
        final roleTasks = tasks[role] ?? {};
        final roleIcons = taskIcons[role] ?? {};
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
      roles: otherRoles,
      taskLists: taskMaps,
      checkedLists: checkedLists,
      edgeInsets: otherEdgeInsets,
      widths: otherWidths,
      titles: otherNames,
    );
  }

  void _syncAllTasksDone() {
    final allDone = primaryRoles.every((role) {
      final taskMap = tasks[role];
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
        .update({"tasks": tasks});
  }
}
