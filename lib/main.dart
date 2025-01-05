// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// Entry point of the application
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize notification services
  await initNotifications();
  runApp(const LunchTimerApp());
}

// Initialize local notifications plugin with platform-specific settings
Future<void> initNotifications() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS =
  DarwinInitializationSettings();
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

// Root widget of the application
class LunchTimerApp extends StatelessWidget {
  const LunchTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lunch Timer',
      // Configure light theme with Material 3
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      // Configure dark theme with Material 3
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}

// Data model for lunch notes
class LunchNote {
  String text;
  bool isCompleted;

  LunchNote({
    required this.text,
    this.isCompleted = false,
  });

  // Convert note to JSON for storage
  Map<String, dynamic> toJson() => {
    'text': text,
    'isCompleted': isCompleted,
  };

  // Create note from JSON storage
  factory LunchNote.fromJson(Map<String, dynamic> json) => LunchNote(
    text: json['text'],
    isCompleted: json['isCompleted'],
  );
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

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // Load saved notes from persistent storage
  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList('lunch_notes') ?? [];
    setState(() {
      _notes = notesJson
          .map((note) => LunchNote.fromJson(Map<String, dynamic>.from(
          Map<String, dynamic>.from({}))))
          .toList();
    });
  }

  // Save notes to persistent storage
  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = _notes.map((note) => note.toJson().toString()).toList();
    await prefs.setStringList('lunch_notes', notesJson);
  }

  // Start lunch break timer
  void _startTimer() {
    _remainingTime = _lunchDuration * 60;
    setState(() {
      _isRunning = true;
      _showRefresher = false;
      // Calculate clock out time
      _clockOutTime = DateTime.now().add(Duration(minutes: _lunchDuration));
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

  // Format seconds into MM:SS
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Format clock out time
  String _formatClockOutTime() {
    if (_clockOutTime == null) return '';
    return 'Clock out at: ${_clockOutTime!.hour.toString().padLeft(2, '0')}:${_clockOutTime!.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lunch Timer'),
        centerTitle: true,
        actions: [
          if (_notes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAllNotes,
              tooltip: 'Clear all notes',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timer Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      _formatTime(_remainingTime),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    if (_clockOutTime != null && _isRunning)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _formatClockOutTime(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (!_isRunning)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (_lunchDuration > 15) {
                                  _lunchDuration -= 5;
                                }
                              });
                            },
                          ),
                          Text(
                            '$_lunchDuration min',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                _lunchDuration += 5;
                              });
                            },
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                      label: Text(_isRunning ? 'Stop' : 'Start Lunch Break'),
                      onPressed: _isRunning ? () {
                        _timer?.cancel();
                        setState(() {
                          _isRunning = false;
                          _showRefresher = false;
                          _clockOutTime = null;
                        });
                      } : _startTimer,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Refresher Card
            if (_showRefresher)
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Time for a Quick Review!',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            _showRefresher = false;
                          });
                          _showNotification('Notes Reviewed!',
                              'Enjoy the rest of your break!');
                        },
                        child: const Text('Mark as Reviewed'),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Notes Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Lunch Notes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: 'Add a note...',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addNote,
                        ),
                      ),
                      onSubmitted: (_) => _addNote(),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: Key(_notes[index].text),
                          onDismissed: (direction) {
                            setState(() {
                              _notes.removeAt(index);
                            });
                            _saveNotes();
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              value: _notes[index].isCompleted,
                              onChanged: (_) => _toggleNoteCompletion(index),
                            ),
                            title: Text(
                              _notes[index].text,
                              style: TextStyle(
                                decoration: _notes[index].isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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