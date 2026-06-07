/// TeacherProfileModel — the logged-in teacher's data.
class TeacherProfileModel {
  final String name;
  final String school;
  final String subject;
  final String avatarUrl;

  const TeacherProfileModel({
    required this.name,
    required this.school,
    required this.subject,
    required this.avatarUrl,
  });

  factory TeacherProfileModel.fromJson(Map<String, dynamic> json) =>
      TeacherProfileModel(
        name: json['name'] as String,
        school: json['school'] as String,
        subject: json['subject'] as String,
        avatarUrl: json['avatarUrl'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'school': school,
        'subject': subject,
        'avatarUrl': avatarUrl,
      };
}
