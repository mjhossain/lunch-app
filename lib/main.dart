// main.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/timer_page.dart';
import 'pages/tasks_page.dart';
import 'models/lunch_note.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lunch Timer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _notesController = TextEditingController();
  Timer? _timer;
  int _lunchDuration = 60; // Default lunch duration in minutes
  int _remainingTime = 0;
  List<LunchNote> _notes = [];
  bool _isRunning = false;
  bool _showRefresher = false;
  DateTime? _clockOutTime;
  int _currentIndex = 0; // Add this for bottom navigation
  DateTime? _pauseTime; // Add this to track pause time
  Duration? _pausedDuration; // Add this to track paused duration

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // Load saved notes from persistent storage
  Future<void> _loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getStringList('lunch_notes') ?? [];
      setState(() {
        _notes = notesJson
            .map((note) => LunchNote.fromJson(jsonDecode(note)))
            .toList();
      });
    } catch (e) {
      // Handle potential JSON parsing errors
      debugPrint('Error loading notes: $e');
      setState(() {
        _notes = []; // Reset to empty list if there's an error
      });
    }
  }

  // Save notes to persistent storage
  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = _notes.map((note) => note.toJson().toString()).toList();
    await prefs.setStringList('lunch_notes', notesJson);
  }

  // Start lunch break timer
  void _startTimer() {
    setState(() {
      if (_pausedDuration != null) {
        // Adjust clock out time based on paused duration
        _clockOutTime = DateTime.now().add(Duration(seconds: _remainingTime));
        _pausedDuration = null;
      } else {
        // Fresh start
        _remainingTime = _lunchDuration * 60;
        _clockOutTime = DateTime.now().add(Duration(minutes: _lunchDuration));
      }
      _isRunning = true;
      _showRefresher = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
          if (_remainingTime == 300) { // 5 minutes remaining
            _showNotification('5 minutes remaining!', 'Time to review your notes.');
            _showRefresher = true;
          }
        } else {
          _timer?.cancel();
          _isRunning = false;
          if (!_showRefresher) {
            _showNotification('Lunch Break Over!',
                'You didn\'t review your notes! Time to get back to work.');
          }
        }
      });
    });
  }

  // Show local notification with sound
  Future<void> _showNotification(String title, String body) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'lunch_timer_channel',
      'Lunch Timer Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentSound: true,
      sound: 'notification_sound.aiff',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // Add new note to the list
  void _addNote() {
    if (_notesController.text.isNotEmpty) {
      setState(() {
        _notes.add(LunchNote(text: _notesController.text));
        _notesController.clear();
      });
      _saveNotes();
    }
  }

  // Clear all notes
  void _clearAllNotes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notes'),
        content: const Text('Are you sure you want to delete all notes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _notes.clear();
              });
              _saveNotes();
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  // Toggle note completion status
  void _toggleNoteCompletion(int index) {
    setState(() {
      _notes[index].isCompleted = !_notes[index].isCompleted;
    });
    _saveNotes();
  }

  // Add this method to reorder notes
  void _reorderNote(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final LunchNote note = _notes.removeAt(oldIndex);
      _notes.insert(newIndex, note);
    });
    _saveNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lunch Timer'),
        centerTitle: true,
        actions: [
          if (_notes.isNotEmpty && _currentIndex == 1)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAllNotes,
              tooltip: 'Clear all notes',
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          TimerPage(
            remainingTime: _remainingTime,
            clockOutTime: _clockOutTime,
            isRunning: _isRunning,
            pauseTime: _pauseTime,
            lunchDuration: _lunchDuration,
            notesController: _notesController,
            notes: _notes,
            onStart: _startTimer,
            onStop: () {
              _timer?.cancel();
              setState(() {
                _isRunning = false;
                _showRefresher = false;
                _clockOutTime = null;
                _pauseTime = null;
                _pausedDuration = null;
              });
            },
            onPause: () {
              _timer?.cancel();
              setState(() {
                _pauseTime = DateTime.now();
                _isRunning = false;
              });
            },
            onDecrementDuration: () {
              setState(() {
                if (_lunchDuration > 15) {
                  _lunchDuration -= 5;
                }
              });
            },
            onIncrementDuration: () {
              setState(() {
                _lunchDuration += 5;
              });
            },
            onAddNote: _addNote,
            onToggleNoteCompletion: _toggleNoteCompletion,
          ),
          TasksPage(
            notesController: _notesController,
            notes: _notes,
            onAddNote: _addNote,
            onToggleNoteCompletion: _toggleNoteCompletion,
            onClearAllNotes: _clearAllNotes,
            onReorderNote: _reorderNote,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Timer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tasks',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notesController.dispose();
    super.dispose();
  }
}