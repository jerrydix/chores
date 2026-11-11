import 'package:flutter_test/flutter_test.dart';

import 'package:chores/utils/chore_assigner.dart';

void main() {
  const members = ["Anna", "Ben", "Chris"];
  const roles = ["Kitchen", "Bathroom"];

  group('RotatingAssigner', () {
    test('single call matches sequential calls for the same week', () {
      // Dashboard-style: one call for the current week.
      final direct = RotatingAssigner(List.of(members), List.of(roles), 1)
          .assignRoles(30);

      // Overview-style: sequential calls for weeks 1..30.
      final sequential = RotatingAssigner(List.of(members), List.of(roles), 1);
      Map<String, List<String>> last = {};
      for (int week = 1; week <= 30; week++) {
        last = sequential.assignRoles(week);
      }

      expect(direct, equals(last));
    });

    test('re-requesting an earlier week gives the same result', () {
      final assigner = RotatingAssigner(List.of(members), List.of(roles), 1);
      final first = assigner.assignRoles(10);
      assigner.assignRoles(40);
      final again = assigner.assignRoles(10);
      expect(again, equals(first));
    });

    test('nobody keeps the same role two weeks in a row', () {
      final assigner = RotatingAssigner(List.of(members), List.of(roles), 1);
      Map<String, List<String>> previous = {};
      for (int week = 1; week <= 52; week++) {
        final current = assigner.assignRoles(week);
        for (final member in members) {
          final repeated = current[member]!
              .where((role) => (previous[member] ?? []).contains(role));
          if (week > 1) {
            expect(repeated, isEmpty,
                reason: "$member kept ${repeated.join(", ")} in week $week");
          }
        }
        previous = current;
      }
    });

    test('every role is assigned exactly once per week', () {
      final assigner = RotatingAssigner(List.of(members), List.of(roles), 1);
      for (int week = 1; week <= 52; week++) {
        final assignments = assigner.assignRoles(week);
        final assigned = assignments.values.expand((r) => r).toList();
        expect(assigned..sort(), equals(List.of(roles)..sort()));
      }
    });

    test('chores are distributed fairly over a year', () {
      final assigner = RotatingAssigner(List.of(members), List.of(roles), 1);
      final counts = {for (final m in members) m: 0};
      for (int week = 1; week <= 52; week++) {
        final assignments = assigner.assignRoles(week);
        for (final m in members) {
          counts[m] = counts[m]! + assignments[m]!.length;
        }
      }
      final min = counts.values.reduce((a, b) => a < b ? a : b);
      final max = counts.values.reduce((a, b) => a > b ? a : b);
      expect(max - min, lessThanOrEqualTo(2),
          reason: "unfair distribution: $counts");
    });

    test('handles empty members or roles', () {
      expect(RotatingAssigner([], List.of(roles), 1).assignRoles(5), isEmpty);
      expect(RotatingAssigner(List.of(members), [], 1).assignRoles(5),
          equals({for (final m in members) m: <String>[]}));
    });

    test('more roles than members still assigns everything', () {
      final manyRoles = ["A", "B", "C", "D", "E"];
      final assigner = RotatingAssigner(["X", "Y"], manyRoles, 1);
      final assignments = assigner.assignRoles(7);
      final assigned = assignments.values.expand((r) => r).toList();
      expect(assigned..sort(), equals(List.of(manyRoles)..sort()));
    });
  });

  group('member keys', () {
    // MemberManager feeds the assigner uids, not display names. Two
    // housemates can share a display name; keying by name collapsed them
    // into one map entry, so both were shown the same roles and the
    // fairness counter treated them as a single person.
    test('housemates with the same display name stay independent', () {
      final uids = ["uid-a", "uid-b", "uid-c"];
      final roles = ["Kitchen", "Bathroom", "Trash"];
      final assignments =
          RotatingAssigner(uids, roles, 1).assignRoles(5);

      expect(assignments.keys, hasLength(3));
      final everyRole = assignments.values.expand((r) => r).toList();
      expect(everyRole..sort(), equals(List.of(roles)..sort()));
      // Nobody covers for somebody else: three roles across three people.
      expect(assignments.values.where((r) => r.isEmpty), isEmpty);
    });

    test('duplicate keys would collapse - why uids are used', () {
      // Guards the reason for the uid switch: identical keys cannot be told
      // apart, whatever the algorithm.
      final collapsed =
          RotatingAssigner(["Alex", "Alex", "Ben"], ["A", "B", "C"], 1)
              .assignRoles(5);
      expect(collapsed.keys, hasLength(2));
    });
  });

  group('FixedAssigner', () {
    test('same assignment every week', () {
      final assigner = FixedAssigner(List.of(members), List.of(roles));
      final week1 = assigner.assignRoles(1);
      final week30 = assigner.assignRoles(30);
      expect(week1, equals(week30));
    });
  });

  group('RandomAssigner', () {
    test('deterministic for the same week', () {
      final a = RandomAssigner(List.of(members), List.of(roles));
      final b = RandomAssigner(List.of(members), List.of(roles));
      expect(a.assignRoles(12), equals(b.assignRoles(12)));
    });

    test('every role assigned exactly once per week', () {
      final assigner = RandomAssigner(List.of(members), List.of(roles));
      for (int week = 1; week <= 52; week++) {
        final assigned =
            assigner.assignRoles(week).values.expand((r) => r).toList();
        expect(assigned..sort(), equals(List.of(roles)..sort()));
      }
    });
  });
}
