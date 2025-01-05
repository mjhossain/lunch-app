import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import '../widgets/neumorphic_button.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _workDuration = 25;
  int _breakDuration = 5;
  bool _notifications = true;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _workDuration = prefs.getInt('work_duration') ?? 25;
      _breakDuration = prefs.getInt('break_duration') ?? 5;
      _notifications = prefs.getBool('notifications') ?? true;
      _darkMode = prefs.getBool('dark_mode') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('work_duration', _workDuration);
    await prefs.setInt('break_duration', _breakDuration);
    await prefs.setBool('notifications', _notifications);
    await prefs.setBool('dark_mode', _darkMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSettingSection(
            'Timer Duration',
            Column(
              children: [
                _buildDurationSetting(
                  'Work Duration',
                  _workDuration,
                      (value) => setState(() => _workDuration = value),
                ),
                const SizedBox(height: 16),
                _buildDurationSetting(
                  'Break Duration',
                  _breakDuration,
                      (value) => setState(() => _breakDuration = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSettingSection(
            'Notifications',
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: _notifications,
              onChanged: (value) {
                setState(() => _notifications = value);
                _saveSettings();
              },
            ),
          ),
          const SizedBox(height: 20),
          _buildSettingSection(
            'Theme',
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: _darkMode,
              onChanged: (value) {
                setState(() => _darkMode = value);
                _saveSettings();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSection(String title, Widget content) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSetting(
      String label,
      int duration,
      Function(int) onChanged,
      ) {
    return Row(
      children: [
        Text(label),
        const Spacer(),
        NeumorphicButton(
          width: 40,
          height: 40,
          onPressed: () {
            if (duration > 5) {
              onChanged(duration - 5);
              _saveSettings();
            }
          },
          child: const Icon(Icons.remove, size: 20),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '$duration min',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        NeumorphicButton(
          width: 40,
          height: 40,
          onPressed: () {
            onChanged(duration + 5);
            _saveSettings();
          },
          child: const Icon(Icons.add, size: 20),
        ),
      ],
    );
  }
}