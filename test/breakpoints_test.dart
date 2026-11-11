import 'package:flutter_test/flutter_test.dart';

import 'package:chores/utils/breakpoints.dart';

void main() {
  group('windowSizeOfWidth', () {
    test('phones are compact', () {
      expect(windowSizeOfWidth(360), WindowSize.compact);
      expect(windowSizeOfWidth(411), WindowSize.compact);
      expect(windowSizeOfWidth(599.9), WindowSize.compact);
    });

    test('600dp is the boundary Android uses for ignoring orientation', () {
      // At and above this width Android 17 drops the app's portrait request,
      // so this is exactly where the layout has to stop assuming portrait.
      expect(windowSizeOfWidth(600), WindowSize.medium);
      expect(windowSizeOfWidth(839.9), WindowSize.medium);
    });

    test('large tablets and desktop windows are expanded', () {
      expect(windowSizeOfWidth(840), WindowSize.expanded);
      expect(windowSizeOfWidth(1280), WindowSize.expanded);
    });
  });

  group('navigation affordances', () {
    test('compact keeps the bottom bar', () {
      expect(WindowSize.compact.usesNavigationRail, isFalse);
      expect(WindowSize.compact.isCompact, isTrue);
    });

    test('medium and expanded use a rail', () {
      expect(WindowSize.medium.usesNavigationRail, isTrue);
      expect(WindowSize.expanded.usesNavigationRail, isTrue);
    });

    test('only expanded is wide enough for rail labels', () {
      expect(WindowSize.medium.usesExtendedRail, isFalse);
      expect(WindowSize.expanded.usesExtendedRail, isTrue);
    });
  });
}
