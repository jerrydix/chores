import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<DataColumn2> _generateColumns() {
    List<DataColumn2> columns = [];
    columns.add(DataColumn2(label: Container(decoration: const BoxDecoration(border: Border(right: BorderSide(width: 1, color: Colors.black26))), child: const Center(child: Text('KW', style: TextStyle(fontWeight: FontWeight.bold)))), size: ColumnSize.M));
    columns.add(const DataColumn2(label: Center(child: Text('David')), size: ColumnSize.L));
    columns.add(const DataColumn2(label: Center(child: Text('Jeremy')), size: ColumnSize.L));
    columns.add(const DataColumn2(label: Center(child: Text('Simon')), size: ColumnSize.L));
    columns.add(const DataColumn2(label: Center(child: Text('Noah')), size: ColumnSize.M));
    return columns;
  }

  List<DataRow2> _generateRows() {
    List<DataRow2> rows = [];
    int variant = 0;
    for (int i = 0; i < 52; i++) {
      if (variant == 0) {
        rows.add(DataRow2(cells: [
          DataCell(Container(decoration: const BoxDecoration(border: Border(right: BorderSide(width: 1, color: Colors.black26))), child: Center(child: Text((i+1).toString(), style: const TextStyle(fontWeight: FontWeight.bold)))), onTap: () { debugPrint('Cell tapped.');}),
          DataCell(const Center(child: Icon(Icons.delete_outlined)), onTap: () { debugPrint('Cell tapped.');}),
          DataCell(const Center(child: Icon(Icons.kitchen_outlined)), onTap: () { debugPrint('Cell tapped.');}),
          DataCell(const Center(child: Icon(Icons.bathtub_outlined)), onTap: () { debugPrint('Cell tapped.');}),
          DataCell(const Center(child: Icon(Icons.cleaning_services_outlined)), onTap: () { debugPrint('Cell tapped.');}),
        ]));
        variant++;
      } else if (variant == 1) {
        rows.add(DataRow2(cells: [
          DataCell(Container(decoration: const BoxDecoration(border: Border(right: BorderSide(width: 1, color: Colors.black26))), child: Center(child: Text((i+1).toString(), style: const TextStyle(fontWeight: FontWeight.bold)))), onTap: () { debugPrint('Cell tapped.');}),
          DataCell(const Center(child: Icon(Icons.cleaning_services_outlined)), onTap: () { debugPrint('Cell tapped.');}),
          DataCell(const Center(child: Icon(Icons.delete_outlined)), onTap: () { debugPrint('Cell tapped.');}),
          DataCell(const Center(child: Icon(Icons.kitchen_outlined)), onTap: () { debugPrint('Cell tapped.');}),
          DataCell(const Center(child: Icon(Icons.bathtub_outlined)), onTap: () { debugPrint('Cell tapped.');}),
        ]));
        variant++;
      } else if (variant == 2) {
        rows.add(DataRow2(cells: [
          DataCell(Container(decoration: const BoxDecoration(border: Border(right: BorderSide(width: 1, color: Colors.black26))), child: Center(child: Text((i+1).toString(), style: const TextStyle(fontWeight: FontWeight.bold)))), onTap: () { debugPrint('Cell tapped.');}),
          DataCell(const Center(child: Icon(Icons.bathtub_outlined)), onTap: () { debugPrint('Cell tapped.');}),
          DataCell(const Center(child: Icon(Icons.cleaning_services_outlined)), onTap: () { debugPrint('Cell tapped.');}),
          DataCell(const Center(child: Icon(Icons.delete_outlined)), onTap: () { debugPrint('Cell tapped.');}),
          DataCell(const Center(child: Icon(Icons.kitchen_outlined)), onTap: () { debugPrint('Cell tapped.');}),
        ]));
        variant++;
      } else if (variant == 3) {
        rows.add(DataRow2(cells: [
          DataCell(Container(decoration: const BoxDecoration(border: Border(right: BorderSide(width: 1, color: Colors.black26))), child: Center(child: Text((i+1).toString(), style: const TextStyle(fontWeight: FontWeight.bold)))), onTap: () { debugPrint('Cell tapped.');}),
          DataCell(const Center(child: Icon(Icons.kitchen_outlined)), onTap: () { debugPrint('Cell tapped.');}),
          DataCell(const Center(child: Icon(Icons.bathtub_outlined)), onTap: () { debugPrint('Cell tapped.');}),
          DataCell(const Center(child: Icon(Icons.cleaning_services_outlined)), onTap: () { debugPrint('Cell tapped.');}),
          DataCell(const Center(child: Icon(Icons.delete_outlined)), onTap: () { debugPrint('Cell tapped.');}),
        ]));
        variant = 0;
      }
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return DataTable2(
      fixedTopRows: 1,
      columns: _generateColumns(),
      rows: _generateRows(),
      columnSpacing: 0,
    );
  }
}