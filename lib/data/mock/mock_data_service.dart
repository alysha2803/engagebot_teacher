import '../models/analytics_models.dart';
import '../models/class_model.dart';
import '../models/student_model.dart';
import '../models/observation_model.dart';
import '../models/export_history_model.dart';
import '../models/teacher_profile_model.dart';

/// MockDataService — single source of truth for all placeholder data.
///
/// Every method is marked with a TODO so real API calls can be swapped in
/// when the droid backend is ready.
abstract final class MockDataService {
  // ---------------------------------------------------------------------------
  // Live engagement
  // ---------------------------------------------------------------------------

  // TODO: Replace with droid API call
  static Map<String, dynamic> getLiveEngagement() => {
        'percentage': 82,
        'trend': '+4%',
        'sessionMinutes': 42,
        'droidStatus': 'ENGAGED',
      };

  // ---------------------------------------------------------------------------
  // AI recommendation
  // ---------------------------------------------------------------------------

  // TODO: Replace with droid API call
  static Map<String, dynamic> getAIRecommendation() => {
        'text':
            'Engagement is dipping in the back rows. Try a quick breakout group to boost energy.',
        'highlightWord': 'breakout group',
        'action': 'Apply Strategy',
      };

  // ---------------------------------------------------------------------------
  // Class list
  // ---------------------------------------------------------------------------

  static List<ClassModel> getClasses() => [
        ClassModel.fromJson(
            {'code': '1 USAHA', 'subject': 'Mathematics', 'students': 28, 'status': 'online'}),
        ClassModel.fromJson(
            {'code': '2 JUJUR', 'subject': 'Mathematics', 'students': 30, 'status': 'online'}),
        ClassModel.fromJson(
            {'code': '3 TEKUN', 'subject': 'Mathematics', 'students': 32, 'status': 'online'}),
        ClassModel.fromJson(
            {'code': '4 GIGIH', 'subject': 'Add Maths', 'students': 24, 'status': 'offline'}),
        ClassModel.fromJson(
            {'code': '5 CEKAL', 'subject': 'Add Maths', 'students': 30, 'status': 'online'}),
      ];

  // ---------------------------------------------------------------------------
  // Per-class rosters
  // ---------------------------------------------------------------------------

  static final Map<String, List<Map<String, dynamic>>> _classRosterData = {
    '1 USAHA': [
      {'id': 'ahmad', 'name': 'Ahmad', 'status': 'engaged'},
      {'id': 'aina', 'name': 'Aina', 'status': 'engaged'},
      {'id': 'hamid', 'name': 'Hamid', 'status': 'engaged'},
      {'id': 'maya', 'name': 'Maya', 'status': 'distracted'},
      {'id': 'badrul', 'name': 'Badrul', 'status': 'engaged'},
      {'id': 'hani', 'name': 'Hani', 'status': 'engaged'},
    ],
    '2 JUJUR': [
      {'id': 'haziq', 'name': 'Haziq', 'status': 'engaged'},
      {'id': 'aishah', 'name': 'Aishah', 'status': 'distracted'},
      {'id': 'rahman', 'name': 'Rahman', 'status': 'engaged'},
      {'id': 'suria', 'name': 'Suria', 'status': 'flagged'},
      {'id': 'jeffri', 'name': 'Jeffri', 'status': 'engaged'},
      {'id': 'nadia', 'name': 'Nadia', 'status': 'engaged'},
    ],
    '3 TEKUN': [
      {'id': 'ali_zain', 'name': 'Ali Zain', 'status': 'engaged'},
      {'id': 'sarah_m', 'name': 'Sarah', 'status': 'engaged'},
      {'id': 'amir_k', 'name': 'Amir', 'status': 'distracted'},
      {'id': 'fatimah_bt', 'name': 'Fatimah', 'status': 'engaged'},
      {'id': 'hafiz_r', 'name': 'Hafiz', 'status': 'engaged'},
      {'id': 'nurul_f', 'name': 'Nurul', 'status': 'engaged'},
    ],
    '4 GIGIH': [
      {'id': 'farid', 'name': 'Farid', 'status': 'engaged'},
      {'id': 'lina', 'name': 'Lina', 'status': 'engaged'},
      {'id': 'karim', 'name': 'Karim', 'status': 'distracted'},
      {'id': 'zara', 'name': 'Zara', 'status': 'engaged'},
      {'id': 'dani', 'name': 'Dani', 'status': 'flagged'},
      {'id': 'sofea', 'name': 'Sofea', 'status': 'engaged'},
    ],
    '5 CEKAL': [
      {'id': 'azri', 'name': 'Azri', 'status': 'engaged'},
      {'id': 'izzati', 'name': 'Izzati', 'status': 'engaged'},
      {'id': 'ridzuan', 'name': 'Ridzuan', 'status': 'distracted'},
      {'id': 'farhana', 'name': 'Farhana', 'status': 'engaged'},
      {'id': 'lutfi', 'name': 'Lutfi', 'status': 'engaged'},
      {'id': 'shira', 'name': 'Shira', 'status': 'engaged'},
    ],
  };

  // TODO: Replace with droid live roster API
  static List<StudentModel> getRoster() =>
      getRosterForClass('1 USAHA');

  static List<StudentModel> getRosterForClass(String classCode) {
    final data = _classRosterData[classCode] ?? _classRosterData['1 USAHA']!;
    return data.map((d) => StudentModel.fromJson(d)).toList();
  }

  /// Returns every class alongside its base roster — used by the Students tab.
  static List<MapEntry<String, List<StudentModel>>> getAllClassRosters() =>
      _classRosterData.entries
          .map((e) => MapEntry(
                e.key,
                e.value.map((d) => StudentModel.fromJson(d)).toList(),
              ))
          .toList();

  // ---------------------------------------------------------------------------
  // Student profile
  // ---------------------------------------------------------------------------

  // TODO: Replace with droid student engagement API
  static StudentProfile getStudentProfile(String studentId) {
    for (final entry in _classRosterData.entries) {
      final match = entry.value.where((s) => s['id'] == studentId).toList();
      if (match.isNotEmpty) {
        final name = match.first['name'] as String;
        final classCode = entry.key;
        final subject = (classCode == '4 GIGIH' || classCode == '5 CEKAL')
            ? 'Add Maths'
            : 'Mathematics';
        return _buildStudentProfile(studentId, name, classCode, subject);
      }
    }
    return _buildStudentProfile(studentId, 'Unknown', '1 USAHA', 'Mathematics');
  }

  static StudentProfile _buildStudentProfile(
      String id, String name, String className, String subject) {
    return StudentProfile.fromJson({
      'id': id,
      'name': name,
      'class': className,
      'subject': subject,
      'engagementLabel': 'High Engaged',
      'avgEngagement': 88,
      'flags': 2,
      'focusDepth': 92,
      'collaboration': 45,
      'droidInsight':
          "$name's engagement dropped by 30% during independent reading. Try initiating a 1-on-1 concept check to re-focus.",
      'timeline': [
        {'time': '09:00', 'value': 70.0},
        {'time': '09:15', 'value': 80.0},
        {'time': '09:30', 'value': 75.0},
        {'time': '09:45', 'value': 60.0},
        {'time': '10:00', 'value': 72.0},
        {'time': '10:15', 'value': 78.0},
      ],
    });
  }

  // ---------------------------------------------------------------------------
  // Class-specific engagement (for Class Analytics screen)
  // ---------------------------------------------------------------------------

  // TODO: Replace with per-class droid API call
  static Map<String, dynamic> getClassEngagement(String classCode) {
    const data = {
      '1 USAHA': {'percentage': 82, 'trend': '+4%', 'sessionMinutes': 42},
      '2 JUJUR': {'percentage': 75, 'trend': '+2%', 'sessionMinutes': 38},
      '3 TEKUN': {'percentage': 90, 'trend': '+12%', 'sessionMinutes': 51},
      '4 GIGIH': {'percentage': 68, 'trend': '-3%', 'sessionMinutes': 30},
      '5 CEKAL': {'percentage': 85, 'trend': '+6%', 'sessionMinutes': 45},
    };
    return data[classCode] ?? {'percentage': 80, 'trend': '+0%', 'sessionMinutes': 40};
  }

  // ---------------------------------------------------------------------------
  // Teacher observations (editable in-state)
  // ---------------------------------------------------------------------------

  static List<ObservationModel> getObservations() => [
        ObservationModel.fromJson({
          'id': 'o1',
          'category': 'Academic',
          'timestamp': 'Today, 10:15 AM',
          'text':
              'Struggled with the stoichiometry equations initially but caught up after Ali paired with Sarah for the lab work.',
        }),
        ObservationModel.fromJson({
          'id': 'o2',
          'category': 'Behavior',
          'timestamp': 'Oct 24, 2023',
          'text':
              'Shows great enthusiasm during class discussions. Needs to work on staying on task during silent reading periods.',
        }),
      ];

  // ---------------------------------------------------------------------------
  // Export history
  // ---------------------------------------------------------------------------

  // TODO: Replace with export history API
  static List<ExportHistoryModel> getExportHistory() => [
        ExportHistoryModel.fromJson(
            {'type': 'PDF', 'name': 'AddMaths_4GIGIH_Weekly_', 'date': 'Oct 19, 2023', 'size': '2.4 MB'}),
        ExportHistoryModel.fromJson(
            {'type': 'CSV', 'name': 'Engagement_Raw_Data_Oct', 'date': 'Oct 12, 2023', 'size': '452 KB'}),
        ExportHistoryModel.fromJson(
            {'type': 'PDF', 'name': 'Monthly_Teaching_Insights', 'date': 'Sep 30, 2023', 'size': '5.1 MB'}),
        ExportHistoryModel.fromJson(
            {'type': 'CSV', 'name': 'USAHA_Behavior_Log_Oct', 'date': 'Oct 5, 2023', 'size': '210 KB'}),
        ExportHistoryModel.fromJson(
            {'type': 'PDF', 'name': 'JUJUR_Monthly_Report', 'date': 'Sep 15, 2023', 'size': '3.2 MB'}),
        ExportHistoryModel.fromJson(
            {'type': 'PDF', 'name': 'TEKUN_Weekly_Summary', 'date': 'Sep 8, 2023', 'size': '1.9 MB'}),
      ];

  // ---------------------------------------------------------------------------
  // Teacher profile
  // ---------------------------------------------------------------------------

  static TeacherProfileModel getTeacherProfile() =>
      TeacherProfileModel.fromJson({
        'name': 'Ms. Sarah Halim',
        'school': 'SMK Bandar Kinrara',
        'subject': 'Mathematics',
        'avatarUrl': '',
      });

  // ---------------------------------------------------------------------------
  // Droid pairing status
  // ---------------------------------------------------------------------------

  // TODO: Replace with droid pairing API
  static Map<String, dynamic> getDroidStatus() => {
        'connected': true,
        'droidId': 'EngageBot-04',
        'activeClass': '4 GIGIH Add Maths',
      };

  // ---------------------------------------------------------------------------
  // Preferences (defaults — persisted via SharedPreferences)
  // ---------------------------------------------------------------------------

  static Map<String, bool> getDefaultPreferences() => {
        'realtimeAlerts': true,
        'autoSchedule': false,
        'cloudSync': true,
      };

  // ---------------------------------------------------------------------------
  // Droid insights (Classes screen)
  // ---------------------------------------------------------------------------

  // TODO: Replace with droid insights API
  static Map<String, String> getDroidInsight() => {
        'title': 'Engagement Optimized',
        'description':
            '3 TEKUN showing peak visual focus today (+12%).',
      };

  // ---------------------------------------------------------------------------
  // Behaviour analysis — UC-6.2
  // ---------------------------------------------------------------------------

  // TODO: Replace with droid behaviour API
  static List<StudentBehaviourRecord> getBehaviourData(String classCode) {
    final roster = getRosterForClass(classCode);
    final records = roster.map((s) {
      final seed = s.id.length;
      final score = switch (s.status) {
        'engaged' => 75 + (seed % 21),
        'distracted' => 40 + (seed % 26),
        'flagged' => 20 + (seed % 31),
        _ => 60,
      };
      final offTask = switch (s.status) {
        'engaged' => seed % 2,
        'distracted' => 2 + (seed % 4),
        'flagged' => 5 + (seed % 5),
        _ => 1,
      };
      final attention = switch (s.status) {
        'engaged' => 30 + (seed % 16),
        'distracted' => 12 + (seed % 16),
        'flagged' => 5 + (seed % 11),
        _ => 20,
      };
      return StudentBehaviourRecord(
        studentId: s.id,
        studentName: s.name,
        engagementScore: score,
        attentionMinutes: attention,
        offTaskCount: offTask,
        dominantStatus: s.status,
      );
    }).toList();

    // Sort: flagged → distracted → engaged
    const order = {'flagged': 0, 'distracted': 1, 'engaged': 2};
    records.sort((a, b) =>
        (order[a.dominantStatus] ?? 3).compareTo(order[b.dominantStatus] ?? 3));
    return records;
  }

  // ---------------------------------------------------------------------------
  // Weekly trend — UC-6.4
  // ---------------------------------------------------------------------------

  // TODO: Replace with droid historical API
  static List<WeeklyDataPoint> getWeeklyTrend(String classCode) {
    const trends = {
      '1 USAHA': [70, 78, 82, 75, 88, 80, 82],
      '2 JUJUR': [65, 70, 75, 72, 78, 75, 75],
      '3 TEKUN': [80, 85, 88, 90, 91, 89, 90],
      '4 GIGIH': [60, 55, 68, 70, 65, 63, 68],
      '5 CEKAL': [75, 78, 82, 85, 84, 83, 85],
    };
    final values = trends[classCode] ?? [70, 72, 75, 73, 78, 76, 80];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return List.generate(
        7, (i) => WeeklyDataPoint(dayLabel: days[i], engagement: values[i]));
  }

  // ---------------------------------------------------------------------------
  // Session history — UC-6.4
  // ---------------------------------------------------------------------------

  // TODO: Replace with droid session history API
  static List<SessionRecord> getSessionHistory(String classCode) {
    final subject =
        (classCode == '4 GIGIH' || classCode == '5 CEKAL') ? 'Add Maths' : 'Mathematics';
    return [
      SessionRecord(
        date: 'Mon, 2 Jun 2025',
        classCode: classCode,
        subject: subject,
        avgEngagement: 88,
        durationMinutes: 50,
        studentCount: 28,
        flaggedCount: 1,
        highlight: 'Strong participation during group work',
      ),
      SessionRecord(
        date: 'Fri, 30 May 2025',
        classCode: classCode,
        subject: subject,
        avgEngagement: 75,
        durationMinutes: 45,
        studentCount: 28,
        flaggedCount: 3,
        highlight: 'Low attention during independent work',
      ),
      SessionRecord(
        date: 'Wed, 28 May 2025',
        classCode: classCode,
        subject: subject,
        avgEngagement: 82,
        durationMinutes: 50,
        studentCount: 27,
        flaggedCount: 2,
        highlight: 'Good response to Q&A segment',
      ),
      SessionRecord(
        date: 'Mon, 26 May 2025',
        classCode: classCode,
        subject: subject,
        avgEngagement: 79,
        durationMinutes: 48,
        studentCount: 28,
        flaggedCount: 2,
        highlight: 'Slight dip mid-session, recovered well',
      ),
      SessionRecord(
        date: 'Fri, 23 May 2025',
        classCode: classCode,
        subject: subject,
        avgEngagement: 91,
        durationMinutes: 52,
        studentCount: 28,
        flaggedCount: 0,
        highlight: 'Best session this month — peak focus',
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Teaching recommendations — UC-8
  // ---------------------------------------------------------------------------

  // TODO: Replace with droid AI teaching style API
  static List<TeachingRecommendation> getTeachingRecommendations() => [
        TeachingRecommendation(
          id: 'tr1',
          category: 'Engagement',
          title: 'Introduce Micro-Breaks',
          description:
              '5 sessions showed dipping engagement after 20 min. A 2-min energiser break can reset focus and raise class participation by ~15%.',
          priority: 'high',
        ),
        TeachingRecommendation(
          id: 'tr2',
          category: 'Strategy',
          title: 'Think-Pair-Share',
          description:
              'Students in rows 2–3 show lower collaboration scores. Structured pair discussions during problem-solving increase visible engagement.',
          priority: 'high',
        ),
        TeachingRecommendation(
          id: 'tr3',
          category: 'Attention',
          title: 'Proximity Technique',
          description:
              'Move around the room during silent tasks. Physical proximity reduces off-task behaviour by up to 40% for distracted students.',
          priority: 'medium',
        ),
        TeachingRecommendation(
          id: 'tr4',
          category: 'Behaviour',
          title: 'Positive Reinforcement Cues',
          description:
              'Use verbal affirmations when students refocus. Flagged students respond better to private acknowledgement over whole-class correction.',
          priority: 'medium',
        ),
        TeachingRecommendation(
          id: 'tr5',
          category: 'Strategy',
          title: 'Exit Ticket Routine',
          description:
              'End sessions with a 3-question exit ticket. Helps students consolidate learning and gives you data on concept retention.',
          priority: 'low',
        ),
        TeachingRecommendation(
          id: 'tr6',
          category: 'Engagement',
          title: 'Varied Question Types',
          description:
              'Mix recall, application, and open-ended questions. Varying difficulty keeps high-performers engaged while supporting struggling students.',
          priority: 'low',
        ),
      ];

  // ---------------------------------------------------------------------------
  // Student session history — UC-6.1 (View Full History)
  // ---------------------------------------------------------------------------

  // TODO: Replace with droid per-student history API
  static List<SessionRecord> getStudentSessionHistory(String studentId) {
    final classCode = _classRosterData.entries
        .where((e) => e.value.any((s) => s['id'] == studentId))
        .map((e) => e.key)
        .firstOrNull ?? '1 USAHA';
    final subject =
        (classCode == '4 GIGIH' || classCode == '5 CEKAL') ? 'Add Maths' : 'Mathematics';
    return [
      SessionRecord(
        date: 'Mon, 2 Jun 2025',
        classCode: classCode,
        subject: subject,
        avgEngagement: 88,
        durationMinutes: 50,
        studentCount: 1,
        flaggedCount: 0,
        highlight: 'Highly focused during practice problems',
      ),
      SessionRecord(
        date: 'Fri, 30 May 2025',
        classCode: classCode,
        subject: subject,
        avgEngagement: 72,
        durationMinutes: 45,
        studentCount: 1,
        flaggedCount: 1,
        highlight: 'Distracted during the last 15 min',
      ),
      SessionRecord(
        date: 'Wed, 28 May 2025',
        classCode: classCode,
        subject: subject,
        avgEngagement: 81,
        durationMinutes: 50,
        studentCount: 1,
        flaggedCount: 0,
        highlight: 'Engaged throughout group activity',
      ),
      SessionRecord(
        date: 'Mon, 26 May 2025',
        classCode: classCode,
        subject: subject,
        avgEngagement: 76,
        durationMinutes: 48,
        studentCount: 1,
        flaggedCount: 1,
        highlight: 'Inconsistent focus throughout session',
      ),
      SessionRecord(
        date: 'Fri, 23 May 2025',
        classCode: classCode,
        subject: subject,
        avgEngagement: 91,
        durationMinutes: 52,
        studentCount: 1,
        flaggedCount: 0,
        highlight: 'Best performance this month',
      ),
      SessionRecord(
        date: 'Wed, 21 May 2025',
        classCode: classCode,
        subject: subject,
        avgEngagement: 68,
        durationMinutes: 47,
        studentCount: 1,
        flaggedCount: 2,
        highlight: 'Struggled with new topic introduction',
      ),
    ];
  }
}
