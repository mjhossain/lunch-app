import 'package:flutter/material.dart';

class TaskInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAddNote;

  const TaskInput({
    required this.controller,
    required this.onAddNote,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Add a task',
        suffixIcon: IconButton(
          icon: const Icon(Icons.add),
          onPressed: onAddNote,
        ),
      ),
      onSubmitted: (value) => onAddNote(),
    );
  }
} 