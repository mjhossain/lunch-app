// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

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
          // Timer Screen
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Timer Container
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Timer Display
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatTime(_remainingTime),
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_clockOutTime != null && _isRunning)
                            Column(
                              children: [
                                Text(
                                  'Clock out at:',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                Text(
                                  '${_clockOutTime!.hour.toString().padLeft(2, '0')}:${_clockOutTime!.minute.toString().padLeft(2, '0')}',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Reminder at: ${_clockOutTime!.subtract(const Duration(minutes: 5)).hour.toString().padLeft(2, '0')}:${_clockOutTime!.subtract(const Duration(minutes: 5)).minute.toString().padLeft(2, '0')}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Timer Controls
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
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isRunning)
                            IconButton(
                              icon: const Icon(Icons.pause),
                              iconSize: 36,
                              onPressed: () {
                                _timer?.cancel();
                                setState(() {
                                  _pauseTime = DateTime.now();
                                  _isRunning = false;
                                });
                              },
                            ),
                          const SizedBox(width: 16),
                          FilledButton.icon(
                            icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                            label: Text(_isRunning ? 'Stop' : _pauseTime != null ? 'Resume' : 'Start'),
                            onPressed: _isRunning ? () {
                              _timer?.cancel();
                              setState(() {
                                _isRunning = false;
                                _showRefresher = false;
                                _clockOutTime = null;
                                _pauseTime = null;
                                _pausedDuration = null;
                              });
                            } : () {
                              if (_pauseTime != null) {
                                // Calculate paused duration
                                _pausedDuration = DateTime.now().difference(_pauseTime!);
                                // Adjust clock out time
                                _clockOutTime = _clockOutTime!.add(_pausedDuration!);
                              }
                              _startTimer();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Add Task Section
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Add a task',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addNote,
                          ),
                        ),
                        onSubmitted: (value) => _addNote(),
                      ),
                      const SizedBox(height: 16),
                      // Show top 3 tasks
                      if (_notes.isNotEmpty)
                        Column(
                          children: _notes.take(3).map((note) => ListTile(
                            leading: Checkbox(
                              value: note.isCompleted,
                              onChanged: (value) {
                                _toggleNoteCompletion(_notes.indexOf(note));
                              },
                            ),
                            title: Text(
                              note.text,
                              style: note.isCompleted
                                  ? TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              )
                                  : null,
                            ),
                          )).toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tasks Screen
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                        ReorderableListView.builder(
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
                                key: ValueKey(_notes[index]),
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
                          onReorder: _reorderNote,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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