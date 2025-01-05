import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/neumorphic_button.dart';
import 'timer_page.dart';
import 'notes_page.dart';
import 'package:lunch/screens/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const TimerPage(),  // Timer page with top 3 tasks
    const NotesPage(),  // Tasks/Notes page
  ];

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return NeumorphicButton(
      width: 60,
      height: 60,
      onPressed: () => setState(() => _selectedIndex = index),
      child: Icon(
        icon,
        color: isSelected ? AppColors.primaryColor : AppColors.textColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _pages[_selectedIndex],
            Positioned(
              top: 16,
              right: 16,
              child: NeumorphicButton(
                width: 48,
                height: 48,
                onPressed: _openSettings,
                child: Icon(Icons.settings, color: AppColors.textColor),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.timer, 0),
            _buildNavItem(Icons.note_alt_outlined, 1),
          ],
        ),
      ),
    );
  }
}





