import 'package:chores/views/overview.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../views/dashboard.dart';
import '../views/settings.dart';

/// Height of the bottom navigation bar.
const double kNavBarHeight = 80;

/// Vertical space the app bar and navigation bar take off the viewport.
double navBarChromeHeight() => kToolbarHeight + kNavBarHeight;

/// Exposes the measured height of [NavBar]'s body to its descendants.
///
/// This used to be a top-level mutable `bodyHeight` assigned during build,
/// which meant any widget reading it got whatever the last build happened to
/// write — and nothing at all before the first build.
class NavBarMetrics extends InheritedWidget {
  final double bodyHeight;

  const NavBarMetrics({
    super.key,
    required this.bodyHeight,
    required super.child,
  });

  /// The body height, falling back to the viewport minus the app chrome when
  /// used outside a [NavBar].
  static double of(BuildContext context) {
    final metrics = context.dependOnInheritedWidgetOfExactType<NavBarMetrics>();
    if (metrics != null) return metrics.bodyHeight;
    final media = MediaQuery.of(context);
    return media.size.height -
        media.padding.top -
        media.padding.bottom -
        navBarChromeHeight();
  }

  @override
  bool updateShouldNotify(NavBarMetrics oldWidget) =>
      oldWidget.bodyHeight != bodyHeight;
}

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<StatefulWidget> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _currentIndex = 0;
  final List<Widget> pages = const [
    Dashboard(),
    HomePage(),
  ];

  Future<void> openSettings() async {
    Route route = MaterialPageRoute(builder: (context) => const Settings());
    await Navigator.push(context, route);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final navBarTheme = NavigationBarThemeData(
      // Use the bundled default font instead of GoogleFonts.openSans, which
      // fetched the font from fonts.gstatic.com on every fresh session and
      // delayed first paint on both web and mobile.
      labelTextStyle: WidgetStateTextStyle.resolveWith((states) =>
          const TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
      height: kNavBarHeight,
    );

    return Scaffold(
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(14),
            ),
          ),
          title: const Text("Chores"),
          actions: <Widget>[
            IconButton(
                onPressed: openSettings, icon: const Icon(Icons.settings))
          ],
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return NavBarMetrics(
              bodyHeight: constraints.maxHeight,
              child: IndexedStack(
                index: _currentIndex,
                children: pages,
              ),
            );
          },
        ),
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
          ),
          child: NavigationBarTheme(
            data: navBarTheme,
            child: NavigationBar(
              selectedIndex: _currentIndex,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (int newIndex) {
                setState(() {
                  _currentIndex = newIndex;
                });
              },
              destinations: [
                NavigationDestination(
                    selectedIcon: const Icon(Icons.dashboard),
                    icon: const Icon(Icons.dashboard_outlined),
                    label: AppLocalizations.of(context)!.dashboard),
                NavigationDestination(
                    selectedIcon: const Icon(Icons.calendar_month),
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: AppLocalizations.of(context)!.overview),
              ],
            ),
          ),
        ));
  }
}
