
// home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notifications.dart';
import 'login_page.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _notesController = TextEditingController();
  Timer? _timer;
  int _lunchDuration = 60;
  int _remainingTime = 0;
  List<LunchNote> _notes = [];
  bool _isRunning = false;
  bool _showRefresher = false;
  DateTime? _clockOutTime;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .get();
      setState(() {
        _notes = snapshot.docs
            .map((doc) => LunchNote.fromJson(doc.data()))
            .toList();
      });
    }
  }

  Future<void> _saveNotes() async {
    final user = _auth.currentUser;
    if (user != null) {
      final batch = _firestore.batch();
      final notesCollection = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes');

      for (var note in _notes) {
        final docRef = notesCollection.doc(note.text);
        batch.set(docRef, note.toJson());
      }
      await batch.commit();
    }
  }

  void _startTimer() {
    _remainingTime = _lunchDuration * 60;
    setState(() {
      _isRunning = true;
      _showRefresher = false;
      _clockOutTime = DateTime.now().add(Duration(minutes: _lunchDuration));
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
          if (_remainingTime == 300) {
            showNotification('5 minutes remaining!', 'Time to review your notes.');
            _showRefresher = true;
          }
        } else {
          _timer?.cancel();
          _isRunning = false;
          if (!_showRefresher) {
            showNotification('Lunch Break Over!',
                'You didn\'t review your notes! Time to get back to work.');
          }
        }
      });
    });
  }

  void _addNote() {
    if (_notesController.text.isNotEmpty) {
      setState(() {
        _notes.add(LunchNote(text: _notesController.text));
        _notesController.clear();
      });
      _saveNotes();
    }
  }

  void _clearAllNotes() {
    setState(() {
      _notes.clear();
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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      _remainingTime > 0
                          ? '${_remainingTime ~/ 60}:${_remainingTime % 60}'
                          : '00:00',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isRunning ? null : _startTimer,
                      child: const Text('Start Lunch Break'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        hintText: 'Add a note...',
                      ),
                      onSubmitted: (_) => _addNote(),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Checkbox(
                            value: _notes[index].isCompleted,
                            onChanged: (value) {
                              setState(() {
                                _notes[index].isCompleted = value ?? false;
                              });
                              _saveNotes();
                            },
                          ),
                          title: Text(_notes[index].text),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _notes.removeAt(index);
                              });
                              _saveNotes();
                            },
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

class LunchNote {
  String text;
  bool isCompleted;

  LunchNote({
    required this.text,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'isCompleted': isCompleted,
  };

  factory LunchNote.fromJson(Map<String, dynamic> json) =>
      LunchNote(
        text: json['text'],
        isCompleted: json['isCompleted'],
      );
}
