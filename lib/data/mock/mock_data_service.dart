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
  // Student roster
  // ---------------------------------------------------------------------------

  // TODO: Replace with droid live roster API
  static List<StudentModel> getRoster() => [
        StudentModel.fromJson({'id': 'ahmad', 'name': 'Ahmad', 'status': 'engaged'}),
        StudentModel.fromJson({'id': 'aina', 'name': 'Aina', 'status': 'engaged'}),
        StudentModel.fromJson({'id': 'hamid', 'name': 'Hamid', 'status': 'engaged'}),
        StudentModel.fromJson({'id': 'maya', 'name': 'Maya', 'status': 'distracted'}),
        StudentModel.fromJson({'id': 'badrul', 'name': 'Badrul', 'status': 'engaged'}),
        StudentModel.fromJson({'id': 'hani', 'name': 'Hani', 'status': 'engaged'}),
      ];

  // ---------------------------------------------------------------------------
  // Student profile
  // ---------------------------------------------------------------------------

  // TODO: Replace with droid student engagement API
  static StudentProfile getStudentProfile(String studentId) {
    // In production this would look up by studentId; for now returns Ali Zain's data.
    return StudentProfile.fromJson({
      'id': studentId,
      'name': 'Ali Zain',
      'class': '3 TEKUN',
      'subject': 'Mathematics',
      'engagementLabel': 'High Engaged',
      'avgEngagement': 88,
      'flags': 2,
      'focusDepth': 92,
      'collaboration': 45,
      'droidInsight':
          "Ali's engagement dropped by 30% during independent reading. Try initiating a 1-on-1 concept check to re-focus.",
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
            {'type': 'CSV', 'name': 'Engagement_Raw_Data_O', 'date': 'Oct 12, 2023', 'size': '452 KB'}),
        ExportHistoryModel.fromJson(
            {'type': 'PDF', 'name': 'Monthly_Teaching_Insights_', 'date': 'Sep 30, 2023', 'size': '5.1 MB'}),
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
}
