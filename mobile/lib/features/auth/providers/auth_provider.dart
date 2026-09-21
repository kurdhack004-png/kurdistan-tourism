import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class AuthState {
  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.role,
  });

  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final String? role;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? role,
  }) =>
      AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        role: role ?? this.role,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._api) : super(const AuthState()) {
    ready = _restoreSession();
  }

  final ApiClient _api;
  late final Future<void> ready;

  Future<void> _loadRole() async {
    try {
      final res = await _api.client.get('/auth/me');
      final body = Map<String, dynamic>.from(res.data as Map);
      final user = body['user'] is Map ? Map<String, dynamic>.from(body['user'] as Map) : null;
      state = state.copyWith(role: user?['role'] as String?);
    } catch (_) {}
  }

  Future<void> _restoreSession() async {
    final token = await _api.readToken();
    if (token != null) {
      state = state.copyWith(isAuthenticated: true);
      await _loadRole();
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _api.client.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final body = Map<String, dynamic>.from(res.data as Map);
      final data = body['data'] is Map
          ? Map<String, dynamic>.from(body['data'] as Map)
          : body;
      final token = data['token'] as String?;
      if (token == null || token.isEmpty) {
        throw const FormatException('Missing token');
      }
      await _api.saveToken(token);
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
      );
      await _loadRole();
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: 'auth_login_failed',
      );
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _api.client.post(
        '/auth/register',
        data: {
          'full_name': fullName,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      );
      final body = Map<String, dynamic>.from(res.data as Map);
      final data = body['data'] is Map
          ? Map<String, dynamic>.from(body['data'] as Map)
          : body;
      final token = data['token'] as String?;
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
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: 'auth_register_failed',
      );
    }
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
