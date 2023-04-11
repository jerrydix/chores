import 'package:chores/overview.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dashboard.dart';
import 'settings.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _currentIndex = 0;
  List<Widget> pages = [
    const CurrentPage(title: 'Current Chores'),
    const HomePage(title: 'All Chores'),
  ];

  @override
  Widget build(BuildContext context) {
    void openSettings(String value) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const SettingsPage(),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Chores'),
          actions: <Widget>[
              PopupMenuButton<String>(
                onSelected: openSettings,
                itemBuilder: (BuildContext context) {
                  return {AppLocalizations.of(context)!.settings}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: MaterialStateTextStyle.resolveWith((states) =>
                GoogleFonts.openSans(
                    fontStyle: FontStyle.normal, fontSize: 13)),
          ),
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
        ));
  }
}
