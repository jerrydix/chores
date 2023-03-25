import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'login.dart';
import 'current_chores.dart';
import 'navigationbar.dart';

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
      home: const NavBar(),
    );
  }
}
