// lib/widgets/note_list.dart
import 'package:flutter/material.dart';
import '../models/lunch_note.dart';

class NoteList extends StatelessWidget {
  final List<LunchNote> notes;
  final Function(int) onDelete;
  final Function(int) onToggle;
  final TextEditingController controller;
  final VoidCallback onAdd;

  const NoteList({
    super.key,
    required this.notes,
    required this.onDelete,
    required this.onToggle,
    required this.controller,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Add a note...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: onAdd,
                ),
              ),
              onSubmitted: (_) => onAdd(),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Dismissible(
                  key: Key(note.id),
                  onDismissed: (_) => onDelete(index),
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
                      value: note.isCompleted,
                      onChanged: (_) => onToggle(index),
                    ),
                    title: Text(
                      note.text,
                      style: TextStyle(
                        decoration: note.isCompleted
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
    );
  }
}