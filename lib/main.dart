import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'navigationbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'utils/userprefs.dart';

void main() async {
  runApp(const MyApp());
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();


  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = PlatformDispatcher.instance.locale;

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  ThemeData setThemeData(ColorScheme? scheme, Brightness brightness) {
    if (scheme != null) {
      return ThemeData(
        useMaterial3: true,
        brightness: brightness,
        colorScheme: scheme,
      );
    }
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorSchemeSeed: Colors.teal,
    );
  }

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: 'Chores',
          theme: setThemeData(lightDynamic, Brightness.light),
          darkTheme: setThemeData(darkDynamic, Brightness.dark),
          themeMode: _themeMode,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('de'),
            Locale('ru'),
          ],
          locale: _locale,
          home: const NavBar(),
        );
      }
    );
  }
}





