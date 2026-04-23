import 'package:deep_focus/core/constant/app_colors.dart';
import 'package:deep_focus/features/focus/view/presentation_screen.dart';
import 'package:deep_focus/features/settings/view/settings_screen.dart';

import 'package:deep_focus/features/sounds/view/sounds_screen.dart';
import 'package:flutter/material.dart';

class Navigation extends StatefulWidget {
  final int? pageNum;
  const Navigation({super.key, this.pageNum});

  @override
  // ignore: library_private_types_in_public_api
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int selectedIndex = 0;

  final List<Widget> screens = [
    const PresentationScreen(),
    const SoundsScreen(),
    const SettingsScreen(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.neutral,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.secondary,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.center_focus_strong),
            label: "FOCUS",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.waves), label: "SOUNDS"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "SETTINGS",
          ),
        ],
      ),
    );
  }
}
