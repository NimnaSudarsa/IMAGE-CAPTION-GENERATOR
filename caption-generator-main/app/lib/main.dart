
import 'dart:convert';

import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:visual/home.dart';
import 'package:visual/server.dart';
import 'package:visual/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Box box = await Hive.openBox('app');

  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {

  int currentPageIndex = 0;

  Widget getPage(currentPageIndex){
    switch(currentPageIndex){
      case 0:
        return const Center(
          child: HomePage()
        );
      case 1:
        return const ServerPage();
      case 2:
        return const SettingsPage();
      default:
        return const Placeholder();
    }

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: getPage(currentPageIndex),
        bottomNavigationBar: Container(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: GNav(
              backgroundColor: Colors.black,
              color: Colors.white,
              activeColor: Colors.white,
              tabBackgroundColor: Colors.grey.shade800,
              gap: 8,
              padding: const EdgeInsets.all(16),
              tabs: const [
                GButton(icon: Icons.home, text: 'Home',),
                GButton(icon: Icons.computer, text: 'Server'),
                GButton(icon: Icons.settings, text: 'Settings',)
              ],
              onTabChange: (index) {
                setState(() {
                  currentPageIndex = index;
                });
                debugPrint('Page changed! $index');
              },
            ),
          ),
        ),
      ),
    );
  }
}



