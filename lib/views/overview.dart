import 'package:chores/member_manager.dart';
import 'package:chores/utils/icon_converter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quiver/time.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:week_of_year/date_week_extensions.dart';
import 'package:chores/l10n/app_localizations.dart';

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
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    const Center(child: CircularProgressIndicator());
                    break;
                  default:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    return const Overview();
                }
                return const Center(child: CircularProgressIndicator());
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
  int scrollOffset = DateTime.now().weekOfYear - 2;
  double rowHeight = 50;
  //List<List<int>> allRoles = [];
  List<Map<String, List<String>>> allRoles = [];
  List<DataRow2> rows = [];
  List<DataColumn2> columns = [];
  MemberManager manager = MemberManager.instance;
  String username = "-1";

  @override
  void initState() {
    super.initState();
    username = manager.username;
    horizontalController = AutoScrollController(
      axis: Axis.horizontal
    );
    verticalController = AutoScrollController(
      axis: Axis.vertical
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentWeek());
  }

  List<DataColumn2> _generateColumns() {

    List<DataColumn2> columns = [];
    List<String> sortedNames = [];
    if (manager.active) {
      sortedNames.add(manager.username);
    }
    sortedNames.addAll(manager.members);

    columns.add(DataColumn2(
        label: Container(
            decoration: BoxDecoration(
              border: Border(
                  right: BorderSide(
                      width: 1,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.2))),
            ),
            child: Center(
                child: Text(AppLocalizations.of(context)!.cw,
                    style: const TextStyle(fontWeight: FontWeight.bold)))),
        size: ColumnSize.M));

    List<ColumnSize> columnSizes = [];

    switch (manager.memberCount) {
      case 1: {
        columnSizes = [ColumnSize.L];
        break;
      }
      case 2: {
        columnSizes = [ColumnSize.M, ColumnSize.M];
        break;
      }
      case 3: {
        columnSizes = [ColumnSize.M, ColumnSize.M, ColumnSize.L];
        break;
      }
      case 4: {
        columnSizes = [ColumnSize.L, ColumnSize.L, ColumnSize.L, ColumnSize.M];
        break;
      }
      default: {
        columnSizes = List.generate(manager.memberCount, (index) => ColumnSize.M);
        columnSizes[manager.memberCount - 1] = ColumnSize.L;
        if (kDebugMode) {
          print("Member count ${manager.memberCount} bigger than 4, using generic column sizes.");
        }
      }
    }

    for (int i = 0; i < sortedNames.length; i++) {
      columns.add(DataColumn2(
          label: Center(child: Text(sortedNames[i])), size: columnSizes[i]));
    }

    return columns;
  }

  List<DataRow2> _generateRows() {

    List<DataRow2> rows = [];
    bool current = false;
    bool wasCurrent = false;
    int numberOfWeeks = 52;

    //53 weeks edge cases https://eduardklein.com/life/how-many-weeks-in-a-year/
    if (isLeapYear(DateTime.now().year) && DateTime(DateTime.now().year, 1, 1).weekday == DateTime.thursday || !isLeapYear(DateTime.now().year) && DateTime(DateTime.now().year, 1, 1).weekday == DateTime.wednesday) {
      numberOfWeeks = 53;
    }

    for (int i = 0; i < numberOfWeeks; i++) {

      if (DateTime.now().weekOfYear == i + 1 && DateTime.now().weekOfYear != 1 || DateTime.now().weekOfYear == i + 1 && DateTime.now().weekOfYear == 1 && DateTime.now().month != DateTime.december || DateTime.now().weekOfYear == 1 && DateTime.now().month == DateTime.december && numberOfWeeks == 53) {
        current = true;
        wasCurrent = true;
      } else {
        current = false;
      }
      //print(DateTime.now().weekOfYear);

      var currentRoles = manager.choreAssigner.assignRoles(i + 1);
      allRoles.add(currentRoles);
      List<DataCell> cells = [];
      cells.add(DataCell(
          Container(
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(
                          width: 1,
                          color: Theme
                              .of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.2)))),
              child: Center(
                  child: Text((i + 1).toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold)))),
          onTap: () {})
      );

      List<DataCell> currentCells = currentRoles.entries.map((entry) {
        List<Icon> icons = entry.value.map((role) {
          return Icon(IconConverter.stringToIcon(role.split("\$").last));
        }).toList();

        return DataCell(
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: icons,
            ),
          ), onTap: () {},
        );
      }).toList();

      cells.addAll(currentCells);


      // for (var roles in allRoles.keys) {
      //   List<Icon> currentIcons = [];
      //   for (var role in roles) {
      //     switch (role) {
      //       case 0:
      //         {
      //           currentIcons.add(const Icon(Symbols.delete_rounded));
      //           break;
      //         }
      //       case 1:
      //         {
      //           currentIcons.add(const Icon(Symbols.bathroom_rounded));
      //           break;
      //         }
      //       case 2:
      //         {
      //           currentIcons.add(const Icon(Symbols.countertops_rounded));
      //           break;
      //         }
      //       case 3:
      //         {
      //           currentIcons.add(const Icon(Symbols.vacuum_rounded));
      //           break;
      //         }
      //     }
      //   }
      //
      //   cells.add(DataCell(
      //       Center(
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: currentIcons,
      //         ),
      //       ), onTap: () {}),
      //   );
      // }

      rows.add(DataRow2(
        color: (() {
          if (current) {
            return WidgetStateProperty.all(
                Theme
                    .of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.15));
          }
          if (wasCurrent) {
            return WidgetStateProperty.all(
                Theme
                    .of(context)
                    .colorScheme
                    .surface);
          }
          return WidgetStateProperty.all(Colors.grey.withOpacity(0.05));
        }()),
        specificRowHeight: rowHeight,
        cells: cells,
      ));
    }

    return rows;
  }

  Future _scrollToCurrentWeek() async {
    await Future.delayed(const Duration(seconds: 1), () {
      verticalController.animateTo(rowHeight * scrollOffset,
          duration: const Duration(seconds: 1), curve: Curves.ease);
    });

  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
      await MemberManager.instance.fetchWGData();
      setState(() {});
    },
    child: DataTable2(
      scrollController: verticalController,
      horizontalScrollController: horizontalController,
      fixedTopRows: 1,
      columns: _generateColumns(),
      rows: _generateRows(),
      columnSpacing: 0,
    ),
    );
  }
}
