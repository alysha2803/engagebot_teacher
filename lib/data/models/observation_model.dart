/// ObservationModel — a teacher-written note about a student.
class ObservationModel {
  final String id;
  final String category; // 'Academic' | 'Behavior' | etc.
  final String timestamp;
  final String text;

  const ObservationModel({
    required this.id,
    required this.category,
    required this.timestamp,
    required this.text,
  });

  factory ObservationModel.fromJson(Map<String, dynamic> json) =>
      ObservationModel(
        id: json['id'] as String,
        category: json['category'] as String,
        timestamp: json['timestamp'] as String,
        text: json['text'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'timestamp': timestamp,
        'text': text,
      };

  /// Returns a copy with updated fields.
  ObservationModel copyWith({
    String? id,
    String? category,
    String? timestamp,
    String? text,
  }) =>
      ObservationModel(
        id: id ?? this.id,
        category: category ?? this.category,
        timestamp: timestamp ?? this.timestamp,
        text: text ?? this.text,
      );
}
