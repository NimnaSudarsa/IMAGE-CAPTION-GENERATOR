import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  Box box = Hive.box('app');
  late bool isCaptionEnabled;



  @override
  void initState() {
    super.initState();

    try{
      isCaptionEnabled = box.get('isCaptionEnabled');
    }catch(err){
      box.put('isCaptionEnabled', false);
      isCaptionEnabled = false;
    }

  }

  SettingsThemeData settingsTheme() {
    return const SettingsThemeData(
      settingsListBackground: Color.fromRGBO(31, 31, 31, 1),
      titleTextColor: Colors.white,
      dividerColor: Colors.white,
      inactiveSubtitleColor: Colors.white,
      leadingIconsColor: Colors.white,
      tileHighlightColor: Colors.white,
      inactiveTitleColor: Colors.white,
      settingsTileTextColor: Colors.white,
      tileDescriptionTextColor: Colors.white
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SettingsList(
        lightTheme: settingsTheme(),
        darkTheme: settingsTheme(),
        sections: [
          SettingsSection(
            title: const Text('Settings'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                value: const Text('English'),
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.people_alt),
                title: const Text('About'),
                value: const Text('App description'),
                onPressed: (context){
                  showAboutDialog(
                    context: context,
                    applicationIcon: const Icon(Icons.abc),
                    applicationName: 'About',
                    applicationLegalese: 'This app is licensed updated MIT License'
                  );
                },
              ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  if(value){
                    box.put('isCaptionEnabled', true);
                  }else {
                    box.put('isCaptionEnabled', false);
                  }
                  setState(() {
                    isCaptionEnabled = box.get('isCaptionEnabled');
                  });
                },
                initialValue: isCaptionEnabled,
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Enable caption'),
              )

            ],
          ),
        ],
      ),
    );
  }
}
