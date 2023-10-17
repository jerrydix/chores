/*
import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../dashboard.dart';
import 'checklist.dart';

import 'package:collection/src/boollist.dart';

import 'navigationbar.dart' as navBar;

class Dashboard4 extends StatefulWidget {

  final int tasksAmount;
  const Dashboard4({super.key, required this.tasksAmount});

  @override
  State<Dashboard4> createState() => _Dashboard4State();
}

class _Dashboard4State extends State<Dashboard4> {

  List<TextStyle> styles = [];
  late BoolList checked;

  @override
  void initState() {
    super.initState();
    checked = BoolList(widget.tasksAmount);
    init();
  }

  Future<void> init() async {
    for (int i = 0; i < widget.tasksAmount; i++) {
      styles.add(const TextStyle(
        decoration: TextDecoration.none,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {

    double actualHeight = kIsWeb ? MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - navBar.getPaddings() : navBar.bodyHeight;

    return Center(
      child: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(10),
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: SizedBox(
              width:
              clampDouble(MediaQuery.of(context).size.width, 0, 500),
              height: (actualHeight - 20) * (8/10),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Scrollbar(
                  radius: const Radius.circular(10),
                  thickness: 3,
                  child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ],
                      )),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 0,
                margin: const EdgeInsets.only(left: 10, right: 5, bottom: 10),
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
                        width: clampDouble(
                            MediaQuery.of(context).size.width / 3 - (13 + 1/3), 0, 161),
                        height: (actualHeight - 20) * (2/10) - 10,
                        child: const InkWell(
                          child: Center(child: Text('Simon')),
                        ),
                      );
                    },
                    openBuilder: (context, action) {
                      return const ChecklistPage(
                          title: 'Garbage Man', list: <String>[]);
                    }),
              ),
              Card(
                elevation: 0,
                margin: const EdgeInsets.only(right: 5, left: 5, bottom: 10),
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
                        width: clampDouble(
                            MediaQuery.of(context).size.width / 3 - (13 + 1/3), 0, 161),
                        height: (actualHeight - 20) * (2/10) - 10,
                        child: const InkWell(
                          child: Center(child: Text('Simon')),
                        ),
                      );
                    },
                    openBuilder: (context, action) {
                      return const ChecklistPage(
                          title: 'Garbage Man', list: <String>[]);
                    }),
              ),
              Card(
                elevation: 0,
                margin: const EdgeInsets.only(left: 5, right: 10, bottom: 10),
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
                        width: clampDouble(
                            MediaQuery.of(context).size.width / 3 - (13 + 1/3), 0, 161),
                        height: (actualHeight - 20) * (2/10) - 10,
                        child: const InkWell(
                          child: Center(child: Text('Simon')),
                        ),
                      );
                    },
                    openBuilder: (context, action) {
                      return const ChecklistPage(
                          title: 'Garbage Man', list: <String>[]);
                    }),
              ),
            ],
          )
        ],
      ),
    );
  }

  void styleSwitcher(int i, bool value) {
    if (value) {
      styles[i] = TextStyle(
          decoration: TextDecoration.lineThrough,
          color: styles[i].color?.withOpacity(0.75));
    } else {
      styles[i] = TextStyle(
          decoration: TextDecoration.none,
          color: styles[i].color?.withOpacity(1));
    }
  }

}*/
