import 'dart:math';

enum AssignmentAlgorithm {
  rotating,
  fixed,
  random;

  static AssignmentAlgorithm fromString(String? value) {
    switch (value) {
      case 'fixed':
        return fixed;
      case 'random':
        return random;
      default:
        return rotating;
    }
  }

  String toFirestoreString() => name;
}

/// Abstract base for all role-assignment strategies.
abstract class RoleAssigner {
  final List<String> members;
  final List<String> roles;

  RoleAssigner(this.members, this.roles);

  /// Returns a map of member → assigned roles for the given ISO week [cw].
  Map<String, List<String>> assignRoles(int cw);

  static RoleAssigner create(
    AssignmentAlgorithm algorithm,
    List<String> members,
    List<String> roles, {
    int noRepeatWindow = 1,
  }) {
    switch (algorithm) {
      case AssignmentAlgorithm.rotating:
        return RotatingAssigner(members, roles, noRepeatWindow);
      case AssignmentAlgorithm.fixed:
        return FixedAssigner(members, roles);
      case AssignmentAlgorithm.random:
        return RandomAssigner(members, roles);
    }
  }

  /// Shared helper: builds an empty result map for all members.
  Map<String, List<String>> _emptyResult() =>
      {for (var m in members) m: []};
}

/// Rotates assignments each week based on the week number offset.
/// Includes a no-repeat window so the same person doesn't get the same
/// role two weeks in a row (configurable window size).
///
/// The assignment for a given week is deterministic: internally the weeks
/// are always simulated in order starting from week 1, so a single call
/// for week N returns the same result as N sequential calls (this keeps
/// the dashboard and the overview table consistent).
class RotatingAssigner extends RoleAssigner {
  final int noRepeatWindow;
  final Map<String, int> _totalChores = {};
  final List<Map<String, String>> _history = [];
  int _nextWeek = 1;

  RotatingAssigner(super.members, super.roles, this.noRepeatWindow) {
    _reset();
  }

  void _reset() {
    for (var m in members) {
      _totalChores[m] = 0;
    }
    _history.clear();
    _nextWeek = 1;
  }

  @override
  Map<String, List<String>> assignRoles(int cw) {
    if (members.isEmpty || roles.isEmpty) return _emptyResult();
    if (cw < 1) cw = 1;

    // Going backwards (or re-requesting a week) requires replaying from
    // the start so the accumulated history stays deterministic.
    if (cw < _nextWeek) _reset();

    var roleAssignments = <String, String>{};
    while (_nextWeek <= cw) {
      roleAssignments = _assignWeek(_nextWeek);
      _nextWeek++;
    }

    return {
      for (var member in members)
        member: roleAssignments.entries
            .where((e) => e.value == member)
            .map((e) => e.key)
            .toList(),
    };
  }

  Map<String, String> _assignWeek(int week) {
    final Map<String, String> roleAssignments = {};
    final int m = members.length;
    final int offset = week % m;

    for (int i = 0; i < roles.length; i++) {
      final role = roles[i];
      // Only members outside the no-repeat window are eligible; fall back
      // to everyone if the window excludes all of them.
      final eligible =
          members.where((mem) => !_hadRoleRecently(mem, role)).toList();
      final pool = eligible.isEmpty ? members : eligible;

      final rotationCandidate = members[(i + offset) % m];
      String best =
          pool.contains(rotationCandidate) ? rotationCandidate : pool.first;
      for (var member in pool) {
        if (_totalChores[member]! < _totalChores[best]!) {
          best = member;
        }
      }

      roleAssignments[role] = best;
      _totalChores[best] = _totalChores[best]! + 1;
    }

    _history.add(Map.from(roleAssignments));
    if (_history.length > noRepeatWindow) _history.removeAt(0);
    return roleAssignments;
  }

  bool _hadRoleRecently(String member, String role) =>
      _history.any((past) => past[role] == member);
}

/// Always assigns the same roles to the same members every week.
/// Roles are distributed in order: role[i] → member[i % memberCount].
class FixedAssigner extends RoleAssigner {
  FixedAssigner(super.members, super.roles);

  @override
  Map<String, List<String>> assignRoles(int cw) {
    if (members.isEmpty || roles.isEmpty) return _emptyResult();

    final m = members.length;
    final result = _emptyResult();
    for (int i = 0; i < roles.length; i++) {
      result[members[i % m]]!.add(roles[i]);
    }
    return result;
  }
}

/// Reproducibly shuffles members using the week number as RNG seed,
/// then assigns roles in order. Same week always gives the same result,
/// and the distribution is fair over many weeks.
class RandomAssigner extends RoleAssigner {
  RandomAssigner(super.members, super.roles);

  @override
  Map<String, List<String>> assignRoles(int cw) {
    if (members.isEmpty || roles.isEmpty) return _emptyResult();

    final shuffled = List.of(members)..shuffle(Random(cw));
    final m = shuffled.length;
    final result = _emptyResult();
    for (int i = 0; i < roles.length; i++) {
      result[shuffled[i % m]]!.add(roles[i]);
    }
    return result;
  }
}
