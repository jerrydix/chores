
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:animations/animations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

import 'checklist.dart';

class CurrentPage extends StatefulWidget {
  const CurrentPage({super.key, required this.title});

  final String title;

  @override
  State<CurrentPage> createState() => _CurrentPageState();
}

class _CurrentPageState extends State<CurrentPage> {
  Map<String, dynamic>? file;

  Color buttonColor = Colors.greenAccent.withOpacity(0.75);
  int tasksAmount = 5;

  BoolList checked = BoolList(5);

  List<TextStyle> styles = <TextStyle>[];
  void fillStyles() {
    for (int i = 0; i < tasksAmount; i++) {
      styles.add(const TextStyle(decoration: TextDecoration.none,));
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

  Future<void> init() async {
    fillStyles();
    file = jsonDecode(await _localFile);
  }

  void styleSwitcher(int i, bool value) {
    if (value) {
      styles[i] = TextStyle(decoration: TextDecoration.lineThrough, color: styles[i].color?.withOpacity(0.75));
    } else {
      styles[i] = TextStyle(decoration: TextDecoration.none, color: styles[i].color?.withOpacity(1));
    }
  }

  Future<String> get _localFile async {
    return rootBundle.loadString('assets/config.json');
  }

  @override
  Widget build(BuildContext context) {
    init();
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
                child: Scrollbar(
                  radius: const Radius.circular(10),
                  thickness: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CheckboxTile(title: "test", style: styles.elementAt(0), checked: checked[0], icon: const Icon(Icons.abc)),
                        CheckboxTile(title: "test", style: styles.elementAt(1), checked: checked[1], icon: const Icon(Icons.delete)),
                        CheckboxTile(title: "test", style: styles.elementAt(2), checked: checked[2], icon: const Icon(Icons.airplane_ticket)),
                        CheckboxTile(title: "test", style: styles.elementAt(3), checked: checked[3], icon: const Icon(Icons.traffic_sharp)),

                      ],
                    )
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: OpenContainer(
                  transitionType: ContainerTransitionType.fadeThrough,
                  closedColor: Theme.of(context).colorScheme.surfaceVariant,
                  middleColor: Theme.of(context).colorScheme.background,
                  openColor:  Theme.of(context).colorScheme.background,
                  transitionDuration: const Duration(milliseconds: 350),
                  closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  closedBuilder: (context, action) {
                    return const SizedBox(
                      width: 111,
                      height: 111,
                      child: Center(child: Text('Test')),
                    );
                  },
                  openBuilder: (context, action) {
                    return const ChecklistPage(title: 'Garbage Man', list: <String>[]);
                }),
              ),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: OpenContainer(
                    transitionType: ContainerTransitionType.fadeThrough,
                    closedColor: Theme.of(context).colorScheme.surfaceVariant,
                    middleColor: Theme.of(context).colorScheme.background,
                    openColor:  Theme.of(context).colorScheme.background,
                    transitionDuration: const Duration(milliseconds: 350),
                    closedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    closedBuilder: (context, action) {
                      return const SizedBox(
                        width: 111,
                        height: 111,
                        child: Center(child: Text('Test')),
                      );
                    },
                    openBuilder: (context, action) {
                      return const ChecklistPage(title: 'Garbage Man', list: <String>[]);
                    }),
              ),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: OpenContainer(
                    transitionType: ContainerTransitionType.fadeThrough,
                    closedColor: Theme.of(context).colorScheme.surfaceVariant,
                    middleColor: Theme.of(context).colorScheme.background,
                    openColor:  Theme.of(context).colorScheme.background,
                    transitionDuration: const Duration(milliseconds: 350),
                    closedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    closedBuilder: (context, action) {
                      return const SizedBox(
                        width: 111,
                        height: 111,
                        child: Center(child: Text('Test')),
                      );
                    },
                    openBuilder: (context, action) {
                      return const ChecklistPage(title: 'Garbage Man', list: <String>[]);
                    }),
              ),
            ],
          )
        ],
      ),
    );
  }
}



class CheckboxTile extends StatefulWidget {
  CheckboxTile({super.key, required this.title, required this.style, required this.checked, required this.icon});

  String title = "";
  TextStyle style = const TextStyle(decoration: TextDecoration.none,);
  bool checked = false;
  Icon icon = const Icon(Icons.delete);

  @override
  State<CheckboxTile> createState() => _CheckboxTileState(title, style, checked, icon);


}

class _CheckboxTileState extends State<CheckboxTile> {
  _CheckboxTileState(this.title, this.style, this.checked, this.icon);

  String title = "";
  TextStyle style = const TextStyle(decoration: TextDecoration.none,);
  bool checked = false;
  Icon icon = const Icon(Icons.delete);


  void styleSwitcher(bool value) {
    if (value) {
      style = TextStyle(decoration: TextDecoration.lineThrough, color: style.color?.withOpacity(0.75));
    } else {
      style = TextStyle(decoration: TextDecoration.none, color: style.color?.withOpacity(1));
    }
  }

  @override
  Widget build(BuildContext context) {

    return CheckboxListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: Text(title, style: style),
        value: checked,
        onChanged: (value) {
          setState(() {
            checked = value!;
            styleSwitcher(value);
          });
        },
        secondary: icon);
  }
}
