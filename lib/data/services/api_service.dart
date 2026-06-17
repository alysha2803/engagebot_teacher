import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Resolved once at first use.
/// Override at build/run time for physical devices or staging:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.5:5000/api
String get _resolvedBaseUrl {
  const defined = String.fromEnvironment('API_BASE_URL');
  if (defined.isNotEmpty) return defined;
  if (Platform.isAndroid) return 'http://10.0.2.2:5000/api'; // Android emulator
  return 'http://localhost:5000/api'; // iOS simulator / macOS
}

const _kTokenKey = 'engagebot_jwt';

class ApiService {
  static Dio? _dioInstance;
  static Dio get _dio => _dioInstance ??= Dio(BaseOptions(
        baseUrl: _resolvedBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ))
        ..interceptors.add(_AuthInterceptor());

  // ── Token management ────────────────────────────────────────────────────────

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kTokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
  }

  // ── Auth ────────────────────────────────────────────────────────────────────

  /// Logs in a teacher. Returns {token, teacher} map on success.
  /// Throws [ApiException] on failure.
  static Future<Map<String, dynamic>> loginTeacher(
    String email,
    String password,
  ) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/teacher/login',
      data: {'email': email.trim(), 'password': password},
    );
    final data = res.data!;
    await saveToken(data['token'] as String);
    return data;
  }

  static Future<void> logout() => clearToken();

  // ── Teacher ─────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getMyProfile() async {
    final res = await _dio.get<Map<String, dynamic>>('/teachers/profile');
    return res.data!;
  }

  static Future<void> updateMyProfile(Map<String, dynamic> patch) async {
    await _dio.patch('/teachers/profile', data: patch);
  }

  // ── Classes ─────────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getSchedules({String? teacherId}) async {
    final res = await _dio.get<List<dynamic>>(
      '/schedules',
      queryParameters: teacherId != null ? {'teacherId': teacherId} : null,
    );
    return res.data!;
  }

  // ── Students ────────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getStudents({String? classGroup}) async {
    final res = await _dio.get<List<dynamic>>(
      '/students',
      queryParameters: classGroup != null ? {'classGroup': classGroup} : null,
    );
    return res.data!;
  }

  static Future<void> updateStudent(
    String studentId,
    Map<String, dynamic> patch,
  ) async {
    await _dio.patch('/students/$studentId', data: patch);
  }

  // ── Reports ─────────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getSessionReports(String date) async {
    final res = await _dio.get<List<dynamic>>(
      '/reports',
      queryParameters: {'date': date},
    );
    return res.data ?? [];
  }

  static Future<Map<String, dynamic>> getMonthlyReports(int month, int year) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/reports/monthly',
      queryParameters: {'month': month, 'year': year},
    );
    return res.data ?? {};
  }

  // ── Generic GET helper ───────────────────────────────────────────────────────

  static Future<T> get<T>(String path) async {
    final res = await _dio.get<T>(path);
    return res.data as T;
  }
}

// Attaches the JWT from SharedPreferences to every request automatically.
class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await ApiService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final data = err.response?.data;
    String message = 'Request failed';
    if (data is Map && data['message'] != null) {
      message = data['message'] as String;
    } else if (err.message != null) {
      message = err.message!;
    }
    handler.next(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: ApiException(message),
      message: message,
    ));
  }
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => message;
}
