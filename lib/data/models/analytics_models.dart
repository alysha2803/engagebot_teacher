// Models for class analytics, behaviour analysis, session history, and teaching tips.
// TODO: Replace all mock instances with droid API responses.

// ─────────────────────────────────────────────────────────────────────────────
// Behaviour Analysis (UC-6.2)
// ─────────────────────────────────────────────────────────────────────────────

/// Per-student behaviour summary for a single class session.
class StudentBehaviourRecord {
  final String studentId;
  final String studentName;
  final int engagementScore;    // 0–100
  final int attentionMinutes;   // cumulative on-task minutes this session
  final int offTaskCount;       // droid-detected off-task events
  final String dominantStatus;  // 'engaged' | 'distracted' | 'flagged'

  const StudentBehaviourRecord({
    required this.studentId,
    required this.studentName,
    required this.engagementScore,
    required this.attentionMinutes,
    required this.offTaskCount,
    required this.dominantStatus,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Historical Data (UC-6.4)
// ─────────────────────────────────────────────────────────────────────────────

/// Summary of a single past teaching session.
class SessionRecord {
  final String date;           // e.g., "Mon, 2 Jun 2025"
  final String classCode;
  final String subject;
  final int avgEngagement;     // 0–100
  final int durationMinutes;
  final int studentCount;
  final int flaggedCount;
  final String highlight;      // e.g., "Strong focus in first 20 min"

  const SessionRecord({
    required this.date,
    required this.classCode,
    required this.subject,
    required this.avgEngagement,
    required this.durationMinutes,
    required this.studentCount,
    required this.flaggedCount,
    required this.highlight,
  });
}

/// A single day's engagement data point for the weekly trend chart.
class WeeklyDataPoint {
  final String dayLabel;  // 'Mon', 'Tue', etc.
  final int engagement;   // 0–100

  const WeeklyDataPoint({required this.dayLabel, required this.engagement});
}

// ─────────────────────────────────────────────────────────────────────────────
// Teaching Recommendations (UC-8)
// ─────────────────────────────────────────────────────────────────────────────

/// AI-generated teaching strategy recommendation.
class TeachingRecommendation {
  final String id;
  final String category;   // 'Engagement' | 'Behaviour' | 'Strategy' | 'Attention'
  final String title;
  final String description;
  final String priority;   // 'high' | 'medium' | 'low'
  bool isApplied;

  TeachingRecommendation({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.priority,
    this.isApplied = false,
  });
}
