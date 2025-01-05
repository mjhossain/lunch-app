// lib/widgets/timer_display.dart
import 'package:flutter/material.dart';

class TimerDisplay extends StatelessWidget {
  final int remainingTime;
  final DateTime? clockOutTime;
  final bool isRunning;
  final int lunchDuration;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final Function(int) onDurationChanged;

  const TimerDisplay({
    super.key,
    required this.remainingTime,
    this.clockOutTime,
    required this.isRunning,
    required this.lunchDuration,
    required this.onStart,
    required this.onStop,
    required this.onDurationChanged,
  });

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _formatTime(remainingTime),
              style: Theme.of(context).textTheme.displayLarge,
            ),
            if (clockOutTime != null && isRunning)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Clock out at: ${clockOutTime!.hour.toString().padLeft(2, '0')}:${clockOutTime!.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            const SizedBox(height: 16),
            if (!isRunning)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (lunchDuration > 15) {
                        onDurationChanged(lunchDuration - 5);
                      }
                    },
                  ),
                  Text(
                    '$lunchDuration min',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => onDurationChanged(lunchDuration + 5),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: Icon(isRunning ? Icons.stop : Icons.play_arrow),
              label: Text(isRunning ? 'Stop' : 'Start Lunch Break'),
              onPressed: isRunning ? onStop : onStart,
            ),
          ],
        ),
      ),
    );
  }
}