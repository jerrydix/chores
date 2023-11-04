import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'checklist.dart';
import 'navigationbar.dart' as navBar;

class SecondaryCardData {
  final List<EdgeInsets> edgeInsets;
  final List<double> widths;
  final List<String> titles;
  final List<List<String>> roles;
  final List<LinkedHashMap<String, Icon>> taskLists;
  final List<List<bool>> checkedLists;

  const SecondaryCardData({required this.roles, required this.taskLists, required this.checkedLists, required this.edgeInsets, required this.widths, required this.titles});
}

class SecondaryCard extends StatefulWidget {

  final SecondaryCardData data;

  const SecondaryCard({super.key, required this.data});

  @override
  State<SecondaryCard> createState() => _SecondaryCardState();
}

class _SecondaryCardState extends State<SecondaryCard> {

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: createSecondaryCards(widget.data),
    );
  }

  List<Widget> createSecondaryCards(SecondaryCardData data) {

    double actualHeight = kIsWeb ? MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - navBar.getPaddings() : navBar.bodyHeight;
    List<Widget> result = [];
    print("Length: ${data.titles.length}");

    for (int i = 0; i < data.titles.length; i++) {
      result.add(
        Card(
          elevation: 0,
          margin: data.edgeInsets[i],
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: OpenContainer(
              transitionType: ContainerTransitionType.fadeThrough,
              closedColor: Theme.of(context).colorScheme.surfaceVariant,
              middleColor: Theme.of(context).colorScheme.background,
              openColor: Theme.of(context).colorScheme.background,
              transitionDuration: const Duration(milliseconds: 350),
              closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              closedBuilder: (context, action) {
                return SizedBox(
                  width: data.widths[i],
                  height: (actualHeight - 20) * (2/10) - 10,
                  child: InkWell(
                    child: Center(child: Text(data.titles[i])),
                  ),
                );
              },
              openBuilder: (context, action) {
                return ChecklistPage(title: data.titles[i], roles: data.roles[i], tasks: data.taskLists[i], checked: data.checkedLists[i]);
              }),
        ),);
    }
    return result;
  }
}