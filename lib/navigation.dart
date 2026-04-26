import 'package:deep_focus/core/constant/app_colors.dart';
import 'package:deep_focus/features/about/view/about_screen.dart';
import 'package:deep_focus/features/focus/view/presentation_screen.dart';
import 'package:deep_focus/features/settings/view/settings_screen.dart';

import 'package:deep_focus/features/sounds/view/sounds_screen.dart';
import 'package:deep_focus/features/sounds/viewmodel/audio_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    const AboutScreen(),
  ];

  void onItemTapped(int index) {
    if (index != selectedIndex) {
      // STOP MUSIC when switching pages
      context.read<AudioProvider>().pauseAudio();
    }
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
            icon: const Icon(Icons.track_changes),
            label: "FOCUS",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.waves), label: "SOUNDS"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "SETTINGS",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "ABOUT"),
        ],
      ),
    );
  }
}
