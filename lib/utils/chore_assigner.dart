class ChoreAssigner {
  final List<String> members;
  final List<String> roles;
  final int noRepeatWindow;

  final Map<String, int> totalChores = {};
  final List<Map<String, String>> history = [];

  ChoreAssigner(this.members, this.roles, this.noRepeatWindow) {
    for (var m in members) {
      totalChores[m] = 0;
    }
  }

  /// Assigns chores for [cw] (ISO week number).
  /// Returns Map<Member, List<Roles>>.
  Map<String, List<String>> assignRoles(int cw) {
    if (members.isEmpty || roles.isEmpty) {
      return {for (var m in members) m: []};
    }

    final Map<String, String> roleAssignments = {};
    final int m = members.length;
    final int offset = cw % m;

    for (int i = 0; i < roles.length; i++) {
      final role = roles[i];
      final startIndex = (i + offset) % m;
      String best = members[startIndex];

      for (var member in members) {
        if (_hadRoleRecently(member, role)) continue;
        if (totalChores[member]! < totalChores[best]!) {
          best = member;
        }
      }

      roleAssignments[role] = best;
      totalChores[best] = totalChores[best]! + 1;
    }

    history.add(Map.from(roleAssignments));
    if (history.length > noRepeatWindow) {
      history.removeAt(0);
    }

    return {
      for (var member in members)
        member: roleAssignments.entries
            .where((e) => e.value == member)
            .map((e) => e.key)
            .toList(),
    };
  }

  bool _hadRoleRecently(String member, String role) {
    return history.any((past) => past[role] == member);
  }
}
