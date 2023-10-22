import 'package:chores/member_manager.dart';
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

  @override
  void initState() {
    super.initState();
    controller = AutoScrollController(
      // viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.vertical,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentWeek());
  }

  List<DataColumn2> _generateColumns() {
    List<DataColumn2> columns = [];
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
    columns.add(const DataColumn2(
        label: Center(child: Text('David')), size: ColumnSize.L));
    columns.add(const DataColumn2(
        label: Center(child: Text('Jeremy')), size: ColumnSize.L));
    /*columns.add(const DataColumn2(
        label: Center(child: Text('Simon')), size: ColumnSize.L));
    columns.add(const DataColumn2(
        label: Center(child: Text('Noah')), size: ColumnSize.M));*/
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

      List<List<int>> allRoles = MemberManager.instance.setRoles(i + 1, false);
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

      /*if (variant == 0) {
        rows.add(DataRow2(
            color: (() {
              if (current) {
                return MaterialStateProperty.all(
                    Theme.of(context).colorScheme.primary.withOpacity(0.15));
              }
              if (wasCurrent) {
                return MaterialStateProperty.all(
                    Theme.of(context).colorScheme.surface);
              }
              return MaterialStateProperty.all(Colors.grey.withOpacity(0.05));
            }()),
            specificRowHeight: rowHeight,
            cells: [
              DataCell(
                  Container(
                      decoration: BoxDecoration(
                          border: Border(
                              right: BorderSide(
                                  width: 1,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.2)))),
                      child: Center(
                          child: Text((i + 1).toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)))),
                  onTap: () {}),
              DataCell(
                  const Center(
                    child: Icon(Icons.delete_outlined),
                  ),
                  onTap: () {}),
              DataCell(const Center(child: Icon(Icons.soup_kitchen_outlined)),
                  onTap: () {}),
              DataCell(const Center(child: Icon(Icons.bathtub_outlined)),
                  onTap: () {}),
              DataCell(
                  const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cleaning_services_outlined),
                      ],
                    ),
                  ), onTap: () {
                debugPrint('Cell tapped.');
              }),
            ]));
        variant++;
      } else if (variant == 1) {
        rows.add(DataRow2(
            color: (() {
              if (current) {
                return MaterialStateProperty.all(
                    Theme.of(context).colorScheme.primary.withOpacity(0.15));
              }
              if (wasCurrent) {
                return MaterialStateProperty.all(
                    Theme.of(context).colorScheme.surface);
              }
              return MaterialStateProperty.all(Colors.grey.withOpacity(0.05));
            }()),
            specificRowHeight: rowHeight,
            cells: [
              DataCell(
                  Container(
                      decoration: BoxDecoration(
                          border: Border(
                              right: BorderSide(
                                  width: 1,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.2)))),
                      child: Center(
                          child: Text((i + 1).toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)))),
                  onTap: () {}),
              DataCell(
                  const Center(child: Icon(Icons.cleaning_services_outlined)),
                  onTap: () {}),
              DataCell(const Center(child: Icon(Icons.delete_outlined)),
                  onTap: () {}),
              DataCell(const Center(child: Icon(Icons.kitchen_outlined)),
                  onTap: () {}),
              DataCell(const Center(child: Icon(Icons.bathtub_outlined)),
                  onTap: () {}),
            ]));
        variant++;
      } else if (variant == 2) {
        rows.add(DataRow2(
            color: (() {
              if (current) {
                return MaterialStateProperty.all(
                    Theme.of(context).colorScheme.primary.withOpacity(0.15));
              }
              if (wasCurrent) {
                return MaterialStateProperty.all(
                    Theme.of(context).colorScheme.surface);
              }
              return MaterialStateProperty.all(Colors.grey.withOpacity(0.05));
            }()),
            specificRowHeight: rowHeight,
            cells: [
              DataCell(
                  Container(
                      decoration: BoxDecoration(
                          border: Border(
                              right: BorderSide(
                                  width: 1,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.2)))),
                      child: Center(
                          child: Text((i + 1).toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)))),
                  onTap: () {}),
              DataCell(const Center(child: Icon(Icons.bathtub_outlined)),
                  onTap: () {}),
              DataCell(
                  const Center(child: Icon(Icons.cleaning_services_outlined)),
                  onTap: () {}),
              DataCell(const Center(child: Icon(Icons.delete_outlined)),
                  onTap: () {}),
              DataCell(const Center(child: Icon(Icons.kitchen_outlined)),
                  onTap: () {}),
            ]));
        variant++;
      } else if (variant == 3) {
        rows.add(DataRow2(
            color: (() {
              if (current) {
                return MaterialStateProperty.all(
                    Theme.of(context).colorScheme.primary.withOpacity(0.15));
              }
              if (wasCurrent) {
                return MaterialStateProperty.all(
                    Theme.of(context).colorScheme.surface);
              }
              return MaterialStateProperty.all(Colors.grey.withOpacity(0.05));
            }()),
            specificRowHeight: rowHeight,
            cells: [
              DataCell(
                  Container(
                      decoration: BoxDecoration(
                          border: Border(
                              right: BorderSide(
                                  width: 1,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.2)))),
                      child: Center(
                          child: Text((i + 1).toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)))),
                  onTap: () {}),
              DataCell(const Center(child: Icon(Icons.kitchen_outlined)),
                  onTap: () {}),
              DataCell(const Center(child: Icon(Icons.bathtub_outlined)),
                  onTap: () {}),
              DataCell(
                  const Center(child: Icon(Icons.cleaning_services_outlined)),
                  onTap: () {}),
              DataCell(const Center(child: Icon(Icons.delete_outlined)),
                  onTap: () {}),
            ]));
        variant = 0;
      }
    }*/

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
