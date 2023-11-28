import 'package:chores/member_manager.dart';
import 'package:chores/overview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../dashboard.dart';
import '../settings.dart';

late Scaffold scaffold;
late NavigationBarThemeData navBarTheme;
late double bodyHeight;

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<StatefulWidget> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _currentIndex = 0;
  List<Widget> pages = [
    const Dashboard(),
    const HomePage(),
  ];

  Future<void> openSettings() async {
    Route route = MaterialPageRoute(builder: (context) => const SettingsPage());
    await Navigator.push(context, route);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    navBarTheme = NavigationBarThemeData(
      labelTextStyle: MaterialStateTextStyle.resolveWith((states) =>
          GoogleFonts.openSans(
              fontStyle: FontStyle.normal, fontSize: 13)),
      height: 80,
    );

    scaffold = Scaffold(
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(8),
            ),
          ),
          title: createPrimaryRolesText(),
          actions: <Widget>[
            IconButton(onPressed: () {openSettings();}, icon: const Icon(Icons.settings))
            /*PopupMenuButton<String>(
              onSelected: openSettings,
              itemBuilder: (BuildContext context) {
                return {AppLocalizations.of(context)!.settings}
                    .map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),*/
          ],
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            bodyHeight = constraints.maxHeight;
            return IndexedStack(
              index: _currentIndex,
              children: pages,
            );
          },
        ),
        bottomNavigationBar: ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0), ),
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
          ),),
        ));
    return SelectionArea(child: scaffold);
  }

  List<String> primaryRoleIntToStr(List<int> roles) {
    AppLocalizations loc = AppLocalizations.of(context)!;

    List<String> result = [];
    for (var role in roles) {
      switch (role) {
        case 0:
        {
          result.add(loc.garbage);
          break;
        }
        case 1:
        {
          result.add(loc.bathroom);
          break;
        }
        case 2:
        {
          result.add(loc.kitchen);
          break;
        }
        case 3:
        {
          result.add(loc.vacuum);
          break;
        }
        default:
        {
          if (kDebugMode) {
            print("ERROR: wrong role id");
          }
        }
      }
    }
    return result;
  }

  Text createPrimaryRolesText() {
    if (MemberManager.instance.primaryRoles.isEmpty) {
      return const Text("Chores");
    }
    String text = "Chores (";
    for (var element in primaryRoleIntToStr(MemberManager.instance.primaryRoles)) {
      text += "$element, ";
    }
    text = text.substring(0, text.length - 2);
    text += ")";
    return Text(text);
  }
}

double getPaddings() {
  return scaffold.appBar!.preferredSize.height + navBarTheme.height!;
}
