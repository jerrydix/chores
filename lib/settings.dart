import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

enum Intervals { onceBegin, onceEnd, twice, every }
enum Themes { system, light, dark }

class _SettingsPageState extends State<SettingsPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<bool> _notificationOn;

  bool currentValue = false;
  Icon currentNotificationStatus = const Icon(Icons.notifications_off);
  String currentLanguage = 'English';
  Text currentInterval = const Text('Once a week (Monday)');
  Text currentIntervalValue = const Text('Once a week (Monday)');

  Text currentTheme = const Text('System Default');
  Text currentThemeValue = const Text('System Default');
  ThemeMode currentThemeMode = ThemeMode.system;

  Intervals? _character = Intervals.onceBegin;
  Themes? _theme = Themes.system;

  final ValueNotifier<ThemeMode> _notifier = ValueNotifier(ThemeMode.light);

  @override
  void initState() {
    super.initState();
    _notificationOn = _prefs.then((SharedPreferences prefs) {
      return prefs.getBool('notificationOn') ?? false;
    });
  }

  Future<void> _setNotificationOn(bool value) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      _notificationOn = prefs.setBool('notificationOn', value);
    });
  }

  Future openIntervalDialog() => showAnimatedDialog(
    animationType: DialogTransitionType.fade,
    duration: Duration(milliseconds: 300),
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text(
                  'Notification Interval',
                  style: TextStyle(fontSize: 20),
                ),
                actions: [
                  RadioListTile<Intervals>(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(20),
                      ),
                      title: const Text('Once a week (Monday)'),
                      value: Intervals.onceBegin,
                      groupValue: _character,
                      onChanged: (value) {
                        setState(() {
                          currentInterval = const Text('Once a week (Monday)');
                          _character = value;
                        });
                      }),
                  RadioListTile<Intervals>(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(20),
                      ),
                      title: const Text('Once a week (Sunday)'),
                      value: Intervals.onceEnd,
                      groupValue: _character,
                      onChanged: (value) {
                        setState(() {
                          currentInterval = const Text('Once a week (Sunday)');
                          _character = value;
                        });
                      }),
                  RadioListTile<Intervals>(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(20),
                      ),
                      title: const Text('Twice a week'),
                      value: Intervals.twice,
                      groupValue: _character,
                      onChanged: (value) {
                        setState(() {
                          currentInterval = const Text('Twice a week');
                          _character = value;
                        });
                      }),
                  RadioListTile<Intervals>(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(20),
                      ),
                      title: const Text('Every day'),
                      value: Intervals.every,
                      groupValue: _character,
                      onChanged: (value) {
                        setState(() {
                          currentInterval = const Text('Every day');
                          _character = value;
                        });
                      }),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        this.setState(() {
                          currentIntervalValue = currentInterval;
                        });
                      },
                      child: const Text('Confirm')),
                ],
              );
            },
          );
        },
      );

  final Uri _GHurl = Uri.parse('https://github.com/jerrydix');
  final Uri _Itchurl = Uri.parse('https://chernogop.itch.io/');
  final Uri _Linkedinurl =
      Uri.parse('https://www.linkedin.com/in/jeremy-dix-805215235/');

  TextSpan makeLink(String name, Uri uri) {
    return TextSpan(
      text: '$name\n',
      style: const TextStyle(
          color: Colors.blue, decoration: TextDecoration.underline),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          launchUrl(uri);
        },
    );
  }

  Future openAboutDialog() => showDialog(
      context: context,
      builder: (context) {
        return AboutDialog(
          applicationIcon: const Image(image: AssetImage('assets/logo.png'), width: 55, height: 55,),
          applicationName: 'Chores',
          applicationVersion: '1.0',
          children: <Widget>[
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Developed by Jeremy Dix\n\n',
                    style: TextStyle(color: Colors.white,)
                  ),
                  makeLink('GitHub', _GHurl),
                  makeLink('Itch.io', _Itchurl),
                  makeLink('LinkedIn', _Linkedinurl),
                ],
              ),
            ),
          ],
        );
      });

  Future openThemeDialog() => showAnimatedDialog(
    animationType: DialogTransitionType.fade,
    duration: Duration(milliseconds: 300),
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              'Theme',
              style: TextStyle(fontSize: 20),
            ),
            actions: [
              RadioListTile<Themes>(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(20),
                  ),
                  title: const Text('System Default'),
                    value: Themes.system,
                  groupValue: _theme,
                  onChanged: (value) {
                    setState(() {
                      currentThemeMode = ThemeMode.system;
                      currentThemeValue = const Text('System Default');
                      _theme = value;
                    });
                  }),
              RadioListTile<Themes>(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(20),
                  ),
                  title: const Text('Light'),
                  value: Themes.light,
                  groupValue: _theme,
                  onChanged: (value) {
                    setState(() {
                      currentThemeMode = ThemeMode.light;
                      currentThemeValue = const Text('Light');
                      _theme = value;
                    });
                  }),
              RadioListTile<Themes>(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(20),
                  ),
                  title: const Text('Dark'),
                  value: Themes.dark,
                  groupValue: _theme,
                  onChanged: (value) {
                    setState(() {
                      currentThemeMode = ThemeMode.dark;
                      currentThemeValue = const Text('Dark');
                      _theme = value;
                    });
                  }),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    this.setState(() {
                      currentThemeValue = currentTheme;
                    });
                    MyApp.of(context).changeTheme(currentThemeMode);
                  },
                  child: const Text('Confirm')),
            ],
          );
        },
      );
    },
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Title(color: Colors.grey, child: const Text('Options')),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.light_mode),
                title: const Text('Theme'),
                value: currentThemeValue,
                onPressed: (context) {
                  openThemeDialog();
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                value: Text(currentLanguage),
                onPressed: (context) {},
              ),
              SettingsTile.switchTile(
                onToggle: (bool value) {
                  setState(() {
                    currentValue = value;
                    if (value) {
                      currentNotificationStatus =
                          const Icon(Icons.notifications_active);
                    } else {
                      currentNotificationStatus =
                          const Icon(Icons.notifications_off);
                    }
                  });
                },
                initialValue: currentValue,
                leading: currentNotificationStatus,
                title: const Text('Enable notifications'),
              ),
              SettingsTile.navigation(
                title: const Text('Notification Interval'),
                leading: const Icon(Icons.notifications),
                value: currentIntervalValue,
                onPressed: (context) {
                  openIntervalDialog();
                },
              ),
            ],
          ),
          SettingsSection(
              title: Title(color: Colors.grey, child: const Text('Info')),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  onPressed: (context) {
                    openAboutDialog();
                  },
                )
              ]),
        ],
      ),
    );
  }
}
