import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

class CurrentPage extends StatefulWidget {
  const CurrentPage({super.key, required this.title});

  final String title;

  @override
  State<CurrentPage> createState() => _CurrentPageState();
}

class _CurrentPageState extends State<CurrentPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Color buttonColor = Colors.greenAccent.withOpacity(0.75);

  Card _createCard(String name) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      color: Colors.teal,
      child: InkWell(
        splashColor: Colors.grey.withAlpha(30),
        onTap: () {
          debugPrint('Card tapped.');
        },
        child: SizedBox(
          width: 0.1,
          height: 0.1,
          child: Center(child: Text(name)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
      return ListView(
        padding: const EdgeInsets.all(0),
        physics: const NeverScrollableScrollPhysics(),
        children:<Widget>[
          Container(
            height: 16,
            child: const Text('Current Chores'),
          ),
          Container(
            height: 400,
            child: _createCard('Sample'),
          ),
        ],
      );
      /*floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('Card tapped.');
        },
        foregroundColor: Colors.green,
        backgroundColor: Colors.green,
        hoverColor: Colors.grey,
        hoverElevation: 10,
      ),
    );*/
  }
}
