import 'package:flutter/material.dart';
import '../models/lunch_note.dart';

class TaskList extends StatelessWidget {
  final List<LunchNote> notes;
  final Function(int) onToggleNoteCompletion;

  const TaskList({
    required this.notes,
    required this.onToggleNoteCompletion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: notes.take(3).map((note) => ListTile(
        leading: Checkbox(
          value: note.isCompleted,
          onChanged: (value) {
            onToggleNoteCompletion(notes.indexOf(note));
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
    );
  }
} 