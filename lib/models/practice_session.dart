class PracticeSession {
  final String pieceName;
  final String notes;
  final int durationSeconds;
  final DateTime date;

  PracticeSession({
    required this.pieceName,
    required this.notes,
    required this.durationSeconds,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'pieceName': pieceName,
      'notes': notes,
      'durationSeconds': durationSeconds,
      'date': date.toIso8601String(),
    };
  }

  factory PracticeSession.fromJson(Map<String, dynamic> json) {
    return PracticeSession(
      pieceName: json['pieceName'] ?? '',
      notes: json['notes'] ?? '',
      durationSeconds: json['durationSeconds'] ?? 0,
      date: DateTime.parse(json['date']),
    );
  }

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

