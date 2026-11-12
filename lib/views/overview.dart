import 'dart:math';

import 'package:chores/member_manager.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:quiver/time.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:week_of_year/date_week_extensions.dart';
import '../l10n/app_localizations.dart';
import '../utils/breakpoints.dart';
import '../utils/chore_assigner.dart';
import '../widgets/navigation_bar.dart';

/// Number of rows the year's table needs.
///
/// Most years have 52 ISO weeks. A year has 53 when 1 January falls on a
/// Thursday, or on a Wednesday in a leap year — the two cases that leave
/// enough days over for a final full week.
/// See https://eduardklein.com/life/how-many-weeks-in-a-year/
int weeksInYear(int year) {
  final firstDay = DateTime(year, 1, 1).weekday;
  final startsLong = firstDay == DateTime.thursday ||
      (isLeapYear(year) && firstDay == DateTime.wednesday);
  return startsLong ? 53 : 52;
}

/// Which row of the table represents "this week".
///
/// In late December the ISO week number wraps round to 1 because that week
/// already belongs to the next year — the row to highlight is then the last
/// one of this table, not row 1.
int currentWeekRow(DateTime now, int numberOfWeeks) {
  final week = now.weekOfYear;
  if (week == 1 && now.month == DateTime.december) return numberOfWeeks;
  return week;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: MemberManager.instance,
        builder: (BuildContext context, Widget? child) {
          return FutureBuilder<void>(
              future: MemberManager.instance.dataFuture,
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                // Only show the spinner on the first load; on later refreshes
                // keep the existing table mounted (avoids losing scroll
                // position and rebuilding the whole grid on every save).
                final firstLoad = MemberManager.instance.memberCount == -1;
                if (snapshot.connectionState == ConnectionState.waiting &&
                    firstLoad) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError && firstLoad) {
                  return Text('Error: ${snapshot.error}');
                }
                if (firstLoad) {
                  // No WG data (e.g. the user just left one) — nothing to draw,
                  // and the column sizing below has no member count to work with.
                  return const SizedBox.shrink();
                }
                return const Overview();
              });
        });
  }
}

class Overview extends StatefulWidget {
  const Overview({super.key});

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  late AutoScrollController horizontalController;
  late AutoScrollController verticalController;
  int scrollOffset = max(0, DateTime.now().weekOfYear - 2);
  static const double _compactRowHeight = 50;
  static const double _expandedRowHeight = 58;
  double rowHeight = _compactRowHeight;
  MemberManager manager = MemberManager.instance;
  String username = "-1";

  /// week index (0-based) → member uid → roles, rebuilt only when the
  /// underlying WG data changes rather than on every widget rebuild.
  List<Map<String, List<String>>> _assignmentsByWeek = const [];

  @override
  void initState() {
    super.initState();
    manager.addListener(_onManagerChanged);
    username = manager.username;
    horizontalController = AutoScrollController(axis: Axis.horizontal);
    verticalController = AutoScrollController(axis: Axis.vertical);
    _rebuildAssignments();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentWeek());
  }

  void _onManagerChanged() {
    _rebuildAssignments();
    setState(() {});
  }

  @override
  void dispose() {
    manager.removeListener(_onManagerChanged);
    horizontalController.dispose();
    verticalController.dispose();
    super.dispose();
  }

  /// The uids shown as columns, in the same order as [_sortedNames].
  List<String> get _sortedUids => [
        if (manager.active && manager.userID != null) manager.userID!,
        ...manager.memberUids,
      ];

  /// The display names shown as column headers. Names are not unique, which
  /// is exactly why the assignment itself is keyed by uid.
  List<String> get _sortedNames => [
        if (manager.active) manager.username,
        ...manager.members,
      ];

  void _rebuildAssignments() {
    final uids = _sortedUids;
    final numberOfWeeks = weeksInYear(DateTime.now().year);

    if (manager.tasks.isEmpty || uids.isEmpty) {
      _assignmentsByWeek =
          List.generate(numberOfWeeks, (_) => const <String, List<String>>{});
      return;
    }

    // A local assigner so the shared choreAssigner's state is not mutated.
    final assigner = RoleAssigner.create(
      manager.algorithm,
      List<String>.from(uids),
      manager.tasks.keys.toList(),
      noRepeatWindow: manager.noRepeatWindow,
    );
    // Weeks are requested in order: RotatingAssigner replays incrementally
    // forward, so the whole year costs one pass rather than one per row.
    _assignmentsByWeek = [
      for (int week = 1; week <= numberOfWeeks; week++)
        assigner.assignRoles(week),
    ];
  }

  /// Relative widths for the member columns.
  ///
  /// On a phone these keep the hand-tuned proportions the layout was built
  /// with. From the medium width class up — which is what a tablet or an
  /// unfolded foldable gets, since Android 17 ignores this app's portrait
  /// request there — every member gets an equal share, because a rota grid
  /// has no reason to favour one column once there is room for all of them.
  List<ColumnSize> _columnSizes(int memberColumns) {
    if (!NavBarMetrics.sizeOf(context).isCompact) {
      return List.generate(memberColumns, (_) => ColumnSize.M);
    }
    switch (memberColumns) {
      case 1:
        return [ColumnSize.L];
      case 2:
        return [ColumnSize.M, ColumnSize.M];
      case 3:
        return [ColumnSize.M, ColumnSize.M, ColumnSize.L];
      case 4:
        return [ColumnSize.L, ColumnSize.L, ColumnSize.L, ColumnSize.M];
      default:
        return List.generate(memberColumns, (_) => ColumnSize.M);
    }
  }

  List<DataColumn2> _generateColumns() {
    final sortedNames = _sortedNames;
    final columns = <DataColumn2>[];

    columns.add(DataColumn2(
        label: Container(
            decoration: BoxDecoration(
              border: Border(
                  right: BorderSide(
                      width: 1,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.2))),
            ),
            child: Center(
                child: Text(AppLocalizations.of(context)!.cw,
                    style: const TextStyle(fontWeight: FontWeight.bold)))),
        size: ColumnSize.M));

    final columnSizes = _columnSizes(sortedNames.length);

    for (int i = 0; i < sortedNames.length; i++) {
      columns.add(DataColumn2(
          label: Center(child: Text(sortedNames[i])), size: columnSizes[i]));
    }

    return columns;
  }

  List<DataRow2> _generateRows() {
    final rows = <DataRow2>[];
    final numberOfWeeks = weeksInYear(DateTime.now().year);
    final currentRow = currentWeekRow(DateTime.now(), numberOfWeeks);
    final uids = _sortedUids;
    final dividerColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2);

    for (int i = 0; i < numberOfWeeks; i++) {
      final weekNumber = i + 1;
      final isCurrent = weekNumber == currentRow;
      final isPast = weekNumber < currentRow;
      // The fallback has to carry the real type: a bare `const {}` is a
      // Map<dynamic, dynamic>, which drags the whole ternary to dynamic and
      // turns the icon map() below into a dynamic call that yields
      // List<dynamic> — "List<dynamic> is not a subtype of List<Widget>" the
      // moment Row tries to render it.
      final Map<String, List<String>> currentRoles =
          i < _assignmentsByWeek.length
              ? _assignmentsByWeek[i]
              : const <String, List<String>>{};

      final cells = <DataCell>[];
      cells.add(DataCell(
          Container(
              decoration: BoxDecoration(
                  border:
                      Border(right: BorderSide(width: 1, color: dividerColor))),
              child: Center(
                  child: Text(weekNumber.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold)))),
          onTap: () {}));

      for (final uid in uids) {
        final roles = currentRoles[uid] ?? const <String>[];
        final icons = roles
            .map((role) => Icon(manager.roleIcons[role] ?? Icons.work_outline))
            .toList();
        cells.add(DataCell(
          Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: icons)),
          onTap: () {},
        ));
      }

      rows.add(DataRow2(
        color: WidgetStateProperty.all(
          isCurrent
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
              : isPast
                  ? Colors.grey.withValues(alpha: 0.05)
                  : Theme.of(context).colorScheme.surface,
        ),
        specificRowHeight: rowHeight,
        cells: cells,
      ));
    }

    return rows;
  }

  Future _scrollToCurrentWeek() async {
    if (!mounted || !verticalController.hasClients) return;
    verticalController.animateTo(rowHeight * scrollOffset,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    final windowSize = NavBarMetrics.sizeOf(context);
    rowHeight = windowSize == WindowSize.expanded
        ? _expandedRowHeight
        : _compactRowHeight;
    // Room for the week column plus a readable column per member; below that
    // the table scrolls sideways instead of squeezing names and icons into
    // unreadable slivers.
    final minWidth = 72.0 + 96.0 * _sortedNames.length;

    return RefreshIndicator(
      onRefresh: () async {
        await MemberManager.instance.fetchWGData();
        _rebuildAssignments();
        setState(() {});
      },
      child: DataTable2(
        scrollController: verticalController,
        horizontalScrollController: horizontalController,
        fixedTopRows: 1,
        minWidth: minWidth,
        columns: _generateColumns(),
        rows: _generateRows(),
        columnSpacing: 0,
      ),
    );
  }
}
