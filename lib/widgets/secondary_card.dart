import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'checklist.dart';
import 'navigationbar.dart' as navBar;
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

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

    for (int i = 0; i < data.titles.length; i++) {

      int completedTaskAmount = 0;
      for (bool checked in data.checkedLists[i]) {
        if (checked) {
          completedTaskAmount++;
        }
      }

      result.add(
        Card(
          elevation: 0,
          margin: data.edgeInsets[i],
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: OpenContainer(
              transitionType: ContainerTransitionType.fadeThrough,
              closedColor: Theme.of(context).colorScheme.secondaryContainer,
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
                    child: Center(child:
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(data.titles[i]),
                          const SizedBox(
                            height: 10,
                          ),
                          SimpleCircularProgressBar(
                            backColor: Theme.of(context).colorScheme.outline,
                            progressColors: [Theme.of(context).colorScheme.primary],
                            mergeMode: true,
                            size: 50,
                            progressStrokeWidth: 5,
                            backStrokeWidth: 5,
                            maxValue: data.checkedLists[i].length.toDouble(),
                            animationDuration: 4,
                            fullProgressColor: Theme.of(context).colorScheme.error,
                            onGetText: (_) {
                              return Text("$completedTaskAmount/${data.checkedLists[i].length}");
                            },
                            valueNotifier: ValueNotifier(completedTaskAmount.toDouble()),
                          ),
                        ]
                      ),
                    )
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