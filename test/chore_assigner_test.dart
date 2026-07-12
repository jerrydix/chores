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
