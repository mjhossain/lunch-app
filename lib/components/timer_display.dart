import 'package:flutter/material.dart';

class TimerDisplay extends StatelessWidget {
  final int remainingTime;
  final DateTime? clockOutTime;
  final bool isRunning;

  const TimerDisplay({
    required this.remainingTime,
    this.clockOutTime,
    required this.isRunning,
  });

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formatTime(remainingTime),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 56,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (clockOutTime != null && isRunning)
          Column(
            children: [
              Text(
                'Clock out at:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                '${clockOutTime!.hour.toString().padLeft(2, '0')}:${clockOutTime!.minute.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Reminder at: ${clockOutTime!.subtract(const Duration(minutes: 5)).hour.toString().padLeft(2, '0')}:${clockOutTime!.subtract(const Duration(minutes: 5)).minute.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
      ],
    );
  }
} 