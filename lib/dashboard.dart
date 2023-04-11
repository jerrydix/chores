
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

  BoolList checked = BoolList(5);

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

  @override
  Widget build(BuildContext context) {
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
                    createCheckboxTile(const Icon(Icons.delete_outlined), const Text('Take out the trash'), checked.elementAt(0)),
                    createCheckboxTile(const Icon(Icons.delete_outlined), const Text('Take out the trash'), checked.elementAt(1)),
                    createCheckboxTile(const Icon(Icons.delete_outlined), const Text('Take out the trash'), checked.elementAt(2)),
                    createCheckboxTile(const Icon(Icons.delete_outlined), const Text('Take out the trash'), checked.elementAt(3)),
                    //createCheckboxTile(const Icon(Icons.delete_outlined), const Text('Take out the trash'), checked[4]),
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
