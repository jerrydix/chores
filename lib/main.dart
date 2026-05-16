import 'package:chores/user_auth/wrapper.dart';
import 'package:chores/utils/notification_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'l10n/app_localizations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/firebase_options.dart';
import 'data/userprefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initializeNotifications();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<StatefulWidget> createState() => MyAppState();

  static MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>()!;
}

class MyAppState extends State<MyApp> {
  ThemeMode? _themeMode;
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    await UserPreferences.init();
    ThemeMode? themeMode;
    Locale? locale;
    switch (UserPreferences.getLanguage()) {
      case 0: locale = const Locale('en'); break;
      case 1: locale = const Locale('de'); break;
      case 2: locale = const Locale('ru'); break;
      case 3: locale = const Locale('zh'); break;
      case 4: locale = const Locale('el'); break;
    }
    switch (UserPreferences.getTheme()) {
      case 0: themeMode = ThemeMode.system; break;
      case 1: themeMode = ThemeMode.light; break;
      case 2: themeMode = ThemeMode.dark; break;
    }
    if (mounted) {
      setState(() {
        _locale = locale;
        _themeMode = themeMode;
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
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
        home:
            const Wrapper(), //check if persisted login, then go to home page, if not go to register / login page
      );
    });
  }
}
