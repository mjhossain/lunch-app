// lib/models/lunch_note.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class LunchNote {
  final String id;
  final String text;
  bool isCompleted;
  final DateTime timestamp;

  LunchNote({
    required this.id,
    required this.text,
    this.isCompleted = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Create from Firestore document
  factory LunchNote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LunchNote(
      id: doc.id,
      text: data['text'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isCompleted': isCompleted,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Create copy with changes
  LunchNote copyWith({
    String? id,
    String? text,
    bool? isCompleted,
    DateTime? timestamp,
  }) {
    return LunchNote(
      id: id ?? this.id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}