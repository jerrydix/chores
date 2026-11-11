import 'package:flutter_test/flutter_test.dart';

import 'package:chores/views/overview.dart';

void main() {
  group('weeksInYear', () {
    test('years starting on a Thursday have 53 weeks', () {
      expect(DateTime(2015, 1, 1).weekday, DateTime.thursday);
      expect(weeksInYear(2015), 53);
      expect(DateTime(2026, 1, 1).weekday, DateTime.thursday);
      expect(weeksInYear(2026), 53);
    });

    test('leap years starting on a Wednesday have 53 weeks', () {
      expect(DateTime(2020, 1, 1).weekday, DateTime.wednesday);
      expect(weeksInYear(2020), 53);
    });

    test('other years have 52', () {
      expect(weeksInYear(2021), 52); // Friday
      expect(weeksInYear(2024), 52); // Monday, leap
      expect(weeksInYear(2025), 52); // Wednesday, not leap
    });
  });

  group('currentWeekRow', () {
    test('normally highlights the ISO week number', () {
      expect(currentWeekRow(DateTime(2026, 6, 15), 53), 25);
    });

    test('late December wrapping to week 1 highlights the last row', () {
      // 29 Dec 2025 already belongs to ISO week 1 of 2026, so the row to
      // highlight is the last one of the 2025 table rather than row 1.
      final lateDecember = DateTime(2025, 12, 29);
      expect(currentWeekRow(lateDecember, 52), 52);
    });

    test('early January week 1 highlights row 1', () {
      expect(currentWeekRow(DateTime(2026, 1, 2), 53), 1);
    });
  });
}
