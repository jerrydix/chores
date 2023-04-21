
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

class CurrentPage extends StatefulWidget {
  const CurrentPage({super.key, required this.title});

  final String title;

  @override
  State<CurrentPage> createState() => _CurrentPageState();
}

class _CurrentPageState extends State<CurrentPage> {
  Color buttonColor = Colors.greenAccent.withOpacity(0.75);
  int tasksAmount = 5;

  BoolList checked = BoolList(5);

  List<TextDecoration> decorations = [TextDecoration.none,TextDecoration.none,TextDecoration.none,TextDecoration.none,TextDecoration.none];
  void fillStyles() {
    for (int i = 0; i < tasksAmount; i++) {
      decorations.add(TextDecoration.none);
    }
  }

  CheckboxListTile createCheckboxTile(Icon icon, Text text, bool? checked) {
    return CheckboxListTile(
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        ),
      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      title: text,
      value: checked,
      onChanged: (value) {
      setState(() {
          checked = value!;
        });
      },
      secondary: icon);
  }

  void init() {
    fillStyles();
  }

  @override
  Widget build(BuildContext context) {
    //init();
    return Center(
      child: Column(
        children: <Widget>[
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: SizedBox(
              width: 348,
              height: 400,
              child: Padding (
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    CheckboxListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        title: const Text('Take out the trash.'),
                        value: checked[0],
                        onChanged: (value) {
                          setState(() {
                            checked[0] = value!;
                          });
                        },
                        secondary: const Icon(Icons.delete)),
                    CheckboxListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        title: const Text('Take out the trash.'),
                        value: checked[1],
                        onChanged: (value) {
                          setState(() {
                            checked[1] = value!;
                            TextDecoration current = decorations.elementAt(1);
                            if (current == TextDecoration.none) {
                              current = TextDecoration.lineThrough;
                            }
                          });
                        },
                        secondary: const Icon(Icons.delete)),
                    CheckboxListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        title: const Text('Take out the trash.'),
                        value: checked[2],
                        onChanged: (value) {
                          setState(() {
                            checked[2] = value!;
                          });
                        },
                        secondary: const Icon(Icons.delete)),
                    CheckboxListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        title: const Text('Take out the trash.'),
                        value: checked[3],
                        onChanged: (value) {
                          setState(() {
                            checked[3] = value!;
                          });
                        },
                        secondary: const Icon(Icons.delete)),
                  ],
                )
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: const SizedBox(
                  width: 111,
                  height: 111,
                  child: Center(child: Text('Test')),
                ),
              ),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: const SizedBox(
                  width: 111,
                  height: 111,
                  child: Center(child: Text('Test')),
                ),
              ),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: const SizedBox(
                  width: 111,
                  height: 111,
                  child: Center(child: Text('Test')),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
