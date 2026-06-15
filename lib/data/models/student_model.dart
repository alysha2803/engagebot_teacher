/// StudentModel — represents a student in the class roster.
class StudentModel {
  final String id;
  final String name;
  final String status; // 'engaged' | 'distracted' | 'flagged'
  final String? avatarUrl;
  final String? statusNote; // optional teacher note attached to a status change
  final String? classCode;  // set when loading all students in one query

  const StudentModel({
    required this.id,
    required this.name,
    required this.status,
    this.avatarUrl,
    this.statusNote,
    this.classCode,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        id: json['id'] as String? ?? json['name'] as String,
        name: json['name'] as String,
        status: json['status'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        statusNote: json['statusNote'] as String?,
        classCode: json['classCode'] as String?,
      );

  StudentModel copyWith({
    String? id,
    String? name,
    String? status,
    String? avatarUrl,
    String? statusNote,
    String? classCode,
  }) =>
      StudentModel(
        id: id ?? this.id,
        name: name ?? this.name,
        status: status ?? this.status,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        statusNote: statusNote ?? this.statusNote,
        classCode: classCode ?? this.classCode,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status,
        'avatarUrl': avatarUrl,
        'statusNote': statusNote,
        'classCode': classCode,
      };
}

/// EngagementPoint — a single data point on the timeline chart.
class EngagementPoint {
  final String timeLabel;
  final double value;

  const EngagementPoint({required this.timeLabel, required this.value});

  factory EngagementPoint.fromJson(Map<String, dynamic> json) =>
      EngagementPoint(
        timeLabel: json['time'] as String,
        value: (json['value'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {'time': timeLabel, 'value': value};
}

/// StudentProfile — detailed engagement data for a single student.
class StudentProfile {
  final String id;
  final String name;
  final String className;
  final String subject;
  final String engagementLabel;
  final int avgEngagement;
  final int flags;
  final int focusDepth;
  final int collaboration;
  final String droidInsight;
  final List<EngagementPoint> timeline;

  const StudentProfile({
    required this.id,
    required this.name,
    required this.className,
    required this.subject,
    required this.engagementLabel,
    required this.avgEngagement,
    required this.flags,
    required this.focusDepth,
    required this.collaboration,
    required this.droidInsight,
    required this.timeline,
  });

  StudentProfile copyWith({
    String? id,
    String? name,
    String? className,
    String? subject,
    String? engagementLabel,
    int? avgEngagement,
    int? flags,
    int? focusDepth,
    int? collaboration,
    String? droidInsight,
    List<EngagementPoint>? timeline,
  }) =>
      StudentProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        className: className ?? this.className,
        subject: subject ?? this.subject,
        engagementLabel: engagementLabel ?? this.engagementLabel,
        avgEngagement: avgEngagement ?? this.avgEngagement,
        flags: flags ?? this.flags,
        focusDepth: focusDepth ?? this.focusDepth,
        collaboration: collaboration ?? this.collaboration,
        droidInsight: droidInsight ?? this.droidInsight,
        timeline: timeline ?? this.timeline,
      );

  factory StudentProfile.fromJson(Map<String, dynamic> json) => StudentProfile(
        id: json['id'] as String? ?? json['name'] as String,
        name: json['name'] as String,
        className: json['class'] as String,
        subject: json['subject'] as String,
        engagementLabel: json['engagementLabel'] as String,
        avgEngagement: json['avgEngagement'] as int,
        flags: json['flags'] as int,
        focusDepth: json['focusDepth'] as int,
        collaboration: json['collaboration'] as int,
        droidInsight: json['droidInsight'] as String,
        timeline: (json['timeline'] as List)
            .map((e) => EngagementPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'class': className,
        'subject': subject,
        'engagementLabel': engagementLabel,
        'avgEngagement': avgEngagement,
        'flags': flags,
        'focusDepth': focusDepth,
        'collaboration': collaboration,
        'droidInsight': droidInsight,
        'timeline': timeline.map((e) => e.toJson()).toList(),
      };
}
