import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TaskItem {
  final String id;
  final String label;

  TaskItem(this.label) : id = const Uuid().v4();
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

class _RoleTaskSettingsState extends State<RoleTaskSettings> {
  final List<TaskList> lists = [];

  @override
  void initState() {
    super.initState();
    lists.addAll([
      TaskList(title: "List A", items: [
        TaskItem('Item A1'),
        TaskItem('Item A2'),
        TaskItem('Item A3'),
      ]),
      TaskList(title: "List B", items: [
        TaskItem('Item B1'),
        TaskItem('Item B2'),
      ]),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nested Drag-and-Drop Lists')),
      body:  DragAndDropLists(
              lastItemTargetHeight: 3,
              listSizeAnimationDurationMilliseconds: 0,
              children: List.generate(
                lists.length,
                    (listIndex) => DragAndDropList(
                  key: ValueKey(lists[listIndex].id),
                  header: _buildCollapsibleHeader(listIndex),
                  canDrag: false,
                  contentsWhenEmpty: lists[listIndex].isExpanded ? Container(
                    padding: const EdgeInsets.all(16),
                    child: Text('Add a chore to get started', style: TextStyle(color: Theme.of(context).disabledColor),),
                  ) : SizedBox.shrink(),
                  decoration: BoxDecoration(
                    color: Theme
                        .of(context)
                        .colorScheme
                        .surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                      children: lists[listIndex].isExpanded
                          ? List.generate(
                        lists[listIndex].items.length,
                            (itemIndex) {
                          final item = lists[listIndex].items[itemIndex];
                          return DragAndDropItem(
                            key: ValueKey(item.id),
                            child: Dismissible(
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
                                  title: Text(item.label),
                                  trailing: const Icon(Icons.drag_handle),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                          : [],
                    ),
              ),
              onItemReorder: _onItemReorder,
              itemDragOnLongPress: false,
              listDragOnLongPress: false,
              listPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              contentsWhenEmpty: const Center(
                child: Text('No lists available. Add a new list!'),
              ),
              itemDragHandle: DragHandle(
                verticalAlignment: DragHandleVerticalAlignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(right: 25),
                  child: Icon(Icons.drag_handle, color: Colors.white.withValues(alpha: 0.0)),
                ),
              ),
              itemDecorationWhileDragging: BoxDecoration(
                color: Theme
                    .of(context)
                    .colorScheme
                    .primaryContainer,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              onListReorder: (int oldListIndex, int newListIndex) {  },
            ),

      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        distance: 70,
        type: ExpandableFabType.up,
        childrenAnimation: ExpandableFabAnimation.none,
        overlayStyle: ExpandableFabOverlayStyle(
          color: Theme.of(context).colorScheme.onInverseSurface.withOpacity(0.5),
        ),
        children: [
          Row(
            children: [
              Text('Add Role'),
              SizedBox(width: 20),
              FloatingActionButton.small(
                onPressed: _addList,
                child: Icon(Icons.person_add_alt_1),
              ),
            ],
          ),
          Row(
            children: [
              Text('Add Chore'),
              SizedBox(width: 20),
              FloatingActionButton.small(
                onPressed: _addItemToFirstList,
                child: Icon(Icons.add_task),
              ),
            ],
          ),
        ],
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
      trailing: IconButton(
        icon: const Icon(Icons.delete_forever),
        onPressed: () {
          setState(() {
            lists.removeAt(index);
          });
        },
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
        lists[0].items.add(TaskItem('Item ${lists[0].items.length + 1}'));
      });
    }
  }

  void _removeItem(int listIndex, int itemIndex) {
    final removedItem = lists[listIndex].items.removeAt(itemIndex);
    final controller = GlobalKey<_AnimatedListItemState>();
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
