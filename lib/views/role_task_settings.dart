import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TaskItem {
  final String id;
  final IconData? iconData;
  final String label;

  TaskItem(this.label, this.iconData) : id = const Uuid().v4();
}

class TaskList {
  final String id;
  String title;
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
  State<RoleTaskSettings> createState() => _RoleTaskSettingsState();
}

class _RoleTaskSettingsState extends State<RoleTaskSettings> {
  final List<TaskList> lists = [];

  @override
  void initState() {
    super.initState();
    // TODO: initialise from MemberManager / Firestore
    lists.addAll([
      TaskList(title: 'List A', items: [
        TaskItem('Item A1', Icons.delete_outlined),
        TaskItem('Item A2', Icons.clean_hands_outlined),
        TaskItem('Item A3', Icons.countertops_outlined),
      ]),
      TaskList(title: 'List B', items: [
        TaskItem('Item B1', Icons.cleaning_services_outlined),
        TaskItem('Item B2', Icons.recycling),
      ]),
    ]);
  }

  void _onRoleReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      lists.insert(newIndex, lists.removeAt(oldIndex));
    });
  }

  void _onTaskReorder(int listIndex, int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      lists[listIndex].items.insert(
            newIndex,
            lists[listIndex].items.removeAt(oldIndex),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Role & Task Settings')),
      body: ReorderableListView.builder(
        onReorder: _onRoleReorder,
        buildDefaultDragHandles: false,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        itemCount: lists.length,
        itemBuilder: (context, roleIndex) {
          final list = lists[roleIndex];
          return _RoleCard(
            key: ValueKey(list.id),
            list: list,
            roleIndex: roleIndex,
            onTaskReorder: (o, n) => _onTaskReorder(roleIndex, o, n),
            onTaskDelete: (i) => setState(() => list.items.removeAt(i)),
            onRoleDelete: () => setState(() => lists.removeAt(roleIndex)),
            onAddChore: () => _openChoreDialogForList(roleIndex),
            onToggleExpand: () =>
                setState(() => list.isExpanded = !list.isExpanded),
          );
        },
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        distance: 70,
        type: ExpandableFabType.up,
        childrenAnimation: ExpandableFabAnimation.none,
        overlayStyle: ExpandableFabOverlayStyle(
          color: Theme.of(context)
              .colorScheme
              .onInverseSurface
              .withValues(alpha: 0.4),
        ),
        children: [
          Row(children: [
            const Text('Add Role'),
            const SizedBox(width: 20),
            FloatingActionButton.small(
              heroTag: 'fab_add_role',
              onPressed: _openRoleDialog,
              child: const Icon(Icons.person_add_alt_1),
            ),
          ]),
          Row(children: [
            const Text('Add Chore'),
            const SizedBox(width: 20),
            FloatingActionButton.small(
              heroTag: 'fab_add_chore',
              onPressed: _openChoreDialog,
              child: const Icon(Icons.add_task),
            ),
          ]),
        ],
      ),
    );
  }

  Future<void> _openRoleDialog() async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Text('Add Role'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Role Name'),
            onChanged: (_) => setDialog(() {}),
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) {
                setState(() => lists.add(TaskList(title: v.trim())));
                Navigator.of(ctx).pop();
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: controller.text.trim().isNotEmpty
                  ? () {
                      setState(() =>
                          lists.add(TaskList(title: controller.text.trim())));
                      Navigator.of(ctx).pop();
                    }
                  : null,
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openChoreDialog() async {
    final controller = TextEditingController();
    int? selectedRoleIndex;
    IconData? pickedIcon;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Text('Add Chore'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Select Role'),
                initialValue: selectedRoleIndex,
                items: [
                  for (int i = 0; i < lists.length; i++)
                    DropdownMenuItem(value: i, child: Text(lists[i].title)),
                ],
                onChanged: (v) => setDialog(() => selectedRoleIndex = v),
              ),
              const SizedBox(height: 20),
              _ChoreInputRow(
                controller: controller,
                iconData: pickedIcon,
                onChanged: (_) => setDialog(() {}),
                onIconPicked: (d) => setDialog(() => pickedIcon = d),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed:
                  controller.text.trim().isNotEmpty && selectedRoleIndex != null
                      ? () {
                          setState(() {
                            lists[selectedRoleIndex!].items.add(
                                  TaskItem(controller.text.trim(),
                                      pickedIcon ?? Icons.task),
                                );
                            lists[selectedRoleIndex!].isExpanded = true;
                          });
                          Navigator.of(ctx).pop();
                        }
                      : null,
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openChoreDialogForList(int listIndex) async {
    final controller = TextEditingController();
    IconData? pickedIcon;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text('Add Chore to ${lists[listIndex].title}'),
          content: _ChoreInputRow(
            controller: controller,
            iconData: pickedIcon,
            onChanged: (_) => setDialog(() {}),
            onIconPicked: (d) => setDialog(() => pickedIcon = d),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: controller.text.trim().isNotEmpty
                  ? () {
                      setState(() {
                        lists[listIndex].items.add(
                              TaskItem(controller.text.trim(),
                                  pickedIcon ?? Icons.task),
                            );
                        lists[listIndex].isExpanded = true;
                      });
                      Navigator.of(ctx).pop();
                    }
                  : null,
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Role card ────────────────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  final TaskList list;
  final int roleIndex;
  final void Function(int oldIdx, int newIdx) onTaskReorder;
  final void Function(int taskIdx) onTaskDelete;
  final VoidCallback onRoleDelete;
  final VoidCallback onAddChore;
  final VoidCallback onToggleExpand;

  const _RoleCard({
    super.key,
    required this.list,
    required this.roleIndex,
    required this.onTaskReorder,
    required this.onTaskDelete,
    required this.onRoleDelete,
    required this.onAddChore,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          ListTile(
            leading: IconButton(
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
              icon: AnimatedRotation(
                turns: list.isExpanded ? 0.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.expand_less),
              ),
              onPressed: onToggleExpand,
            ),
            title: Text(
              list.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                  icon: const Icon(Icons.add),
                  tooltip: 'Add Chore',
                  onPressed: onAddChore,
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete Role',
                  onPressed: onRoleDelete,
                ),
                // 40×40 matches icon(24) + padding(8) on each side — aligns
                // horizontally with the inner task drag handles.
                ReorderableDragStartListener(
                  index: roleIndex,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.drag_indicator),
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: list.isExpanded
                ? _TaskList(
                    key: ValueKey('tasks_${list.id}'),
                    items: list.items,
                    onReorder: onTaskReorder,
                    onDelete: onTaskDelete,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─── Task list ────────────────────────────────────────────────────────────────

class _TaskList extends StatelessWidget {
  final List<TaskItem> items;
  final void Function(int oldIdx, int newIdx) onReorder;
  final void Function(int idx) onDelete;

  const _TaskList({
    super.key,
    required this.items,
    required this.onReorder,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No chores for this role',
          style: TextStyle(color: Theme.of(context).disabledColor),
        ),
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      // Outer Scaffold handles scrolling.
      physics: const NeverScrollableScrollPhysics(),
      // Suppress the default handle — our explicit ReorderableDragStartListener
      // is the only drag zone, avoiding the double-burger.
      buildDefaultDragHandles: false,
      onReorder: onReorder,
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return Dismissible(
          // Key doubles as the ReorderableListView item key.
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => onDelete(i),
          child: ListTile(
            leading: item.iconData != null ? Icon(item.iconData) : null,
            title: Text(item.label),
            trailing: ReorderableDragStartListener(
              index: i,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.drag_handle),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Shared chore-input row ───────────────────────────────────────────────────

class _ChoreInputRow extends StatelessWidget {
  final TextEditingController controller;
  final IconData? iconData;
  final ValueChanged<String> onChanged;
  final ValueChanged<IconData?> onIconPicked;

  const _ChoreInputRow({
    required this.controller,
    required this.iconData,
    required this.onChanged,
    required this.onIconPicked,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Chore Name'),
            onChanged: onChanged,
          ),
        ),
        IconButton(
          icon: Icon(iconData ?? Icons.image),
          onPressed: () async {
            final picked = await showIconPicker(
              context,
              configuration: SinglePickerConfiguration(
                iconPackModes: [
                  IconPack.material,
                  IconPack.cupertino,
                  IconPack.fontAwesomeIcons,
                ],
                title: const Text('Pick an icon'),
                closeChild: const Text('Close'),
                searchHintText: 'Search icon...',
                noResultsText: 'No results found',
                iconSize: 50,
                adaptiveDialog: true,
                iconPickerShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            onIconPicked(picked?.data);
          },
        ),
      ],
    );
  }
}
