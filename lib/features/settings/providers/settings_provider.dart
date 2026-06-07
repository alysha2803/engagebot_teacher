import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/mock/mock_data_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Preferences state — persisted to SharedPreferences
// ─────────────────────────────────────────────────────────────────────────────

class PreferencesState {
  final bool realtimeAlerts;
  final bool autoSchedule;
  final bool cloudSync;

  const PreferencesState({
    required this.realtimeAlerts,
    required this.autoSchedule,
    required this.cloudSync,
  });

  PreferencesState copyWith({
    bool? realtimeAlerts,
    bool? autoSchedule,
    bool? cloudSync,
  }) =>
      PreferencesState(
        realtimeAlerts: realtimeAlerts ?? this.realtimeAlerts,
        autoSchedule: autoSchedule ?? this.autoSchedule,
        cloudSync: cloudSync ?? this.cloudSync,
      );
}

class SettingsNotifier extends StateNotifier<PreferencesState> {
  SettingsNotifier()
      : super(_fromDefaults(MockDataService.getDefaultPreferences()));

  static PreferencesState _fromDefaults(Map<String, bool> d) =>
      PreferencesState(
        realtimeAlerts: d['realtimeAlerts'] ?? true,
        autoSchedule: d['autoSchedule'] ?? false,
        cloudSync: d['cloudSync'] ?? true,
      );

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

  /// Load persisted values from SharedPreferences on app start.
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    state = PreferencesState(
      realtimeAlerts: prefs.getBool('realtimeAlerts') ?? state.realtimeAlerts,
      autoSchedule: prefs.getBool('autoSchedule') ?? state.autoSchedule,
      cloudSync: prefs.getBool('cloudSync') ?? state.cloudSync,
    );
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, PreferencesState>(
  (ref) => SettingsNotifier(),
);
