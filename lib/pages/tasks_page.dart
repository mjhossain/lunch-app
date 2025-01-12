import 'package:flutter/material.dart';
import '../components/task_input.dart';
import '../models/lunch_note.dart';

class TasksPage extends StatelessWidget {
  final TextEditingController notesController;
  final List<LunchNote> notes;
  final VoidCallback onAddNote;
  final Function(int) onToggleNoteCompletion;
  final VoidCallback onClearAllNotes;
  final Function(int, int) onReorderNote;

  const TasksPage({
    required this.notesController,
    required this.notes,
    required this.onAddNote,
    required this.onToggleNoteCompletion,
    required this.onClearAllNotes,
    required this.onReorderNote,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                  TaskInput(
                    controller: notesController,
                    onAddNote: onAddNote,
                  ),
                  const SizedBox(height: 16),
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key(notes[index].text),
                        onDismissed: (direction) {
                          onToggleNoteCompletion(index);
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
                          key: ValueKey(notes[index]),
                          leading: Checkbox(
                            value: notes[index].isCompleted,
                            onChanged: (_) => onToggleNoteCompletion(index),
                          ),
                          title: Text(
                            notes[index].text,
                            style: TextStyle(
                              decoration: notes[index].isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      );
                    },
                    onReorder: onReorderNote,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 