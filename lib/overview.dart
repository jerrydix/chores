import 'package:chores/member_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:week_of_year/date_week_extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AutoScrollController controller;
  int scrollOffset = DateTime.now().weekOfYear - 2;
  double rowHeight = 50;
  List<List<int>> allRoles = [];
  List<DataRow2> rows = [];
  List<DataColumn2> columns = [];

  @override
  Future<void> initState() async {
    super.initState();
    controller = AutoScrollController(
      axis: Axis.vertical,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentWeek());
  }

  List<DataColumn2> _generateColumns() {
    List<DataColumn2> columns = [];

    List<String> sortedNames = [];
    sortedNames.add(MemberManager.instance.username);
    sortedNames.addAll(MemberManager.instance.otherNames);

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

    switch (allRoles.length) {
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
        if (kDebugMode) {
          print("Member Count invalid!");
        }
      }
    }

    for (int i = 0; i < sortedNames.length; i++) {
      columns.add(DataColumn2(
          label: Center(child: Text(sortedNames[i])), size: columnSizes[i]));
    }

    return columns;
  }

  //TODO wtf is this
  List<DataRow2> _generateRows() {

    List<DataRow2> rows = [];
    int variant = 0;
    bool current = false;
    bool wasCurrent = false;

    for (int i = 0; i < DateTime.utc(DateTime.now().year, 12, 31).weekOfYear; i++) {

      if (DateTime.now().weekOfYear == i + 1) {
        current = true;
        wasCurrent = true;
      } else {
        current = false;
      }

      allRoles = MemberManager.instance.setRoles(i + 1, false);
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

      for (var roles in allRoles) {
        List<Icon> currentIcons = [];
        for (var role in roles) {
          switch (role) {
            case 0:
              {
                currentIcons.add(const Icon(Icons.delete_outlined));
                break;
              }
            case 1:
              {
                currentIcons.add(const Icon(Icons.bathtub_outlined));
                break;
              }
            case 2:
              {
                currentIcons.add(const Icon(Icons.soup_kitchen_outlined));
                break;
              }
            case 3:
              {
                currentIcons.add(const Icon(Icons.cleaning_services_outlined));
                break;
              }
          }
        }

        cells.add(DataCell(
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: currentIcons,
              ),
            ), onTap: () {}),
        );
      }

      rows.add(DataRow2(
        color: (() {
          if (current) {
            return MaterialStateProperty.all(
                Theme
                    .of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.15));
          }
          if (wasCurrent) {
            return MaterialStateProperty.all(
                Theme
                    .of(context)
                    .colorScheme
                    .surface);
          }
          return MaterialStateProperty.all(Colors.grey.withOpacity(0.05));
        }()),
        specificRowHeight: rowHeight,
        cells: cells,
      ));
    }

    return rows;
  }

  Future _scrollToCurrentWeek() async {
    Future.delayed(const Duration(seconds: 1), () {
      controller.animateTo(rowHeight * scrollOffset,
          duration: const Duration(seconds: 1), curve: Curves.ease);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DataTable2(
      scrollController: controller,
      fixedTopRows: 1,
      columns: _generateColumns(),
      rows: _generateRows(),
      columnSpacing: 0,
    );
  }
}
