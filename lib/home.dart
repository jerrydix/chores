import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  List<DataColumn2> _generateColumns() {
    List<DataColumn2> columns = [];
    columns.add(const DataColumn2(label: Text('David')));
    columns.add(const DataColumn2(label: Text('Jeremy')));
    columns.add(const DataColumn2(label: Text('Simon')));
    columns.add(const DataColumn2(label: Text('Noah')));
    return columns;
  }

  List<DataRow2> _generateRows() {
    List<DataRow2> rows = [];
    for (int i = 0; i < 50; i++) {
      rows.add(const DataRow2(cells: [
        DataCell(Text('Müllmeister')),
        DataCell(Text('Küchenchef')),
        DataCell(Text('Bademeister')),
        DataCell(Text('Saubstauger'))
      ]));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return DataTable2(
      fixedTopRows: 1,
      columns: _generateColumns(),
      rows: _generateRows()
    );
  }
}