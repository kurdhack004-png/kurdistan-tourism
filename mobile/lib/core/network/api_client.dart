import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around Dio that attaches the bearer token to every
/// request and centralizes base URL / error handling. Tokens are kept in
/// flutter_secure_storage (Keychain/Keystore-backed) rather than
/// SharedPreferences, which is not encrypted at rest.
class ApiClient {
  ApiClient({String? baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'https://rapids-supporting-settled-system.trycloudflare.com/api',
          ),
          connectTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _storage.delete(key: 'auth_token');
            // A router-level listener on the cleared token redirects to login.
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final _storage = const FlutterSecureStorage();

  Dio get client => _dio;

  Future<void> saveToken(String token) => _storage.write(key: 'auth_token', value: token);
  Future<void> clearToken() => _storage.delete(key: 'auth_token');
  Future<String?> readToken() => _storage.read(key: 'auth_token');
}
