import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool currentValue = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
        body: SettingsList(
          sections: [
            SettingsSection(
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  leading: Icon(Icons.language),
                  title: Text('Language'),
                  value: Text('English'),
                  onPressed: (context) {},
                ),
                SettingsTile.switchTile (
                  onToggle: (bool value) { setState(() {
                    currentValue = value;
                  });},
                  initialValue: currentValue,
                  leading: Icon(Icons.notifications),
                  title: Text('Enable notifications'),
                ),
              ],
            ),
          ],
        ),
    );
  }
}