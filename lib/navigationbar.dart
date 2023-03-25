import 'package:chores/home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'current_chores.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _currentIndex = 0;
  List<Widget> pages = [
    const HomePage(title: 'All Chores'),
    const CurrentPage(title: 'Current Chores'),
    Text('Settings', style: GoogleFonts.openSans(fontStyle: FontStyle.normal)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      title: const Text('Chores'),
      ),
      body: Center(
        child: pages[_currentIndex],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: MaterialStateTextStyle.resolveWith((states) => GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 13)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 75,
          onDestinationSelected: (int newIndex) {
            setState(() {
              _currentIndex = newIndex;
            });
          },
          destinations: const [
            NavigationDestination(selectedIcon: Icon(Icons.calendar_month),icon: Icon(Icons.calendar_month_outlined), label: 'Overview'),
            NavigationDestination(selectedIcon: Icon(Icons.dashboard),icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
            NavigationDestination(selectedIcon: Icon(Icons.settings),icon: Icon(Icons.settings_outlined), label: 'Settings'),
          ],
        ),
      )
    );
  }

}