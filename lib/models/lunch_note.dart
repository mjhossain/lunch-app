class LunchNote {
  String id;
  String text;
  bool isCompleted;
  DateTime date;

  LunchNote({
    required this.text,
    this.isCompleted = false,
    required this.date,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isCompleted': isCompleted,
    'date': date.toIso8601String(),
  };

  factory LunchNote.fromJson(Map<String, dynamic> json) => LunchNote(
    text: json['text'] as String,
    isCompleted: json['isCompleted'] as bool,
    date: DateTime.parse(json['date'] as String),
  )..id = json['id'] as String;
}