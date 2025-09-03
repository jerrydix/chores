import 'package:flutter/material.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';

import '../l10n/app_localizations.dart';

class RoleTaskSettings extends StatefulWidget {
  const RoleTaskSettings({super.key});

  @override
  State<StatefulWidget> createState() => _RoleTaskSettingsState();
}

class _RoleTaskSettingsState extends State<RoleTaskSettings> {
  late List<DragAndDropList> _taskLists;
  bool _isInitialized = false; // Flag to ensure initialization runs once

  bool? currentNotificationValue;
  Icon? currentNotificationStatus;

  @override
  void initState() {
    super.initState();
    // Do not access Theme.of(context) or AppLocalizations.of(context) here
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize here if not already initialized
    if (!_isInitialized) {
      // Get AppLocalizations instance
      final loc = AppLocalizations.of(context)!; // Assuming it's always available here

      _taskLists = List.generate(4, (listIndex) {
        String headerText;
        TextStyle? headerTextStyle = Theme.of(context).textTheme.titleLarge; // Get theme here

        switch (listIndex) {
          case 0:
            headerText = "test";
            break;
          case 1:
            headerText = "test";
            break;
          case 2:
            headerText = "test";
            break;
          case 3:
            headerText = "test";
            break;
          default:
            headerText = 'List ${listIndex + 1}'; // Fallback
        }

        return DragAndDropList(
          header: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              headerText,
              style: headerTextStyle,
            ),
          ),
          children: List.generate(3, (itemIndex) {
            return DragAndDropItem(
              child: ListTile(
                title: Text('Task ${listIndex * 3 + itemIndex + 1} for $headerText'),
                leading: Icon(Icons.check_circle_outline),
              ),
            );
          }),
        );
      }, growable: false);
      _isInitialized = true;
    }
  }

  void _onItemReorder(int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      final DragAndDropItem movedItem = _taskLists[oldListIndex].children.removeAt(oldItemIndex);
      _taskLists[newListIndex].children.insert(newItemIndex, movedItem);
    });
  }

  void _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      final DragAndDropList movedList = _taskLists.removeAt(oldListIndex);
      _taskLists.insert(newListIndex, movedList);
    });
  }

  @override
  Widget build(BuildContext context) {
    // If _taskLists might not be initialized yet (e.g. if didChangeDependencies hasn't run),
    // you might show a loading indicator. However, with the _isInitialized flag,
    // it should be initialized before the first build after dependencies are available.
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)?.role_task_settings ?? "Settings"),
        ),
        body: Center(child: CircularProgressIndicator()), // Loading state
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.role_task_settings),
      ),
      body: DragAndDropLists(
        children: _taskLists,
        onItemReorder: _onItemReorder,
        onListReorder: _onListReorder,
        listPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemDecorationWhileDragging: BoxDecoration(
          color: Colors.grey.shade200,
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4
          )],
          borderRadius: BorderRadius.circular(8),
        ),
        listInnerDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        lastItemTargetHeight: 8,
        addLastItemTargetHeightToTop: true,
        lastListTargetSize: 40,
        listDragHandle: const DragHandle(
          verticalAlignment: DragHandleVerticalAlignment.top,
          child: Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(
              Icons.drag_handle,
              color: Colors.grey,
            ),
          ),
        ),
        itemDragHandle: const DragHandle(
          child: Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(
              Icons.drag_handle,
              color: Colors.grey,
            ),
          ),
        ),
        axis: Axis.vertical,
        listWidth: 300,
        listDraggingWidth: 300,
        itemSizeAnimationDurationMilliseconds: 300,
        listSizeAnimationDurationMilliseconds: 300,
        listGhost: const SizedBox(
          height: 50,
          width: 300,
          child: Center(
            child: Text(
              'Moving List',
              style: TextStyle(color: Colors.white),
            ),
          ),
          // You can customize the appearance of the ghost list here
        ),
        itemGhost: const SizedBox(
          height: 50,
          child: Center(
            child: Text(
              'Moving Item',
              style: TextStyle(color: Colors.white),
            ),
          ),
          // You can customize the appearance of the ghost item here
        ),
      ),
    );
  }
}
