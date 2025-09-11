import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TaskItem {
  final String id;
  final Icon? icon;
  final String label;

  TaskItem(this.label, this.icon) : id = const Uuid().v4();
}

class TaskList {
  final String id;
  final String title;
  final List<TaskItem> items;
  bool isExpanded;

  TaskList({
    required this.title,
    List<TaskItem>? items,
    this.isExpanded = true,
  })  : id = const Uuid().v4(),
        items = items ?? [];
}

class RoleTaskSettings extends StatefulWidget {
  const RoleTaskSettings({super.key});

  @override
  _RoleTaskSettingsState createState() => _RoleTaskSettingsState();
}

class _RoleTaskSettingsState extends State<RoleTaskSettings> with TickerProviderStateMixin {
  final List<TaskList> lists = [];

  @override
  void initState() {
    super.initState();
    lists.addAll([
      TaskList(title: "List A", items: [
        TaskItem('Item A1', null),
        TaskItem('Item A2', null),
        TaskItem('Item A3', null),
      ]),
      TaskList(title: "List B", items: [
        TaskItem('Item B1', null),
        TaskItem('Item B2', null),
      ]),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Role & Task Settings')),
      body: DragAndDropLists(
        listSizeAnimationDurationMilliseconds: 0,
        children: List.generate(
          lists.length,
              (listIndex) => DragAndDropList(
            key: ValueKey(lists[listIndex].id),
            header: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: _buildCollapsibleHeader(listIndex),
            ),
            canDrag: false,
            contentsWhenEmpty: lists[listIndex].isExpanded
                ? Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No chores for this role',
                style: TextStyle(color: Theme.of(context).disabledColor),
              ),
            )
                : const SizedBox.shrink(),
            lastTarget: Container(
              height: 8,
              alignment: Alignment.center,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            children: [
              DragAndDropItem(
                child: lists[listIndex].isExpanded
                      ? Column(
                    children: List.generate(
                      lists[listIndex].items.length,
                          (itemIndex) {
                        final item = lists[listIndex].items[itemIndex];
                        return Dismissible(
                          key: ValueKey("dismiss_${item.id}"),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            setState(() {
                              lists[listIndex].items.removeAt(itemIndex);
                            });
                          },
                          child: _AnimatedListItem(
                            key: ValueKey("anim_${item.id}"),
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Row(
                                  children: [
                                    if (item.icon != null) ...[
                                      item.icon!,
                                      const SizedBox(width: 10),
                                    ],
                                    Text(item.label),
                                  ],
                                ),
                              ),
                              trailing: const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(Icons.drag_handle),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        ),
        onItemReorder: _onItemReorder,
        itemDragOnLongPress: false,
        listDragOnLongPress: false,
        listPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        contentsWhenEmpty: const Center(
          child: Text('No lists available. Add a new list!'),
        ),
        itemDragHandle: DragHandle(
          verticalAlignment: DragHandleVerticalAlignment.center,
          child: Padding(
            padding: const EdgeInsets.only(right: 30),
            child: Icon(Icons.drag_handle,
                color: Colors.white.withValues(alpha: 0.0)),
          ),
        ),
        itemDecorationWhileDragging: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        onListReorder: (int oldListIndex, int newListIndex) {},
        // 👇 dynamic height depending on dragging
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        distance: 70,
        type: ExpandableFabType.up,
        childrenAnimation: ExpandableFabAnimation.none,
        overlayStyle: ExpandableFabOverlayStyle(
          color: Theme.of(context).colorScheme.onInverseSurface.withOpacity(0.4),
        ),
        children: [
          Row(
            children: [
              const Text('Add Role'),
              const SizedBox(width: 20),
              FloatingActionButton.small(
                onPressed: _openRoleDialog,
                child: const Icon(Icons.person_add_alt_1),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Add Chore'),
              const SizedBox(width: 20),
              FloatingActionButton.small(
                onPressed: _openChoreDialog,
                child: const Icon(Icons.add_task),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future _openRoleDialog() {
    final TextEditingController roleController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Role'),
          content: TextField(
            controller: roleController,
            decoration: const InputDecoration(hintText: 'Role Name'),
            onChanged: (value) => setDialogState(() {}),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                setState(() {
                  lists.add(TaskList(title: value.trim()));
                });
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: roleController.text.trim().isNotEmpty
                  ? () {
                setState(() {
                  lists.add(TaskList(title: roleController.text.trim()));
                });
                Navigator.of(context).pop();
              }
                  : null,
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future _openChoreDialog() {
    final TextEditingController choreController = TextEditingController();
    int? selectedRoleIndex;
    IconData? localIconData;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Chore'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Select Role'),
                value: selectedRoleIndex,
                items: List.generate(
                  lists.length,
                      (index) => DropdownMenuItem(
                    value: index,
                    child: Text(lists[index].title),
                  ),
                ),
                onChanged: (value) {
                  setDialogState(() {
                    selectedRoleIndex = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: choreController,
                      decoration: const InputDecoration(hintText: 'Chore Name'),
                      onChanged: (value) => setDialogState(() {}),
                    ),
                  ),
                  IconButton(
                    icon: localIconData != null ? Icon(localIconData) : const Icon(Icons.image),
                    onPressed: () async {
                      IconData? icon = await showIconPicker(
                        context,
                        iconPackModes: [IconPack.material, IconPack.cupertino, IconPack.fontAwesomeIcons],
                        title: const Text('Pick an icon'),
                        closeChild: const Text('Close'),
                        searchHintText: 'Search icon...',
                        noResultsText: 'No results found',
                        iconSize: 50,
                        adaptiveDialog: true,
                        iconPickerShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      );
                      setDialogState(() {
                        localIconData = icon;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: (choreController.text.trim().isNotEmpty && selectedRoleIndex != null)
                  ? () {
                setState(() {
                  lists[selectedRoleIndex!].items.add(TaskItem(choreController.text.trim(), Icon(localIconData)));
                  // store the icon in TaskItem if needed
                });
                Navigator.of(context).pop();
              }
                  : null,
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsibleHeader(int index) {
    final list = lists[index];
    return ListTile(
      title: Text(list.title),
      leading: IconButton(
        icon: Icon(list.isExpanded ? Icons.expand_less : Icons.expand_more),
        onPressed: () {
          setState(() {
            list.isExpanded = !list.isExpanded;
          });
        },
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Chore',
            onPressed: () => _openChoreDialogForList(index),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Role',
            onPressed: () {
              setState(() {
                lists.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  Future _openChoreDialogForList(int listIndex) {
    final TextEditingController choreController = TextEditingController();
    IconData? localIconData;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add Chore to ${lists[listIndex].title}'),
          content: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: choreController,
                  decoration: const InputDecoration(hintText: 'Chore Name'),
                  onChanged: (value) => setDialogState(() {}),
                ),
              ),
              IconButton(
                icon: localIconData != null ? Icon(localIconData) : const Icon(Icons.image),
                onPressed: () async {
                  IconData? icon = await showIconPicker(
                    context,
                    iconPackModes: [IconPack.material, IconPack.cupertino, IconPack.fontAwesomeIcons],
                    title: const Text('Pick an icon'),
                    closeChild: const Text('Close'),
                    searchHintText: 'Search icon...',
                    noResultsText: 'No results found',
                    iconSize: 50,
                    adaptiveDialog: true,
                    iconPickerShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  );
                  setDialogState(() {
                    localIconData = icon;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: choreController.text.trim().isNotEmpty
                  ? () {
                setState(() {
                  lists[listIndex].items.add(TaskItem(choreController.text.trim(), Icon(localIconData)));
                });
                Navigator.of(context).pop();
              }
                  : null,
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }


  void _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      final movedItem = lists[oldListIndex].items.removeAt(oldItemIndex);
      lists[newListIndex].items.insert(newItemIndex, movedItem);
    });
  }

  void _addList() {
    setState(() {
      lists.add(TaskList(title: "List ${lists.length + 1}"));
    });
  }

  void _addItemToFirstList() {
    if (lists.isNotEmpty) {
      setState(() {
        lists[0].items.add(TaskItem('Item ${lists[0].items.length + 1}', null));
      });
    }
  }

  void _removeItem(int listIndex, int itemIndex) {
    lists[listIndex].items.removeAt(itemIndex);
    setState(() {});
  }
}

class _AnimatedListItem extends StatefulWidget {
  final Widget child;

  const _AnimatedListItem({super.key, required this.child});

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _controller.forward();
  }

  void remove() {
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
      child: FadeTransition(
        opacity: _controller,
        child: widget.child,
      ),
    );
  }
}
