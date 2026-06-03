import 'package:flutter/material.dart';
import '../screens/main_tabs_screen.dart'; // Make sure this path points to your new MainTabsScreen file

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // This connects the /home route from your splash screen directly to the tab manager
    return const MainTabsScreen(); 
  }
}