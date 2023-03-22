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
        side: BorderSide(
          color: Color.fromARGB(255, 143, 143, 143),
        ),
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      color: buttonColor,
      child: InkWell(
        splashColor: Colors.grey.withAlpha(30),
        onTap: () {
          debugPrint('Card tapped.');
        },
        child: SizedBox(
          width: 150,
          height: 300,
          child: Center(child: Text(name)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
        ),
        body: Center(
          child: GridView.count(
            primary: false,
            padding: const EdgeInsets.all(12),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            children: <Widget>[
              _createCard('David'),
              _createCard('Jeremy'),
              _createCard('Simon'),
              _createCard('Noah')
            ],
          ),
        ));
  }
}
