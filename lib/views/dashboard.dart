import 'package:chores/widgets/dashboard_view.dart';
import 'package:flutter/material.dart';
import 'package:chores/member_manager.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final MemberManager _manager = MemberManager.instance;

  @override
  void initState() {
    super.initState();
    _manager.dataFuture = _manager.fetchWGData();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _manager,
      builder: (context, child) {
        return FutureBuilder<void>(
          future: _manager.dataFuture,
          builder: (context, snapshot) {
            // Only block on the very first load (memberCount is -1 until the
            // first fetch completes). On later refreshes keep the existing
            // DashboardView mounted instead of flashing a spinner — swapping
            // it out disposes it, and its dispose used to write stale data.
            final firstLoad = _manager.memberCount == -1;
            if (snapshot.connectionState == ConnectionState.waiting &&
                firstLoad) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError && firstLoad) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            return DashboardView(
              tasks: _manager.tasks,
              taskIcons: _manager.taskIcons,
              primaryRoles: _manager.primaryRoles,
              otherRoles: _manager.otherRoles,
              otherNames: _manager.members,
              username: _manager.username,
              active: _manager.active,
            );
          },
        );
      },
    );
  }
}
