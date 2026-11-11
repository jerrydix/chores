import 'package:flutter/widgets.dart';

/// Material 3 window size classes.
///
/// From Android 17 a large-screen device ignores an app's orientation and
/// resizability restrictions, so the layout has to hold up at any width
/// rather than assuming the portrait phone window it asked for.
/// See https://developer.android.com/about/versions/17/changes/ff-restrictions-ignored
enum WindowSize {
  /// Phones in portrait. Below this width Android still honours the
  /// portrait preference, so this stays the layout the app is tuned for.
  compact,

  /// Small tablets, unfolded foldables, phones in landscape.
  medium,

  /// Large tablets, desktop and web windows.
  expanded;

  bool get isCompact => this == WindowSize.compact;

  /// Navigation belongs at the side rather than the bottom from medium up.
  bool get usesNavigationRail => this != WindowSize.compact;

  /// Wide enough for the rail to show its labels.
  bool get usesExtendedRail => this == WindowSize.expanded;
}

/// Width below which a window counts as [WindowSize.compact]. 600dp is also
/// the threshold Android uses for ignoring orientation restrictions.
const double kCompactWidthLimit = 600;

/// Width at or above which a window counts as [WindowSize.expanded].
const double kExpandedWidthLimit = 840;

WindowSize windowSizeOfWidth(double width) {
  if (width < kCompactWidthLimit) return WindowSize.compact;
  if (width < kExpandedWidthLimit) return WindowSize.medium;
  return WindowSize.expanded;
}

WindowSize windowSizeOf(BuildContext context) =>
    windowSizeOfWidth(MediaQuery.sizeOf(context).width);
