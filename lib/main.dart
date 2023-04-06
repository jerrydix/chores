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

  ThemeMode? _themeMode;
  Locale? _locale;

  void setTheme(ThemeMode? themeMode) {
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

  void setLocale(Locale? value) {
    setState(() {
      _locale = value;
    });
  }

  void init() async {
    await UserPreferences.init();
    switch (UserPreferences.getLanguage()) {
      case 0: {
        _locale = const Locale('en');
        break;
      }
      case 1: {
        _locale = const Locale('de');
        break;
      }
      case 2: {
        _locale = const Locale('ru');
        break;
      }
    }

    switch (UserPreferences.getTheme()) {
      case 0: {
        _themeMode = ThemeMode.system;
        break;
      }
      case 1: {
        _themeMode = ThemeMode.light;
        break;
      }
      case 2: {
        _themeMode = ThemeMode.dark;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    init();
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





