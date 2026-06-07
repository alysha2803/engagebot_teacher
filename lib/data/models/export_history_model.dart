/// ExportHistoryModel — a past export entry shown in the Reports screen.
class ExportHistoryModel {
  final String type; // 'PDF' | 'CSV'
  final String name;
  final String date;
  final String size;

  const ExportHistoryModel({
    required this.type,
    required this.name,
    required this.date,
    required this.size,
  });

  factory ExportHistoryModel.fromJson(Map<String, dynamic> json) =>
      ExportHistoryModel(
        type: json['type'] as String,
        name: json['name'] as String,
        date: json['date'] as String,
        size: json['size'] as String,
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'name': name,
        'date': date,
        'size': size,
      };
}
