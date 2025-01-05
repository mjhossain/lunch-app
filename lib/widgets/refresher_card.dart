// lib/widgets/refresher_card.dart
import 'package:flutter/material.dart';

class RefresherCard extends StatelessWidget {
  final VoidCallback onReviewed;

  const RefresherCard({
    super.key,
    required this.onReviewed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Time for a Quick Review!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: onReviewed,
              child: const Text('Mark as Reviewed'),
            ),
          ],
        ),
      ),
    );
  }
}