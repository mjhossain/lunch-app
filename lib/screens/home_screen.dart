// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../models/lunch_note.dart';
import '../widgets/timer_display.dart';
import '../widgets/note_list.dart';
import '../widgets/refresher_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _notesController = TextEditingController();
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

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
    _loadSettings();
  }

  // Load saved settings from Firestore
  Future<void> _loadSettings() async {
    try {
      if (_currentUser != null) {
        final doc = await _firestore
            .collection('users')
            .doc(_currentUser?.uid)
            .collection('settings')
            .doc('timer')
            .get();

        if (doc.exists) {
          setState(() {
            _lunchDuration = doc.data()?['lunchDuration'] ?? 60;
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error loading settings: $e');
    }
  }

  // Save settings to Firestore
  Future<void> _saveSettings() async {
    try {
      if (_currentUser != null) {
        await _firestore
            .collection('users')
            .doc(_currentUser?.uid)
            .collection('settings')
            .doc('timer')
            .set({
          'lunchDuration': _lunchDuration,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error saving settings: $e');
    }
  }

  // Load notes from Firestore
  Future<void> _loadNotes() async {
    try {
      if (_currentUser != null) {
        final snapshot = await _firestore
            .collection('users')
            .doc(_currentUser?.uid)
            .collection('notes')
            .orderBy('timestamp', descending: true)
            .get();

        setState(() {
          _notes = snapshot.docs.map((doc) => LunchNote.fromFirestore(doc)).toList();
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error loading notes: $e');
    }
  }

  // Add note to Firestore
  Future<void> _addNote() async {
    if (_notesController.text.isEmpty) return;

    try {
      if (_currentUser != null) {
        final docRef = await _firestore
            .collection('users')
            .doc(_currentUser?.uid)
            .collection('notes')
            .add({
          'text': _notesController.text,
          'isCompleted': false,
          'timestamp': FieldValue.serverTimestamp(),
        });

        final note = LunchNote(
          id: docRef.id,
          text: _notesController.text,
          isCompleted: false,
        );

        setState(() {
          _notes.insert(0, note);
          _notesController.clear();
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error adding note: $e');
    }
  }

  // Toggle note completion status in Firestore
  Future<void> _toggleNoteCompletion(int index) async {
    try {
      if (_currentUser != null) {
        final note = _notes[index];
        await _firestore
            .collection('users')
            .doc(_currentUser?.uid)
            .collection('notes')
            .doc(note.id)
            .update({
          'isCompleted': !note.isCompleted,
        });

        setState(() {
          _notes[index].isCompleted = !note.isCompleted;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error updating note: $e');
    }
  }

  // Delete note from Firestore
  Future<void> _deleteNote(int index) async {
    try {
      if (_currentUser != null) {
        final note = _notes[index];
        await _firestore
            .collection('users')
            .doc(_currentUser?.uid)
            .collection('notes')
            .doc(note.id)
            .delete();

        setState(() {
          _notes.removeAt(index);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error deleting note: $e');
    }
  }

  // Clear all notes from Firestore
  Future<void> _clearAllNotes() async {
    try {
      if (_currentUser != null) {
        final batch = _firestore.batch();
        final snapshots = await _firestore
            .collection('users')
            .doc(_currentUser?.uid)
            .collection('notes')
            .get();

        for (var doc in snapshots.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
        setState(() => _notes.clear());
      }
    } catch (e) {
      _showErrorSnackBar('Error clearing notes: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
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
          if (_remainingTime == 300) { // 5 minutes remaining
            _notificationService.showNotification(
              title: '5 minutes remaining!',
              body: 'Time to review your notes.',
            );
            _showRefresher = true;
          }
        } else {
          _timer?.cancel();
          _isRunning = false;
          if (!_showRefresher) {
            _notificationService.showNotification(
              title: 'Lunch Break Over!',
              body: 'You didn\'t review your notes! Time to get back to work.',
            );
          }
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _showRefresher = false;
      _clockOutTime = null;
    });
  }

  void _updateDuration(int newDuration) {
    setState(() {
      _lunchDuration = newDuration;
    });
    _saveSettings();
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
              onPressed: () {
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
                          _clearAllNotes();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Clear all notes',
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _authService.signOut(),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TimerDisplay(
              remainingTime: _remainingTime,
              clockOutTime: _clockOutTime,
              isRunning: _isRunning,
              lunchDuration: _lunchDuration,
              onStart: _startTimer,
              onStop: _stopTimer,
              onDurationChanged: _updateDuration,
            ),
            const SizedBox(height: 16),
            if (_showRefresher)
              RefresherCard(
                onReviewed: () {
                  setState(() => _showRefresher = false);
                  _notificationService.showNotification(
                    title: 'Notes Reviewed!',
                    body: 'Enjoy the rest of your break!',
                  );
                },
              ),
            const SizedBox(height: 16),
            NoteList(
              notes: _notes,
              onDelete: _deleteNote,
              onToggle: _toggleNoteCompletion,
              controller: _notesController,
              onAdd: _addNote,
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