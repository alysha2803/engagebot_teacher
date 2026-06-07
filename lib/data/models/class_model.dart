/// ClassModel — represents one teacher's class period.
class ClassModel {
  final String code;
  final String subject;
  final int studentCount;
  final String status; // 'online' | 'offline'

  const ClassModel({
    required this.code,
    required this.subject,
    required this.studentCount,
    required this.status,
  });

  bool get isOnline => status == 'online';

  factory ClassModel.fromJson(Map<String, dynamic> json) => ClassModel(
        code: json['code'] as String,
        subject: json['subject'] as String,
        studentCount: json['students'] as int,
        status: json['status'] as String,
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'subject': subject,
        'students': studentCount,
        'status': status,
      };
}
