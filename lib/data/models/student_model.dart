/// StudentModel — represents a student in the class roster.
class StudentModel {
  final String id;
  final String name;
  final String status; // 'engaged' | 'distracted' | 'flagged'
  final String? avatarUrl;

  const StudentModel({
    required this.id,
    required this.name,
    required this.status,
    this.avatarUrl,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        id: json['id'] as String? ?? json['name'] as String,
        name: json['name'] as String,
        status: json['status'] as String,
        avatarUrl: json['avatarUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status,
        'avatarUrl': avatarUrl,
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
