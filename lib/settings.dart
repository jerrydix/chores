import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

enum Intervals { onceBegin, onceEnd, twice, every }

class _SettingsPageState extends State<SettingsPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<bool> _notificationOn;

  bool currentValue = false;
  Icon currentNotificationStatus = Icon(Icons.notifications_off);
  String currentLanguage = 'English';
  String currentTheme = 'System';
  Text currentInterval = Text('Once a week (Monday)');
  Text currentIntervalValue = Text('Once a week (Monday)');

  Intervals? _character = Intervals.onceBegin;

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

  Future openDialog() => showDialog(
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
                      title: const Text('Once a week (Monday)'),
                      value: Intervals.onceBegin,
                      groupValue: _character,
                      onChanged: (value) {
                        setState(() {
                          currentInterval = Text('Once a week (Monday)');
                          _character = value;
                        });
                      }),
                  RadioListTile<Intervals>(
                      title: const Text('Once a week (Sunday)'),
                      value: Intervals.onceEnd,
                      groupValue: _character,
                      onChanged: (value) {
                        setState(() {
                          currentInterval = Text('Once a week (Sunday)');
                          _character = value;
                        });
                      }),
                  RadioListTile<Intervals>(
                      title: const Text('Twice a week'),
                      value: Intervals.twice,
                      groupValue: _character,
                      onChanged: (value) {
                        setState(() {
                          currentInterval = Text('Twice a week');
                          _character = value;
                        });
                      }),
                  RadioListTile<Intervals>(
                      title: const Text('Every day'),
                      value: Intervals.every,
                      groupValue: _character,
                      onChanged: (value) {
                        setState(() {
                          currentInterval = Text('Every day');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_circle_down),
            onPressed: () {
              print(currentInterval);
            },
          )
        ],
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.light_mode),
                title: Text('Theme'),
                value: Text(currentTheme),
                onPressed: (context) {},
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.language),
                title: Text('Language'),
                value: Text(currentLanguage),
                onPressed: (context) {},
              ),
              SettingsTile.switchTile(
                onToggle: (bool value) {
                  setState(() {
                    currentValue = value;
                    if (value) {
                      currentNotificationStatus =
                          Icon(Icons.notifications_active);
                    } else {
                      currentNotificationStatus = Icon(Icons.notifications_off);
                    }
                  });
                },
                initialValue: currentValue,
                leading: currentNotificationStatus,
                title: Text('Enable notifications'),
              ),
              SettingsTile.navigation(
                title: Text('Notification Interval'),
                leading: Icon(Icons.notifications),
                value: currentIntervalValue,
                onPressed: (context) {
                  openDialog();
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
