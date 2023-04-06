import 'package:chores/utils/userprefs.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

enum Intervals { onceBegin, onceMiddle, onceEnd, twice, every }
enum Themes { system, light, dark }
enum Languages { en, de, ru }

class _SettingsPageState extends State<SettingsPage> {

  bool? currentValue;
  Icon? currentNotificationStatus;

  Text currentInterval = const Text('Once a week (Monday)');
  Text currentIntervalValue = const Text('Once a week (Monday)');

  Text currentTheme = const Text('System Default');
  Text currentThemeValue = const Text('System Default');
  ThemeMode currentThemeMode = ThemeMode.system;
  Icon currentThemeIcon = const Icon(Icons.light_mode);

  Text currentLanguage = const Text('English');
  Text currentLanguageValue = const Text('English');
  Locale currentLocale = const Locale('en');

  Intervals? _character = Intervals.onceBegin;
  Themes? _theme = Themes.system;
  Languages? _language = Languages.en;

  @override
  void initState() {
    super.initState();

    currentValue = UserPreferences.getNotificationsBool();
    if (currentValue == true) {
      currentNotificationStatus = const Icon(Icons.notifications_off);
    } else {
      currentNotificationStatus = const Icon(Icons.notifications_on);
    }

  }


  Future openIntervalDialog() => showAnimatedDialog(
    barrierDismissible: true,
    animationType: DialogTransitionType.fade,
    duration: const Duration(milliseconds: 300),
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context)!.notInterval,
                  style: const TextStyle(fontSize: 20),
                ),
                actions: [
                  RadioListTile<Intervals>(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(20),
                      ),
                      title: Text(AppLocalizations.of(context)!.monday),
                      value: Intervals.onceBegin,
                      groupValue: _character,
                      onChanged: (value) {
                        setState(() {
                          currentInterval = Text(AppLocalizations.of(context)!.monday);
                          _character = value;
                        });
                      }),
                  RadioListTile<Intervals>(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(20),
                      ),
                      title: Text(AppLocalizations.of(context)!.friday),
                      value: Intervals.onceMiddle,
                      groupValue: _character,
                      onChanged: (value) {
                        setState(() {
                          currentInterval = Text(AppLocalizations.of(context)!.friday);
                          _character = value;
                        });
                      }),
                  RadioListTile<Intervals>(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(20),
                      ),
                      title: Text(AppLocalizations.of(context)!.sunday),
                      value: Intervals.onceEnd,
                      groupValue: _character,
                      onChanged: (value) {
                        setState(() {
                          currentInterval = Text(AppLocalizations.of(context)!.sunday);
                          _character = value;
                        });
                      }),
                  RadioListTile<Intervals>(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(20),
                      ),
                      title: Text(AppLocalizations.of(context)!.twice),
                      value: Intervals.twice,
                      groupValue: _character,
                      onChanged: (value) {
                        setState(() {
                          currentInterval = Text(AppLocalizations.of(context)!.twice);
                          _character = value;
                        });
                      }),
                  RadioListTile<Intervals>(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(20),
                      ),
                      title: Text(AppLocalizations.of(context)!.every),
                      value: Intervals.every,
                      groupValue: _character,
                      onChanged: (value) {
                        setState(() {
                          currentInterval = Text(AppLocalizations.of(context)!.every);
                          _character = value;
                        });
                      }),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget> [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(AppLocalizations.of(context)!.cancel)),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          this.setState(() {
                            currentIntervalValue = currentInterval;
                          });
                        },
                        child: Text(AppLocalizations.of(context)!.confirm)),
                    ],
                  ),
                ],
              );
            },
          );
        },
      );

  final Uri _ghurl = Uri.parse('https://github.com/jerrydix');
  final Uri _itchurl = Uri.parse('https://chernogop.itch.io/');
  final Uri _linkedinurl =
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
                  makeLink('GitHub', _ghurl),
                  makeLink('Itch.io', _itchurl),
                  makeLink('LinkedIn', _linkedinurl),
                ],
              ),
            ),
          ],
        );
      });

  Future openThemeDialog() => showAnimatedDialog(
    barrierDismissible: true,
    animationType: DialogTransitionType.fade,
    duration: const Duration(milliseconds: 300),
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.theme,
              style: const TextStyle(fontSize: 20),
            ),
            actions: [
              RadioListTile<Themes>(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(20),
                  ),
                  title: Text(AppLocalizations.of(context)!.sys),
                    value: Themes.system,
                  groupValue: _theme,
                  onChanged: (value) {
                    setState(() {
                      currentThemeMode = ThemeMode.system;
                      currentTheme = Text(AppLocalizations.of(context)!.sys);
                      _theme = value;
                    });
                  }),
              RadioListTile<Themes>(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(20),
                  ),
                  title: Text(AppLocalizations.of(context)!.light),
                  value: Themes.light,
                  groupValue: _theme,
                  onChanged: (value) {
                    setState(() {
                      currentThemeMode = ThemeMode.light;
                      currentTheme = Text(AppLocalizations.of(context)!.light);
                      _theme = value;
                    });
                  }),
              RadioListTile<Themes>(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(20),
                  ),
                  title: Text(AppLocalizations.of(context)!.dark),
                  value: Themes.dark,
                  groupValue: _theme,
                  onChanged: (value) {
                    setState(() {
                      currentThemeMode = ThemeMode.dark;
                      currentTheme = Text(AppLocalizations.of(context)!.dark);
                      _theme = value;
                    });
                  }),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    this.setState(() {
                      currentThemeValue = currentTheme;
                      if (MediaQuery.of(context).platformBrightness == Brightness.dark && currentThemeMode == ThemeMode.system || currentThemeMode == ThemeMode.dark) {
                        currentThemeIcon = const Icon(Icons.dark_mode);
                      } else {
                        currentThemeIcon = const Icon(Icons.light_mode);
                      }
                    });
                    MyApp.of(context).changeTheme(currentThemeMode);
                  },
                  child: Text(AppLocalizations.of(context)!.confirm)),
            ],
          );
        },
      );
    },
  );

  Future openLanguageDialog() => showAnimatedDialog(
    barrierDismissible: true,
    animationType: DialogTransitionType.fade,
    duration: const Duration(milliseconds: 300),
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.language,
              style: const TextStyle(fontSize: 20),
            ),
            actions: [
              RadioListTile<Languages>(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(20),
                  ),
                  title: const Text("English"),
                  value: Languages.en,
                  groupValue: _language,
                  onChanged: (value) {
                    setState(() {
                      currentLocale = const Locale('en');
                      currentLanguage = const Text("English");
                      _language = value;
                    });
                  }),
              RadioListTile<Languages>(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(20),
                  ),
                  title: const Text("Deutsch"),
                  value: Languages.de,
                  groupValue: _language,
                  onChanged: (value) {
                    setState(() {
                      currentLocale = const Locale('de');
                      currentLanguage = const Text("Deutsch");
                      _language = value;
                    });
                  }),
              RadioListTile<Languages>(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(20),
                  ),
                  title: const Text("Русский"),
                  value: Languages.ru,
                  groupValue: _language,
                  onChanged: (value) {
                    setState(() {
                      currentLocale = const Locale('ru');
                      currentLanguage = const Text("Русский");
                      _language = value;
                    });
                  }),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    MyApp.of(context).setLocale(currentLocale);
                    this.setState(() {
                      currentLanguageValue = currentLanguage;
                    });
                  },
                  child: Text(AppLocalizations.of(context)!.confirm)),
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
        title: Text(AppLocalizations.of(context)!.settings),

      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Title(color: Colors.grey, child: Text(AppLocalizations.of(context)!.options)),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: currentThemeIcon,
                title: Text(AppLocalizations.of(context)!.theme),
                value: currentThemeValue,
                onPressed: (context) {
                  openThemeDialog();
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.language),
                title: Text(AppLocalizations.of(context)!.language),
                value: currentLanguageValue,
                onPressed: (context) {
                  openLanguageDialog();
                },
              ),
              SettingsTile.switchTile(
                initialValue: currentValue,
                leading: currentNotificationStatus,
                title: Text(AppLocalizations.of(context)!.notEnable),
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
                  UserPreferences.setNotificationsBool(value);
                },
              ),
              SettingsTile.navigation(
                title: Text(AppLocalizations.of(context)!.notInterval),
                leading: const Icon(Icons.notifications),
                value: currentIntervalValue,
                onPressed: (context) {
                  openIntervalDialog();
                },
              ),
            ],
          ),
          SettingsSection(
              title: Title(color: Colors.grey, child: Text(AppLocalizations.of(context)!.info)),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  leading: const Icon(Icons.info_outline),
                  title: Text(AppLocalizations.of(context)!.about),
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
