import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

enum AuthStatus { initial, loading, authenticated, notRegistered, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? teacherId; // Firestore teachers/{teacherId}
  final String? email;
  final String? errorMessage;

  const AuthState._({
    required this.status,
    this.teacherId,
    this.email,
    this.errorMessage,
  });

  factory AuthState.initial() =>
      const AuthState._(status: AuthStatus.initial);
  factory AuthState.loading() =>
      const AuthState._(status: AuthStatus.loading);
  factory AuthState.authenticated(String teacherId, String email) =>
      AuthState._(status: AuthStatus.authenticated, teacherId: teacherId, email: email);
  factory AuthState.notRegistered() =>
      const AuthState._(status: AuthStatus.notRegistered);
  factory AuthState.unauthenticated() =>
      const AuthState._(status: AuthStatus.unauthenticated);
  factory AuthState.error(String msg) =>
      AuthState._(status: AuthStatus.error, errorMessage: msg);

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial()) {
    _restoreSession();
  }

  // Check whether the user is already signed in from a previous session.
  Future<void> _restoreSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = AuthState.unauthenticated();
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .doc('users/${user.uid}')
          .get()
          .timeout(const Duration(seconds: 5));
      final teacherId = doc.data()?['teacherId'] as String?;
      if (teacherId != null && teacherId.isNotEmpty) {
        state = AuthState.authenticated(teacherId, user.email ?? '');
      } else {
        // Auth token exists but no Firestore user record — sign out cleanly.
        await FirebaseAuth.instance.signOut();
        state = AuthState.unauthenticated();
      }
    } catch (_) {
      // Firestore unavailable (offline / first launch with no network).
      // Keep the user "in" with an empty teacherId so mock data is used.
      state = AuthState.authenticated('', user.email ?? '');
    }
  }

  // ── Sign in ───────────────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    state = AuthState.loading();
    try {
      final user = (await FirebaseAuth.instance
              .signInWithProvider(GoogleAuthProvider()))
          .user!;
      final email = user.email!.toLowerCase();

      // Check whether this Google account belongs to a registered teacher.
      final snap = await FirebaseFirestore.instance
          .collection('teachers')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        await FirebaseAuth.instance.signOut();
        state = AuthState.notRegistered();
        return;
      }

      final doc = snap.docs.first;
      // Link the Firebase Auth UID to the teacher document.
      await doc.reference.update({'authUid': user.uid});
      // Write/merge a user record so future sessions can resolve teacherId fast.
      await FirebaseFirestore.instance.doc('users/${user.uid}').set(
        {'teacherId': doc.id, 'role': 'teacher', 'email': email},
        SetOptions(merge: true),
      );

      state = AuthState.authenticated(doc.id, email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'web-context-cancelled' ||
          e.code == 'canceled') {
        // User closed the sign-in popup — don't show an error.
        state = AuthState.unauthenticated();
      } else {
        state = AuthState.error(e.message ?? 'Authentication failed');
      }
    } catch (_) {
      state = AuthState.error('Sign-in failed. Please try again.');
    }
  }

  // ── Email / password sign in ──────────────────────────────────────────────

  Future<void> signInWithEmailAndPassword(
      String email, String password) async {
    state = AuthState.loading();
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;

      final doc = await FirebaseFirestore.instance
          .doc('users/${user.uid}')
          .get()
          .timeout(const Duration(seconds: 6));

      final teacherId = doc.data()?['teacherId'] as String?;
      if (teacherId != null && teacherId.isNotEmpty) {
        state = AuthState.authenticated(teacherId, user.email ?? '');
      } else {
        // Auth account exists but no teacher record — admin hasn't registered them.
        await FirebaseAuth.instance.signOut();
        state = AuthState.notRegistered();
      }
    } on FirebaseAuthException catch (e) {
      state = AuthState.error(_emailError(e.code));
    } catch (_) {
      // Firestore unreachable — keep user signed in with mock data fallback.
      if (FirebaseAuth.instance.currentUser != null) {
        state = AuthState.authenticated(
            '', FirebaseAuth.instance.currentUser!.email ?? '');
      } else {
        state = AuthState.error('Sign-in failed. Please try again.');
      }
    }
  }

  static String _emailError(String code) => switch (code) {
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' ||
        'INVALID_LOGIN_CREDENTIALS' =>
          'Incorrect email or password.',
        'user-disabled' => 'This account has been disabled.',
        'too-many-requests' => 'Too many attempts. Please try again later.',
        'network-request-failed' => 'No internet connection.',
        _ => 'Sign-in failed. Please try again.',
      };

  // ── Sign out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    state = AuthState.unauthenticated();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

/// Derives the current teacher's Firestore document ID from auth state.
/// Other providers (dashboard, settings) watch this to trigger Firebase refreshes.
/// Null means "not authenticated" — use mock data only.
/// Empty string means "authenticated but Firestore unreachable" — use mock data.
final currentTeacherIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).teacherId;
});
