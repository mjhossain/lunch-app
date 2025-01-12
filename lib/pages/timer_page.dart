import 'package:flutter/material.dart';
import 'package:lunch/models/lunch_note.dart';
import '../components/timer_display.dart';
import '../components/timer_controls.dart';
import '../components/task_input.dart';
import '../components/task_list.dart';

class TimerPage extends StatelessWidget {
  final int remainingTime;
  final DateTime? clockOutTime;
  final bool isRunning;
  final DateTime? pauseTime;
  final int lunchDuration;
  final TextEditingController notesController;
  final List<LunchNote> notes;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onPause;
  final VoidCallback onDecrementDuration;
  final VoidCallback onIncrementDuration;
  final VoidCallback onAddNote;
  final Function(int) onToggleNoteCompletion;

  const TimerPage({
    required this.remainingTime,
    this.clockOutTime,
    required this.isRunning,
    this.pauseTime,
    required this.lunchDuration,
    required this.notesController,
    required this.notes,
    required this.onStart,
    required this.onStop,
    required this.onPause,
    required this.onDecrementDuration,
    required this.onIncrementDuration,
    required this.onAddNote,
    required this.onToggleNoteCompletion,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                TimerDisplay(
                  remainingTime: remainingTime,
                  clockOutTime: clockOutTime,
                  isRunning: isRunning,
                ),
                const SizedBox(height: 32),
                TimerControls(
                  isRunning: isRunning,
                  pauseTime: pauseTime,
                  onStart: onStart,
                  onStop: onStop,
                  onPause: onPause,
                  onDecrementDuration: onDecrementDuration,
                  onIncrementDuration: onIncrementDuration,
                  lunchDuration: lunchDuration,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
                TaskInput(
                  controller: notesController,
                  onAddNote: onAddNote,
                ),
                const SizedBox(height: 16),
                if (notes.isNotEmpty)
                  TaskList(
                    notes: notes,
                    onToggleNoteCompletion: onToggleNoteCompletion,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 