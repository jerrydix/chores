import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chores/member_manager.dart';
import 'package:chores/data/providers/authentication_provider.dart';
import 'package:chores/user_auth/pages/login.dart';
import 'package:chores/utils/notification_list.dart';
import 'package:chores/data/userprefs.dart';
import 'package:chores/views/role_task_settings.dart';
import 'package:chores/views/wg_selection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:settings_ui/settings_ui.dart';
import '../l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsState();
}

enum Intervals { onceBegin, onceMiddle, onceEnd, twice, every }

enum Themes { system, light, dark }

enum Languages { en, de, ru }

class _SettingsState extends State<Settings> {
  bool? currentNotificationValue;
  Icon? currentNotificationStatus;

  bool? currentActiveValue;
  Icon? currentActiveIcon;

  Text? currentInterval;
  Text? currentIntervalValue;

  Text? currentTheme;
  Text? currentThemeValue;
  ThemeMode? currentThemeMode;
  Icon? currentThemeIcon;

  Text? currentLanguage;
  Text? currentLanguageValue;
  Locale? currentLocale;

  Intervals? _character;
  Themes? _theme;
  Languages? _language;

  void init() {
    currentNotificationValue = UserPreferences.getNotificationsBool();
    currentActiveValue = MemberManager.instance.active;
    if (currentActiveValue!) {
      currentActiveIcon = const Icon(Icons.check_circle);
    } else {
      currentActiveIcon = const Icon(Icons.check_circle_outline);
    }
    if (currentNotificationValue!) {
      currentNotificationStatus = const Icon(Icons.notifications_on);
    } else {
      currentNotificationStatus = const Icon(Icons.notifications_off);
    }

    switchCurrentNotificationValue();
    switchCurrentThemeValue();
    switchCurrentLanguageValue();
  }

  void switchCurrentNotificationValue() {
    switch (UserPreferences.getNotificationInterval()) {
      case 0:
        {
          currentInterval = currentIntervalValue = Text(AppLocalizations.of(context)!.monday);
          _character = Intervals.onceBegin;
          break;
        }
      case 1:
        {
          currentInterval = currentIntervalValue = Text(AppLocalizations.of(context)!.friday);
          _character = Intervals.onceMiddle;
          break;
        }
      case 2:
        {
          currentInterval = currentIntervalValue = Text(AppLocalizations.of(context)!.sunday);
          _character = Intervals.onceEnd;
          break;
        }
      case 3:
        {
          currentInterval = currentIntervalValue = Text(AppLocalizations.of(context)!.twice);
          _character = Intervals.twice;
          break;
        }
      case 4:
        {
          currentInterval = currentIntervalValue = Text(AppLocalizations.of(context)!.every);
          _character = Intervals.every;
          break;
        }
    }
  }

  void switchCurrentThemeValue() {
    switch (UserPreferences.getTheme()) {
      case 0:
        {
          currentThemeMode = ThemeMode.system;
          currentTheme =
              currentThemeValue = Text(AppLocalizations.of(context)!.sys);
          if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
            currentThemeIcon = const Icon(Icons.dark_mode);
          } else {
            currentThemeIcon = const Icon(Icons.light_mode);
          }
          _theme = Themes.system;
          break;
        }
      case 1:
        {
          currentThemeMode = ThemeMode.light;
          currentTheme =
              currentThemeValue = Text(AppLocalizations.of(context)!.light);
          currentThemeIcon = const Icon(Icons.light_mode);
          _theme = Themes.light;
          break;
        }
      case 2:
        {
          currentThemeMode = ThemeMode.dark;
          currentTheme =
              currentThemeValue = Text(AppLocalizations.of(context)!.dark);
          currentThemeIcon = const Icon(Icons.dark_mode);
          _theme = Themes.dark;
          break;
        }
    }
  }

  void switchCurrentLanguageValue() {
    if (UserPreferences.getLanguage() == -1) {
      if (Intl.getCurrentLocale() == "en") {
        UserPreferences.setLanguage(0);
      }
      if (Intl.getCurrentLocale() == "de") {
        UserPreferences.setLanguage(1);
      }
      if (Intl.getCurrentLocale() == "ru") {
        UserPreferences.setLanguage(2);
      }
    }
    switch (UserPreferences.getLanguage()) {
      case 0:
        {
          currentLanguage = currentLanguageValue = const Text('English');
          currentLocale = const Locale('en');
          _language = Languages.en;
          break;
        }
      case 1:
        {
          currentLanguage = currentLanguageValue = const Text('Deutsch');
          currentLocale = const Locale('de');
          _language = Languages.de;
          break;
        }
      case 2:
        {
          currentLanguage = currentLanguageValue = const Text('Русский');
          currentLocale = const Locale('ru');
          _language = Languages.ru;
          break;
        }
    }
  }

  Future openIntervalDialog() {
    switchCurrentNotificationValue();
    return showDialog(
      barrierDismissible: true,
      //animationType: DialogTransitionType.fade,
      //duration: const Duration(milliseconds: 300),
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.notInterval,
                style: const TextStyle(fontSize: 20),
              ),
              actions: [
                RadioListTile<Intervals>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(AppLocalizations.of(context)!.monday),
                    value: Intervals.onceBegin,
                    groupValue: _character,
                    onChanged: (value) {
                      setState(() {
                        currentInterval =
                            Text(AppLocalizations.of(context)!.monday);
                        _character = value;
                      });
                    }),
                RadioListTile<Intervals>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(AppLocalizations.of(context)!.friday),
                    value: Intervals.onceMiddle,
                    groupValue: _character,
                    onChanged: (value) {
                      setState(() {
                        currentInterval =
                            Text(AppLocalizations.of(context)!.friday);
                        _character = value;
                      });
                    }),
                RadioListTile<Intervals>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(AppLocalizations.of(context)!.sunday),
                    value: Intervals.onceEnd,
                    groupValue: _character,
                    onChanged: (value) {
                      setState(() {
                        currentInterval =
                            Text(AppLocalizations.of(context)!.sunday);
                        _character = value;
                      });
                    }),
                RadioListTile<Intervals>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(AppLocalizations.of(context)!.twice),
                    value: Intervals.twice,
                    groupValue: _character,
                    onChanged: (value) {
                      setState(() {
                        currentInterval =
                            Text(AppLocalizations.of(context)!.twice);
                        _character = value;
                      });
                    }),
                RadioListTile<Intervals>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(AppLocalizations.of(context)!.every),
                    value: Intervals.every,
                    groupValue: _character,
                    onChanged: (value) {
                      setState(() {
                        currentInterval =
                            Text(AppLocalizations.of(context)!.every);
                        _character = value;
                      });
                    }),
                TextButton(
                    onPressed: () async {
                      switch (_character) {
                        case Intervals.onceBegin:
                          {
                            await UserPreferences.setNotificationInterval(0);
                            break;
                          }
                        case Intervals.onceMiddle:
                          {
                            await UserPreferences.setNotificationInterval(1);
                            break;
                          }
                        case Intervals.onceEnd:
                          {
                            await UserPreferences.setNotificationInterval(2);
                            break;
                          }
                        case Intervals.twice:
                          {
                            await UserPreferences.setNotificationInterval(3);
                            break;
                          }
                        case Intervals.every:
                          {
                            await UserPreferences.setNotificationInterval(4);
                            break;
                          }
                        case null:
                          throw Exception("Interval is null");
                      }
                      if (currentNotificationValue! && currentActiveValue!) {
                        await AwesomeNotifications().cancelAllSchedules().then((_) async {
                          if (UserPreferences.getNotificationsBool()) {
                            List<int> weekdays = getNotificationWeekday(_character!);
                            for (int weekday in weekdays) {
                              await NotificationService.scheduleChoresNotification(
                                  id: 0,
                                  title: AppLocalizations.of(context)!.n_title,
                                  body: AppLocalizations.of(context)!.n_text,
                                  weekday: weekday
                              );
                            }
                          }
                        });
                      }
                      this.setState(() {
                        currentIntervalValue = currentInterval;
                      });
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)!.confirm)),
              ],
            );
          },
        );
      },
    );
  }

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
          applicationIcon: const Image(
            image: AssetImage('assets/logo.png'),
            width: 55,
            height: 55,
          ),
          applicationName: 'Chores',
          applicationVersion: '1.0.0',
          children: <Widget>[
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: 'Developed by Jeremy Dix\n\n',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      )),
                  makeLink('GitHub', _ghurl),
                  makeLink('Itch.io', _itchurl),
                  makeLink('LinkedIn', _linkedinurl),
                ],
              ),
            ),
          ],
        );
      });

  Future openLogoutDialog() => showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.logout_t,
            style: const TextStyle(fontSize: 20),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.cancel)),
            TextButton(
                onPressed: () {
                  AuthenticationProvider(FirebaseAuth.instance).signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ), (route) => false
                  );
                },
                child: Text(AppLocalizations.of(context)!.confirm)),
          ],
        );
      });

  Future openThemeDialog() {
    switchCurrentThemeValue();
    return showDialog(
      barrierDismissible: true,
      //animationType: DialogTransitionType.fade,
      //duration: const Duration(milliseconds: 300),
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.theme,
                style: const TextStyle(fontSize: 20),
              ),
              actions: [
                RadioListTile<Themes>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(AppLocalizations.of(context)!.sys),
                    value: Themes.system,
                    groupValue: _theme,
                    onChanged: (value) {
                      currentThemeMode = ThemeMode.system;
                      setState(() {
                        currentTheme =
                            Text(AppLocalizations.of(context)!.sys);
                        _theme = value;
                      });
                    }),
                RadioListTile<Themes>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(AppLocalizations.of(context)!.light),
                    value: Themes.light,
                    groupValue: _theme,
                    onChanged: (value) {
                      currentThemeMode = ThemeMode.light;
                      setState(() {
                        currentTheme =
                            Text(AppLocalizations.of(context)!.light);
                        _theme = value;
                      });
                    }),
                RadioListTile<Themes>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(AppLocalizations.of(context)!.dark),
                    value: Themes.dark,
                    groupValue: _theme,
                    onChanged: (value) {
                      currentThemeMode = ThemeMode.dark;
                      setState(() {
                        currentTheme =
                            Text(AppLocalizations.of(context)!.dark);
                        _theme = value;
                      });
                    }),
                TextButton(
                    onPressed: () {
                      switch (_theme) {
                        case Themes.system:
                          {
                            UserPreferences.setTheme(0);
                            break;
                          }
                        case Themes.light:
                          {
                            UserPreferences.setTheme(1);
                            break;
                          }
                        case Themes.dark:
                          {
                            UserPreferences.setTheme(2);
                            break;
                          }
                        case null:
                          throw Exception("Theme is null");
                      }
                      this.setState(() {
                        currentThemeValue = currentTheme;
                        if (MediaQuery.of(context).platformBrightness ==
                            Brightness.dark &&
                            currentThemeMode == ThemeMode.system ||
                            currentThemeMode == ThemeMode.dark) {
                          currentThemeIcon = const Icon(Icons.dark_mode);
                        } else {
                          currentThemeIcon = const Icon(Icons.light_mode);
                        }
                      });
                      MyApp.of(context).setTheme(currentThemeMode);
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)!.confirm)),
              ],
            );
          },
        );
      },
    );
  }

  Future openLanguageDialog() {
    switchCurrentLanguageValue();
    return showDialog(
      barrierDismissible: true,
      //animationType: DialogTransitionType.fade,
      //duration: const Duration(milliseconds: 300),
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.language,
                style: const TextStyle(fontSize: 20),
              ),
              actions: [
                RadioListTile<Languages>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text("English"),
                    value: Languages.en,
                    groupValue: _language,
                    onChanged: (value) {
                      currentLocale = const Locale('en');
                      setState(() {
                        currentLanguage = const Text("English");
                        _language = value;
                      });
                    }),
                RadioListTile<Languages>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text("Deutsch"),
                    value: Languages.de,
                    groupValue: _language,
                    onChanged: (value) {
                      currentLocale = const Locale('de');
                      setState(() {
                        currentLanguage = const Text("Deutsch");
                        _language = value;
                      });
                    }),
                RadioListTile<Languages>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text("Русский"),
                    value: Languages.ru,
                    groupValue: _language,
                    onChanged: (value) {
                      currentLocale = const Locale('ru');
                      setState(() {
                        currentLanguage = const Text("Русский");
                        _language = value;
                      });
                    }),
                TextButton(
                    onPressed: () async {
                      switch (_language) {
                        case Languages.en:
                          {
                            await UserPreferences.setLanguage(0);
                            break;
                          }
                        case Languages.de:
                          {
                            await UserPreferences.setLanguage(1);
                            break;
                          }
                        case Languages.ru:
                          {
                            await UserPreferences.setLanguage(2);
                            break;
                          }
                        case null:
                          throw Exception("Language is null");
                      }
                      MyApp.of(context).setLocale(currentLocale);
                      this.setState(() {
                        currentLanguageValue = currentLanguage;
                      });
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)!.confirm)),
              ],
            );
          },
        );
      },
    );
  }

  Future openLeaveDialog() => showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.leave_wg_t,
            style: const TextStyle(fontSize: 20),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.cancel)),
            TextButton(
                onPressed: () async {

                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );

                  FirebaseFirestore db = FirebaseFirestore.instance;
                  MemberManager manager = MemberManager.instance;
                  await db.collection("wgs").doc(manager.currentWgID).collection("members").doc(manager.user?.uid).delete();
                  await db.collection("wgs").doc(manager.currentWgID).update({
                    "count": FieldValue.increment(-1),
                  });
                  await db.collection("users").doc(manager.user?.uid).update({
                    "wg": -1,
                  });

                  if (manager.memberCount == 1) {
                    await db.collection("wgs").doc(manager.currentWgID).delete();
                  }

                  Navigator.pop(context);

                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => WGSelection(username: FirebaseAuth.instance.currentUser!.displayName!),
                      ), (route) => false
                  );
                },
                child: Text(AppLocalizations.of(context)!.confirm)),
          ],
        );
      });

  List<int> getNotificationWeekday(Intervals interval) {
    List<int> weekdays = [];
    switch (interval) {
      case Intervals.onceBegin:
        weekdays.add(1);
        break;
      case Intervals.onceMiddle:
        weekdays.add(3);
        break;
      case Intervals.onceEnd:
        weekdays.add(6);
        break;
      case Intervals.twice:
        weekdays.add(2);
        weekdays.add(5);
        break;
      case Intervals.every:
        for (int i = 1; i < 7; i++) {
          weekdays.add(i);
        }
        break;
    }
    return weekdays;
  }

  Future<void> openRoleTaskSettings() async {
    Route route = MaterialPageRoute(builder: (context) => RoleTaskSettings());
    await Navigator.push(context, route);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    init();
    return SelectionArea(child: Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        actions: <Widget>[
          Container(
            padding: const EdgeInsets.only(right: 10),
            child: ElevatedButton(onPressed: () {
              openLogoutDialog();
            }, child: Text(AppLocalizations.of(context)!.logout)),
          ),
        ],
      ),
      body: SettingsList(
        darkTheme: SettingsThemeData(
          settingsListBackground: Theme.of(context).colorScheme.surface,
          settingsSectionBackground: Theme.of(context).colorScheme.surfaceContainer,
        ),
        lightTheme: SettingsThemeData(
          settingsListBackground: Theme.of(context).colorScheme.surface,
          settingsSectionBackground: Theme.of(context).colorScheme.surfaceContainer,
        ),
        sections: [
          SettingsSection(
            title: Title(
                color: Colors.grey,
                child: Text(AppLocalizations.of(context)!.options, style: TextStyle(color: Theme.of(context).colorScheme.primary))),
            tiles: <SettingsTile>[
              SettingsTile.switchTile(
                initialValue: currentActiveValue,
                leading: currentActiveIcon,
                title: Text(AppLocalizations.of(context)!.active),
                onToggle: (bool value) async {
                  FirebaseFirestore db = FirebaseFirestore.instance;
                  MemberManager manager = MemberManager.instance;
                  await db.collection("wgs").doc(manager.currentWgID).collection("members").doc(manager.user?.uid).update({
                    "active": value,
                  });
                  if (value && currentNotificationValue!) {
                    await AwesomeNotifications().cancelAllSchedules().then((_) async {
                      List<int> weekdays = getNotificationWeekday(_character!);
                      for (int weekday in weekdays) {
                        await NotificationService.scheduleChoresNotification(
                            id: 0,
                            title: AppLocalizations.of(context)!.n_title,
                            body: AppLocalizations.of(context)!.n_text,
                            weekday: weekday
                        );
                      }
                    });
                  } else {
                    await AwesomeNotifications().cancelAllSchedules();
                  }
                  MemberManager.instance.updateActive(value);
                  setState(() {
                    currentActiveValue = value;
                    if (value) {
                        currentActiveIcon = const Icon(Icons.check_circle);
                      } else {
                        currentActiveIcon = const Icon(Icons.check_circle_outline);
                      }
                  });
                }
              ),
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
                initialValue: currentNotificationValue,
                leading: currentNotificationStatus,
                title: Text(AppLocalizations.of(context)!.notEnable),
                onToggle: (bool value) async {
                  if (value && currentActiveValue!) {
                    await AwesomeNotifications().cancelAllSchedules().then((_) async {
                      List<int> weekdays = getNotificationWeekday(_character!);
                      for (int weekday in weekdays) {
                        await NotificationService.scheduleChoresNotification(
                            id: 0,
                            title: AppLocalizations.of(context)!.n_title,
                            body: AppLocalizations.of(context)!.n_text,
                            weekday: weekday
                        );
                      }
                    });
                  } else {
                    await AwesomeNotifications().cancelAllSchedules();
                  }
                  setState(() {
                    currentNotificationValue = value;
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
              title: Title(
                  color: Colors.grey,
                  child: Text(AppLocalizations.of(context)!.wg_settings, style: TextStyle(color: Theme.of(context).colorScheme.primary))),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  leading: const Icon(Icons.logout),
                  title: Text(AppLocalizations.of(context)!.leave_wg),
                  onPressed: (context) {
                    openLeaveDialog();
                  },
                ),
                SettingsTile.navigation(
                  title: Text(AppLocalizations.of(context)!.role_task_settings),
                  leading: const Icon(Icons.view_list_rounded),
                  onPressed: (context) {
                    openRoleTaskSettings();
                  }
                )
              ]
          ),
          SettingsSection(
              title: Title(
                  color: Colors.grey,
                  child: Text(AppLocalizations.of(context)!.info, style: TextStyle(color: Theme.of(context).colorScheme.primary))),
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
    ),);
  }
}
