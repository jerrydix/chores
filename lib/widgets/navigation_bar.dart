import 'package:chores/views/overview.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/breakpoints.dart';
import '../views/dashboard.dart';
import '../views/settings.dart';

/// Height of the bottom navigation bar.
const double kNavBarHeight = 80;

/// Vertical space the app bar and bottom navigation bar take off the viewport.
double navBarChromeHeight() => kToolbarHeight + kNavBarHeight;

/// Exposes the measured height of [NavBar]'s body, and the window size class,
/// to its descendants.
///
/// This used to be a top-level mutable `bodyHeight` assigned during build,
/// which meant any widget reading it got whatever the last build happened to
/// write - and nothing at all before the first build.
class NavBarMetrics extends InheritedWidget {
  final double bodyHeight;
  final WindowSize windowSize;

  const NavBarMetrics({
    super.key,
    required this.bodyHeight,
    required this.windowSize,
    required super.child,
  });

  static NavBarMetrics? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NavBarMetrics>();

  /// The measured body height, falling back to the viewport minus the app
  /// chrome when used outside a [NavBar].
  static double heightOf(BuildContext context) {
    final metrics = maybeOf(context);
    if (metrics != null) return metrics.bodyHeight;
    final media = MediaQuery.of(context);
    return media.size.height -
        media.padding.top -
        media.padding.bottom -
        navBarChromeHeight();
  }

  /// The window size class of the surrounding [NavBar], or of the window.
  static WindowSize sizeOf(BuildContext context) =>
      maybeOf(context)?.windowSize ?? windowSizeOf(context);

  @override
  bool updateShouldNotify(NavBarMetrics oldWidget) =>
      oldWidget.bodyHeight != bodyHeight || oldWidget.windowSize != windowSize;
}

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<StatefulWidget> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _currentIndex = 0;
  final List<Widget> pages = const [Dashboard(), HomePage()];

  Future<void> openSettings() async {
    Route route = MaterialPageRoute(builder: (context) => const Settings());
    await Navigator.push(context, route);
    if (!mounted) return;
    setState(() {});
  }

  void _onDestinationSelected(int newIndex) =>
      setState(() => _currentIndex = newIndex);

  NavigationBarThemeData get _navBarTheme => NavigationBarThemeData(
    // Use the bundled default font instead of GoogleFonts.openSans, which
    // fetched the font from fonts.gstatic.com on every fresh session and
    // delayed first paint on both web and mobile.
    labelTextStyle: WidgetStateTextStyle.resolveWith(
      (states) => const TextStyle(fontStyle: FontStyle.normal, fontSize: 13),
    ),
    height: kNavBarHeight,
  );

  List<({IconData icon, IconData selectedIcon, String label})> _destinations(
    BuildContext context,
  ) {
    final loc = AppLocalizations.of(context)!;
    return [
      (
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        label: loc.dashboard,
      ),
      (
        icon: Icons.calendar_month_outlined,
        selectedIcon: Icons.calendar_month,
        label: loc.overview,
      ),
    ];
  }

  /// The page stack, wrapped so descendants can read the real body size.
  Widget _body(WindowSize windowSize) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      return NavBarMetrics(
        bodyHeight: constraints.maxHeight,
        windowSize: windowSize,
        child: IndexedStack(index: _currentIndex, children: pages),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final destinations = _destinations(context);
    // Measure the window rather than the body: the rail changes the body's
    // width, so deciding from the body would feed back on itself.
    final windowSize = windowSizeOf(context);

    final appBar = AppBar(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
      ),
      title: const Text("Chores"),
      actions: <Widget>[
        IconButton(onPressed: openSettings, icon: const Icon(Icons.settings)),
      ],
    );

    // Material puts navigation at the side from the medium width class up.
    // Android 17 ignores this app's portrait request on large screens, so this
    // is the layout a tablet or unfolded foldable actually gets.
    if (windowSize.usesNavigationRail) {
      return Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onDestinationSelected,
              extended: windowSize.usesExtendedRail,
              labelType: windowSize.usesExtendedRail
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: _body(windowSize)),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: _body(windowSize),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
        child: NavigationBarTheme(
          data: _navBarTheme,
          child: NavigationBar(
            selectedIndex: _currentIndex,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: _onDestinationSelected,
            destinations: [
              for (final d in destinations)
                NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: d.label,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
