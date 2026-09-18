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
  }) =>
      AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        isLocalMode: isLocalMode ?? this.isLocalMode,
      );
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
        isLocalMode: false,
      );
    } catch (_) {
      final ok = await DemoAuth.login(email, password);
      if (ok) {
        await _api.saveToken('local_demo_${email.trim().toLowerCase()}');
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          isLocalMode: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          error: 'چوونەژوورەوە سەرکەوتوو نەبوو. ئیمەیل و وشەی نهێنی بپشکنە.',
          isLocalMode: false,
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
      await DemoAuth.register(fullName, email, password);
      await _api.saveToken('local_demo_${email.trim().toLowerCase()}');
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        isLocalMode: true,
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
