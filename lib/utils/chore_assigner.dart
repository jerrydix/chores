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

  /// Returns Map<member, List<assigned roles>> for the given ISO week [cw].
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
class RotatingAssigner extends RoleAssigner {
  final int noRepeatWindow;
  final Map<String, int> _totalChores = {};
  final List<Map<String, String>> _history = [];

  RotatingAssigner(super.members, super.roles, this.noRepeatWindow) {
    for (var m in members) {
      _totalChores[m] = 0;
    }
  }

  @override
  Map<String, List<String>> assignRoles(int cw) {
    if (members.isEmpty || roles.isEmpty) return _emptyResult();

    final Map<String, String> roleAssignments = {};
    final int m = members.length;
    final int offset = cw % m;

    for (int i = 0; i < roles.length; i++) {
      final role = roles[i];
      final startIndex = (i + offset) % m;
      String best = members[startIndex];

      for (var member in members) {
        if (_hadRoleRecently(member, role)) continue;
        if (_totalChores[member]! < _totalChores[best]!) {
          best = member;
        }
      }

      roleAssignments[role] = best;
      _totalChores[best] = _totalChores[best]! + 1;
    }

    _history.add(Map.from(roleAssignments));
    if (_history.length > noRepeatWindow) _history.removeAt(0);

    return {
      for (var member in members)
        member: roleAssignments.entries
            .where((e) => e.value == member)
            .map((e) => e.key)
            .toList(),
    };
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
