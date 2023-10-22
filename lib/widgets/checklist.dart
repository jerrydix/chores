import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChecklistPage extends StatefulWidget {
  final String title;
  final List<String> roles;
  final LinkedHashMap<String, Icon> tasks;
  final List<bool> checked;


  const ChecklistPage({super.key, required this.title, required this.roles, required this.tasks, required this.checked});

  @override
  State<ChecklistPage> createState() => _ChecklistState();
}

class _ChecklistState extends State<ChecklistPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: createRolesText(),
      ),
      body: ListView(
        children: createListTiles(widget.tasks, widget.checked)
      ),
    );
  }

  List<Widget> createListTiles(LinkedHashMap<String, Icon> tasks, List<bool> checked) {
    List<Widget> result = [];
    for (int i = 0; i < tasks.length; i++) {
      result.add(ListTile(
        leading: tasks.values.elementAt(i),
        title: Text(tasks.keys.elementAt(i)),
        trailing: checked[i] ? const Icon(Icons.check_box_rounded) : const Icon(Icons.check_box_outline_blank_rounded),
      ),);
    }
    return result;
  }

  Text createRolesText() {
    String text = "${widget.title} (";
    for (var element in widget.roles) {
      text += "$element, ";
    }
    text = text.substring(0, text.length - 2);
    text += ")";
    return Text(text);
  }
}
