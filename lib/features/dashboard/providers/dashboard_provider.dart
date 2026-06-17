import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/mock/mock_data_service.dart';
import '../../../data/models/class_model.dart';
import '../../../data/models/student_model.dart';
import '../../../data/services/mongo_data_service.dart';
import '../../auth/providers/auth_provider.dart';

// ---------------------------------------------------------------------------
// Global student edits store
// Persists name/status/note edits across class switches and provider rebuilds.
// ---------------------------------------------------------------------------

final studentEditsProvider = StateProvider<Map<String, StudentModel>>(
  (ref) => {},
);

// ---------------------------------------------------------------------------
// Dashboard state
// ---------------------------------------------------------------------------

class DashboardState {
  final Map<String, dynamic> liveEngagement;
  final List<ClassModel> classes;
  final int selectedClassIndex;
  final List<StudentModel> roster;
  final Map<String, dynamic> aiRecommendation;
  final bool isLoading;
  // True after the first successful API fetch — distinguishes "API returned
  // empty" from "still waiting for the first response".
  final bool hasLoadedFromApi;

  const DashboardState({
    required this.liveEngagement,
    required this.classes,
    required this.selectedClassIndex,
    required this.roster,
    required this.aiRecommendation,
    this.isLoading = false,
    this.hasLoadedFromApi = false,
  });

  DashboardState copyWith({
    Map<String, dynamic>? liveEngagement,
    List<ClassModel>? classes,
    int? selectedClassIndex,
    List<StudentModel>? roster,
    Map<String, dynamic>? aiRecommendation,
    bool? isLoading,
    bool? hasLoadedFromApi,
  }) =>
      DashboardState(
        liveEngagement: liveEngagement ?? this.liveEngagement,
        classes: classes ?? this.classes,
        selectedClassIndex: selectedClassIndex ?? this.selectedClassIndex,
        roster: roster ?? this.roster,
        aiRecommendation: aiRecommendation ?? this.aiRecommendation,
        isLoading: isLoading ?? this.isLoading,
        hasLoadedFromApi: hasLoadedFromApi ?? this.hasLoadedFromApi,
      );
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final Ref _ref;
  Timer? _refreshTimer;

  DashboardNotifier(this._ref)
      : super(DashboardState(
          liveEngagement: MockDataService.getLiveEngagement(),
          classes: MockDataService.getClasses(),
          selectedClassIndex: 0,
          roster: MockDataService.getRosterForClass('1 USAHA'),
          aiRecommendation: MockDataService.getAIRecommendation(),
        )) {
    // Listen for sign-in events that occur after this notifier is created.
    _ref.listen<String?>(currentTeacherIdProvider, (_, next) {
      if (next != null && next.isNotEmpty) {
        refreshFromFirebase(next);
        _startPeriodicRefresh(next);
      }
    });

    // If the session was already restored (app restart with existing auth),
    // kick off a refresh immediately without blocking the constructor.
    Future.microtask(() {
      final id = _ref.read(currentTeacherIdProvider);
      if (id != null && id.isNotEmpty) {
        refreshFromFirebase(id);
        _startPeriodicRefresh(id);
      }
    });
  }

  void _startPeriodicRefresh(String teacherId) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (!mounted) return;
      refreshFromFirebase(teacherId);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// Merge a freshly-loaded roster with any persisted edits from the global store.
  List<StudentModel> _applyEdits(List<StudentModel> baseRoster) {
    final edits = _ref.read(studentEditsProvider);
    return baseRoster.map((s) => edits[s.id] ?? s).toList();
  }

  /// Pull classes, roster, and live session data from the API.
  Future<void> refreshFromFirebase(String teacherId) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);

    final classes = await MongoDataService.getClasses(teacherId);
    if (!mounted) return;

    final classCode = classes.isNotEmpty ? classes[0].code : '';

    // Fetch roster (with droid engagement overlay) and live session in parallel.
    final rosterFuture =
        MongoDataService.getRosterWithEngagement(classCode, teacherId);
    final liveFuture = MongoDataService.getLiveSession(classCode);

    final roster = await rosterFuture;
    final liveSession = await liveFuture;
    if (!mounted) return;

    state = state.copyWith(
      classes: classes,
      roster: _applyEdits(roster),
      selectedClassIndex: 0,
      liveEngagement:
          liveSession != null ? _mapLiveSession(liveSession) : state.liveEngagement,
      isLoading: false,
      hasLoadedFromApi: true,
    );
  }

  static Map<String, dynamic> _mapLiveSession(Map<String, dynamic> report) {
    final score = (report['avgFocusScore'] as num?)?.toInt() ?? 0;
    final engagement = (report['overallEngagement'] as String?) ?? '';
    final startTime = report['startTime'] as String?;

    int minutes = 0;
    if (startTime != null) {
      final parts = startTime.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        final now = DateTime.now();
        final startMinutes = h * 60 + m;
        final nowMinutes = now.hour * 60 + now.minute;
        minutes = (nowMinutes - startMinutes).clamp(0, 200);
      }
    }

    // Simple trend label derived from score.
    final diff = score - 70;
    final trend = diff >= 0 ? '+$diff%' : '$diff%';

    final droidStatus = switch (engagement) {
      'high' => 'ENGAGED',
      'medium' => 'MODERATE',
      'low' => 'DISTRACTED',
      'absent' => 'ABSENT',
      _ => report['status'] == 'in_progress' ? 'MONITORING' : 'IDLE',
    };

    return {
      'percentage': score,
      'trend': trend,
      'sessionMinutes': minutes,
      'droidStatus': droidStatus,
    };
  }

  /// Switch to a different class and reload its roster with droid engagement.
  Future<void> selectClass(int index) async {
    final classCode = state.classes[index].code;
    final teacherId = _ref.read(currentTeacherIdProvider) ?? '';

    final baseRoster = teacherId.isNotEmpty
        ? await MongoDataService.getRosterWithEngagement(classCode, teacherId)
        : MockDataService.getRosterForClass(classCode);

    if (!mounted) return;
    state = state.copyWith(
      selectedClassIndex: index,
      roster: _applyEdits(baseRoster),
    );
  }

  void editStudent(String studentId, StudentModel updated) {
    // Persist to Firestore (fire-and-forget — UI updates via in-memory overlay).
    MongoDataService.updateStudent(studentId, updated);
    // Persist to global store so other screens and future selectClass calls
    // pick up the change without hitting MockDataService again.
    _ref.read(studentEditsProvider.notifier).update(
      (map) => {...map, studentId: updated},
    );
    // Refresh the visible roster immediately.
    final roster =
        state.roster.map((s) => s.id == studentId ? updated : s).toList();
    state = state.copyWith(roster: roster);
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>(
  (ref) => DashboardNotifier(ref),
);
