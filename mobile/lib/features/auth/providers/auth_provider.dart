import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../data/local/demo_auth.dart';

class AuthState {
  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.isLocalMode = false,
  });

  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final bool isLocalMode;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? isLocalMode,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isLocalMode: isLocalMode ?? this.isLocalMode,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._api) : super(const AuthState()) {
    ready = _restoreSession();
  }

  final ApiClient _api;
  late final Future<void> ready;

  Future<void> _restoreSession() async {
    final token = await _api.readToken();
    if (token != null && token.isNotEmpty) {
      state = state.copyWith(
        isAuthenticated: true,
        isLocalMode: token.startsWith('local_demo_'),
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _api.client.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final token = _extractToken(response.data);
      if (token == null || token.isEmpty) {
        throw const FormatException('Missing token');
      }
      await _api.saveToken(token);
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        isLocalMode: false,
      );
    } catch (_) {
      final ok = await DemoAuth.login(email, password);
      if (ok) {
        await _saveLocalSession(email);
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          isLocalMode: false,
          error: 'چوونەژوورەوە سەرکەوتوو نەبوو.',
        );
      }
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _api.client.post(
        '/auth/register',
        data: {
          'name': fullName,
          'email': email,
          'password': password,
        },
      );
      final token = _extractToken(response.data);
      if (token == null || token.isEmpty) {
        throw const FormatException('Missing token');
      }
      await _api.saveToken(token);
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        isLocalMode: false,
      );
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status != null && status >= 400 && status < 500) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          error: 'زانیارییەکان دروست نین یان ئیمەیلەکە پێشتر بەکارهاتووە.',
        );
      } else {
        await _registerLocal(fullName, email, password);
      }
    } catch (_) {
      await _registerLocal(fullName, email, password);
    }
  }

  Future<void> _registerLocal(
    String fullName,
    String email,
    String password,
  ) async {
    await DemoAuth.register(fullName, email, password);
    await _saveLocalSession(email);
  }

  Future<void> _saveLocalSession(String email) async {
    await _api.saveToken('local_demo_${email.trim().toLowerCase()}');
    state = state.copyWith(
      isAuthenticated: true,
      isLoading: false,
      isLocalMode: true,
      clearError: true,
    );
  }

  String? _extractToken(dynamic responseData) {
    if (responseData is! Map) return null;
    final body = Map<String, dynamic>.from(responseData);
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
    final token = data['token'] ?? body['access_token'];
    return token is String ? token : null;
  }

  Future<void> bypassForTesting() async {
    const demoToken = 'local_demo_guest@kurdistantourism.app';
    await _api.saveToken(demoToken);
    state = state.copyWith(
      isAuthenticated: true,
      isLoading: false,
      isLocalMode: true,
      clearError: true,
    );
  }

  Future<void> logout() async {
    await _api.clearToken();
    state = const AuthState();
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(apiClientProvider)),
);
