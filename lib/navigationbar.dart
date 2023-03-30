import 'package:chores/home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'current_chores.dart';
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
      switch (value) {
        case 'Settings':
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SettingsPage(),
            ),
          );
          break;
        case 'About':
          break;
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Chores'),
          actions: <Widget>[
            TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    ),
                icon: const Icon(Icons.settings),
                label: const Text('')),
            /*PopupMenuButton<String>(
              onSelected: openSettings,
              itemBuilder: (BuildContext context) {
                return {'Settings', 'About'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),*/
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
            destinations: const [
              NavigationDestination(
                  selectedIcon: Icon(Icons.dashboard),
                  icon: Icon(Icons.dashboard_outlined),
                  label: 'Dashboard'),
              NavigationDestination(
                  selectedIcon: Icon(Icons.calendar_month),
                  icon: Icon(Icons.calendar_month_outlined),
                  label: 'Overview'),
            ],
          ),
        ));
  }
}
