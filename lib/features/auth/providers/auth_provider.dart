import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

enum AuthStatus { initial, loading, authenticated, notRegistered, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? teacherId;
  final String? email;
  final String? errorMessage;

  const AuthState._({
    required this.status,
    this.teacherId,
    this.email,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState._(status: AuthStatus.initial);
  factory AuthState.loading() => const AuthState._(status: AuthStatus.loading);
  factory AuthState.authenticated(String teacherId, String email) =>
      AuthState._(status: AuthStatus.authenticated, teacherId: teacherId, email: email);
  factory AuthState.notRegistered() => const AuthState._(status: AuthStatus.notRegistered);
  factory AuthState.unauthenticated() => const AuthState._(status: AuthStatus.unauthenticated);
  factory AuthState.error(String msg) => AuthState._(status: AuthStatus.error, errorMessage: msg);

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial()) {
    _restoreSession();
  }

  // On app launch: check whether a saved JWT is still valid by calling /auth/me.
  Future<void> _restoreSession() async {
    final token = await ApiService.getToken();
    if (token == null) {
      state = AuthState.unauthenticated();
      return;
    }
    try {
      final profile = await ApiService.getMyProfile();
      final teacherId = (profile['id'] ?? profile['_id'] ?? '').toString();
      final email = (profile['email'] ?? '').toString();
      state = AuthState.authenticated(teacherId, email);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        // Token expired — clear it and send to login.
        await ApiService.clearToken();
        state = AuthState.unauthenticated();
      } else {
        // Network error — keep authenticated with empty id so mock data is used.
        state = AuthState.authenticated('', '');
      }
    } catch (_) {
      state = AuthState.authenticated('', '');
    }
  }

  // ── Sign in ────────────────────────────────────────────────────────────────

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = AuthState.loading();
    try {
      final data = await ApiService.loginTeacher(email, password);
      final teacher = data['teacher'] as Map<String, dynamic>;
      final teacherId = (teacher['id'] ?? teacher['_id'] ?? '').toString();
      final teacherEmail = (teacher['email'] ?? email).toString();
      state = AuthState.authenticated(teacherId, teacherEmail);
    } on DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : e.message ?? 'Sign-in failed';
      state = AuthState.error(_mapError(msg));
    } catch (e) {
      state = AuthState.error('Sign-in failed. Please try again.');
    }
  }

  static String _mapError(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('incorrect') || lower.contains('invalid')) {
      return 'Incorrect email or password.';
    }
    if (lower.contains('deactivated') || lower.contains('disabled')) {
      return 'This account has been deactivated. Contact your admin.';
    }
    if (lower.contains('network') || lower.contains('connect')) {
      return 'No internet connection.';
    }
    return msg;
  }

  // ── Sign out ───────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await ApiService.logout();
    state = AuthState.unauthenticated();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

/// The current teacher's MongoDB _id as a string.
/// Null = not authenticated. Empty string = authenticated but API unreachable.
final currentTeacherIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).teacherId;
});
