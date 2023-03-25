import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<DataColumn2> _generateColumns() {
    List<DataColumn2> columns = [];
    columns.add(const DataColumn2(label: Center(child: Text('David', textAlign: TextAlign.center)), size: ColumnSize.S));
    columns.add(const DataColumn2(label: Center(child: Text('Jeremy', textAlign: TextAlign.center)), size: ColumnSize.M));
    columns.add(const DataColumn2(label: Center(child: Text('Simon', textAlign: TextAlign.center)), size: ColumnSize.M));
    columns.add(const DataColumn2(label: Center(child: Text('Noah', textAlign: TextAlign.center)), size: ColumnSize.S));
    return columns;
  }

  List<DataRow2> _generateRows() {
    List<DataRow2> rows = [];
    for (int i = 0; i < 50; i++) {
      rows.add(const DataRow2(cells: [
        DataCell(Center(child: Icon(Icons.delete_outlined))),
        DataCell(Center(child: Icon(Icons.kitchen_outlined))),
        DataCell(Center(child: Icon(Icons.bathtub_outlined))),
        DataCell(Center(child: Icon(Icons.cleaning_services_outlined))),
      ]));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return DataTable2(
      fixedTopRows: 1,
      columns: _generateColumns(),
      rows: _generateRows(),
    );
  }
}