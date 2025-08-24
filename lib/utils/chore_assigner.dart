class ChoreAssigner {
  final List<String> members;
  final List<String> roles;
  final int noRepeatWindow; // configurable window (weeks)
  int currentWeek = 0;

  // Track total chores per member
  final Map<String, int> totalChores = {};

  // History of last assignments (week -> role -> member)
  final List<Map<String, String>> history = [];

  ChoreAssigner(this.members, this.roles, this.noRepeatWindow) {
    for (var m in members) {
      totalChores[m] = 0;
    }
  }

  /// Assigns chores for the current week
  /// Returns: Map<Member, List<Roles>>
  Map<String, List<String>> assignRoles(int cw, {bool overwrite = false}) {
    Map<String, String> roleAssignments = {};
    int m = members.length;
    int offset = cw % m;

    for (int i = 0; i < roles.length; i++) {
      String role = roles[i];
      int startIndex = (i + offset) % m;

      // Start with round-robin candidate
      String best = members[startIndex];

      for (var member in members) {
        if (_hadRoleRecently(member, role)) continue;

        // Prefer member with fewer total chores
        if (totalChores[member]! < totalChores[best]!) {
          best = member;
        }
      }

      roleAssignments[role] = best;
      totalChores[best] = totalChores[best]! + 1;
    }

    // Save to history
    history.add(Map.from(roleAssignments));
    if (history.length > noRepeatWindow) {
      history.removeAt(0);
    }

    // Convert role → member into member → [roles]
    Map<String, List<String>> memberAssignments = {
      for (var m in members) m: []
    };
    roleAssignments.forEach((role, member) {
      memberAssignments[member]!.add(role);
    });

    return memberAssignments;
  }

  bool _hadRoleRecently(String member, String role) {
    for (var past in history) {
      if (past[role] == member) return true;
    }
    return false;
  }

  void printTotals() {
    print("Total chores so far: $totalChores");
  }
}

void main() {
  var members = ["Alice", "Bob", "Charlie"];
  var roles = ["Dishes", "Cooking", "Vacuuming", "Laundry", "Trash"];

  var assigner = ChoreAssigner(members, roles, 2);

  for (int week = 1; week <= 3; week++) {
    var assignment = assigner.assignRoles(week);
    print("Week $week:");
    assignment.forEach((member, roleList) {
      print("  $member → $roleList");
    });
    assigner.printTotals();
    print("");
    week++;
  }
}