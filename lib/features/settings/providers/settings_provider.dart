import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/mock/mock_data_service.dart';
import '../../../data/services/mongo_data_service.dart';
import '../../auth/providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class PreferencesState {
  final bool realtimeAlerts;
  final bool autoSchedule;
  final bool cloudSync;
  final bool darkMode;
  final String teacherName;
  final String teacherSchool;
  final String teacherSubject;

  const PreferencesState({
    required this.realtimeAlerts,
    required this.autoSchedule,
    required this.cloudSync,
    required this.darkMode,
    required this.teacherName,
    required this.teacherSchool,
    this.teacherSubject = '',
  });

  PreferencesState copyWith({
    bool? realtimeAlerts,
    bool? autoSchedule,
    bool? cloudSync,
    bool? darkMode,
    String? teacherName,
    String? teacherSchool,
    String? teacherSubject,
  }) =>
      PreferencesState(
        realtimeAlerts: realtimeAlerts ?? this.realtimeAlerts,
        autoSchedule: autoSchedule ?? this.autoSchedule,
        cloudSync: cloudSync ?? this.cloudSync,
        darkMode: darkMode ?? this.darkMode,
        teacherName: teacherName ?? this.teacherName,
        teacherSchool: teacherSchool ?? this.teacherSchool,
        teacherSubject: teacherSubject ?? this.teacherSubject,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class SettingsNotifier extends StateNotifier<PreferencesState> {
  final Ref _ref;

  SettingsNotifier(this._ref) : super(_buildInitial()) {
    _ref.listen<String?>(currentTeacherIdProvider, (_, next) {
      if (next != null && next.isNotEmpty) refreshFromApi(next);
    });

    Future.microtask(() {
      final id = _ref.read(currentTeacherIdProvider);
      if (id != null && id.isNotEmpty) refreshFromApi(id);
    });
  }

  static PreferencesState _buildInitial() {
    final defaults = MockDataService.getDefaultPreferences();
    final teacher = MockDataService.getTeacherProfile();
    return PreferencesState(
      realtimeAlerts: defaults['realtimeAlerts'] ?? true,
      autoSchedule: defaults['autoSchedule'] ?? false,
      cloudSync: defaults['cloudSync'] ?? true,
      darkMode: false,
      teacherName: teacher.name,
      teacherSchool: teacher.school,
      teacherSubject: teacher.subject,
    );
  }

  Future<void> refreshFromApi(String teacherId) async {
    final profile = await MongoDataService.getTeacherProfile(teacherId);
    if (!mounted) return;
    state = state.copyWith(
      teacherName: profile.name.isNotEmpty ? profile.name : state.teacherName,
      teacherSchool:
          profile.school.isNotEmpty ? profile.school : state.teacherSchool,
      teacherSubject:
          profile.subject.isNotEmpty ? profile.subject : state.teacherSubject,
    );
  }

  Future<void> setRealtimeAlerts(bool value) async {
    state = state.copyWith(realtimeAlerts: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('realtimeAlerts', value);
  }

  Future<void> setAutoSchedule(bool value) async {
    state = state.copyWith(autoSchedule: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoSchedule', value);
  }

  Future<void> setCloudSync(bool value) async {
    state = state.copyWith(cloudSync: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cloudSync', value);
  }

  Future<void> setDarkMode(bool value) async {
    state = state.copyWith(darkMode: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }

  Future<void> updateProfile({required String name}) async {
    state = state.copyWith(teacherName: name);
    await MongoDataService.updateTeacherName(name);
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      realtimeAlerts:
          prefs.getBool('realtimeAlerts') ?? state.realtimeAlerts,
      autoSchedule: prefs.getBool('autoSchedule') ?? state.autoSchedule,
      cloudSync: prefs.getBool('cloudSync') ?? state.cloudSync,
      darkMode: prefs.getBool('darkMode') ?? state.darkMode,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, PreferencesState>(
  (ref) => SettingsNotifier(ref),
);
