import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chores',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Current Chores'),
    );
  }
}

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
    for (int i = 0; i < 2; i++) {
      columns.add(const DataColumn2(label: Text('Test')));
    }
    return columns;
  }

  List<DataRow2> _generateRows() {
    List<DataRow2> columns = [];
    for (int i = 0; i < 100; i++) {
      columns.add(const DataRow2(
          cells: [DataCell(Text('test')), DataCell(Text('test2'))]));
    }
    return columns;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: DataTable2(
        fixedTopRows: 1,
        columns: _generateColumns(),
        rows: _generateRows(),
      ),
    );
  }
}
