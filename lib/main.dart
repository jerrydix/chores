import 'package:chores/user_auth/wrapper.dart';
import 'package:chores/utils/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'l10n/app_localizations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'utils/userprefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initializeNotifications();
  await Firebase.initializeApp(
    options: kIsWeb ? DefaultFirebaseOptions.currentPlatform : null,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
      colorSchemeSeed: Colors.white,
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
      case 0:
        {
          _locale = const Locale('en');
          break;
        }
      case 1:
        {
          _locale = const Locale('de');
          break;
        }
      case 2:
        {
          _locale = const Locale('ru');
          break;
        }
    }

    switch (UserPreferences.getTheme()) {
      case 0:
        {
          _themeMode = ThemeMode.system;
          break;
        }
      case 1:
        {
          _themeMode = ThemeMode.light;
          break;
        }
      case 2:
        {
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
        navigatorKey: MyApp.navigatorKey,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: _locale,
        home: const Wrapper(), //check if persisted login, then go to home page, if not go to register / login page
      );
    });
  }
}
