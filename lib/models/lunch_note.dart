class LunchNote {
  String text;
  bool isCompleted;

  LunchNote({
    required this.text,
    this.isCompleted = false,
  });

  factory LunchNote.fromJson(Map<String, dynamic> json) {
    return LunchNote(
      text: json['text'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isCompleted': isCompleted,
    };
  }
} 