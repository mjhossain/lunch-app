import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lunch_note.dart';
import '../widgets/neumorphic_fab.dart';
import '../widgets/add_note_dialog.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}



// Update the _NotesPageState class:
class _NotesPageState extends State<NotesPage> {
  List<LunchNote> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList('lunch_notes') ?? [];
    setState(() {
      _notes = notesJson
          .map((noteStr) => LunchNote.fromJson(json.decode(noteStr)))
          .toList();
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = _notes
        .map((note) => json.encode(note.toJson()))
        .toList();
    await prefs.setStringList('lunch_notes', notesJson);
  }

  List<LunchNote> get _todayNotes => _notes
      .where((note) => note.date.day == DateTime.now().day)
      .toList();

  List<LunchNote> get _tomorrowNotes => _notes
      .where((note) => note.date.day == DateTime.now().add(const Duration(days: 1)).day)
      .toList();

  void _addNote(String text, DateTime date) {
    setState(() {
      _notes.add(LunchNote(
        text: text,
        date: date,
      ));
    });
    _saveNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          // ... existing build method content ...
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: NeumorphicFAB(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddNoteDialog(
                  onAdd: _addNote,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}