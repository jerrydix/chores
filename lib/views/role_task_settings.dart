import 'package:chores/utils/icon_picker.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chores/member_manager.dart';

class TaskItem {
  final String id;
  final IconData? iconData;
  final String label;

  TaskItem(this.label, this.iconData) : id = const Uuid().v4();
}

class TaskList {
  final String id;
  String title;
  IconData? iconData;
  final List<TaskItem> items;
  bool isExpanded;

  TaskList({
    required this.title,
    this.iconData,
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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFromFirestore();
  }

  Future<void> _loadFromFirestore() async {
    final manager = MemberManager.instance;
    final wgID = manager.currentWgID;
    if (wgID == "-1") {
      setState(() => _loading = false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection("wgs")
        .doc(wgID)
        .get();
    final data = doc.data();
    final rawConfig = data?["rolesConfig"];

    final loaded = <TaskList>[];
    if (rawConfig is List) {
      for (final roleEntry in rawConfig) {
        final roleName = roleEntry["name"] as String;
        final rawTasks = roleEntry["tasks"] as List? ?? [];
        final items = rawTasks.map<TaskItem>((t) {
          final codePoint = t["codePoint"] as int?;
          final fontFamily = t["fontFamily"] as String?;
          final icon = codePoint != null
              ? IconData(codePoint, fontFamily: fontFamily ?? 'MaterialIcons')
              : null;
          return TaskItem(t["name"] as String, icon);
        }).toList();
        final roleIconCodePoint = roleEntry["iconCodePoint"] as int?;
        final roleIconFontFamily = roleEntry["iconFontFamily"] as String?;
        final roleIcon = roleIconCodePoint != null
            ? IconData(roleIconCodePoint,
                fontFamily: roleIconFontFamily ?? 'MaterialIcons')
            : null;
        loaded.add(TaskList(title: roleName, iconData: roleIcon, items: items));
      }
    }

    setState(() {
      lists
        ..clear()
        ..addAll(loaded);
      _loading = false;
    });
  }

  Future<void> _saveToFirestore() async {
    final manager = MemberManager.instance;
    final wgID = manager.currentWgID;
    if (wgID == "-1") return;

    final rolesConfig = lists.map((role) => {
          "name": role.title,
          "iconCodePoint": role.iconData?.codePoint,
          "iconFontFamily": role.iconData?.fontFamily,
          "tasks": role.items.map((task) => {
                "name": task.label,
                "codePoint": task.iconData?.codePoint,
                "fontFamily": task.iconData?.fontFamily,
              }).toList(),
        }).toList();

    // Rebuild tasks completion map: keep existing values, add new entries as false
    final existingTasks = Map<String, Map<String, bool>>.from(
      manager.tasks.map((k, v) => MapEntry(k, Map<String, bool>.from(v))),
    );
    final updatedTasks = <String, Map<String, bool>>{};
    for (final role in lists) {
      final existing = existingTasks[role.title] ?? {};
      updatedTasks[role.title] = {
        for (final task in role.items)
          task.label: existing[task.label] ?? false,
      };
    }

    await FirebaseFirestore.instance.collection("wgs").doc(wgID).update({
      "rolesConfig": rolesConfig,
      "tasks": updatedTasks,
    });

    // Re-fetch so all manager fields (taskIcons, roleIcons, primaryRoles, etc.)
    // are consistent before listeners rebuild their UI.
    final fut = manager.fetchWGData();
    manager.dataFuture = fut;
    await fut;
    manager.refresh();
  }

  void _onRoleReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      lists.insert(newIndex, lists.removeAt(oldIndex));
    });
    _saveToFirestore();
  }

  void _onTaskReorder(int listIndex, int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      lists[listIndex].items.insert(
            newIndex,
            lists[listIndex].items.removeAt(oldIndex),
          );
    });
    _saveToFirestore();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Role & Task Settings')),
      body: lists.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  Text('No roles yet',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Tap + to add a role or chore',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.outline)),
                ],
              ),
            )
          : ReorderableListView.builder(
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
            onTaskDelete: (i) {
              setState(() => list.items.removeAt(i));
              _saveToFirestore();
            },
            onRoleDelete: () {
              setState(() => lists.removeAt(roleIndex));
              _saveToFirestore();
            },
            onAddChore: () => _openChoreDialogForList(roleIndex),
            onToggleExpand: () =>
                setState(() => list.isExpanded = !list.isExpanded),
            onIconTap: () => _pickRoleIcon(roleIndex),
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
    IconData? pickedIcon;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Text('Add Role'),
          content: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'Role Name'),
                  onChanged: (_) => setDialog(() {}),
                  onSubmitted: (v) {
                    if (v.trim().isNotEmpty) {
                      setState(() => lists.add(
                          TaskList(title: v.trim(), iconData: pickedIcon)));
                      _saveToFirestore();
                      Navigator.of(ctx).pop();
                    }
                  },
                ),
              ),
              IconButton(
                icon: Icon(pickedIcon ?? Icons.image_outlined),
                onPressed: () async {
                  final picked = await showMaterialIconPicker(
                    ctx,
                    title: 'Pick Role Icon',
                  );
                  setDialog(() => pickedIcon = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: controller.text.trim().isNotEmpty
                  ? () {
                      setState(() => lists.add(TaskList(
                          title: controller.text.trim(),
                          iconData: pickedIcon)));
                      _saveToFirestore();
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

  Future<void> _pickRoleIcon(int listIndex) async {
    final picked = await showMaterialIconPicker(
      context,
      title: 'Pick Role Icon',
    );
    if (picked != null) {
      setState(() => lists[listIndex].iconData = picked);
      _saveToFirestore();
    }
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
                          _saveToFirestore();
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
                      _saveToFirestore();
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
  final VoidCallback onIconTap;

  const _RoleCard({
    super.key,
    required this.list,
    required this.roleIndex,
    required this.onTaskReorder,
    required this.onTaskDelete,
    required this.onRoleDelete,
    required this.onAddChore,
    required this.onToggleExpand,
    required this.onIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: IconButton(
              constraints: const BoxConstraints(),
              //padding: const EdgeInsets.all(8),
              icon: AnimatedRotation(
                turns: list.isExpanded ? 0.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.expand_less),
              ),
              onPressed: onToggleExpand,
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onIconTap,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      list.iconData ?? Icons.add_reaction_outlined,
                      size: 22,
                      color: list.iconData != null
                          ? null
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    list.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
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
            leading: item.iconData != null
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(item.iconData),
                  )
                : null,
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
            final picked = await showMaterialIconPicker(
              context,
              title: 'Pick an icon',
            );
            onIconPicked(picked);
          },
        ),
      ],
    );
  }
}
