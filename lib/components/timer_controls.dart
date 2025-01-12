import 'package:flutter/material.dart';

class TimerControls extends StatelessWidget {
  final bool isRunning;
  final DateTime? pauseTime;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onPause;
  final VoidCallback onDecrementDuration;
  final VoidCallback onIncrementDuration;
  final int lunchDuration;

  const TimerControls({
    required this.isRunning,
    this.pauseTime,
    required this.onStart,
    required this.onStop,
    required this.onPause,
    required this.onDecrementDuration,
    required this.onIncrementDuration,
    required this.lunchDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isRunning)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: onDecrementDuration,
              ),
              Text(
                '$lunchDuration min',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: onIncrementDuration,
              ),
            ],
          ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isRunning)
              IconButton(
                icon: const Icon(Icons.pause),
                iconSize: 36,
                onPressed: onPause,
              ),
            const SizedBox(width: 16),
            FilledButton.icon(
              icon: Icon(isRunning ? Icons.stop : Icons.play_arrow),
              label: Text(isRunning ? 'Stop' : pauseTime != null ? 'Resume' : 'Start'),
              onPressed: isRunning ? onStop : onStart,
            ),
          ],
        ),
      ],
    );
  }
} 