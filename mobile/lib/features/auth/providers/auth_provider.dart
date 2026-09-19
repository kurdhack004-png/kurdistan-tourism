import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../data/local/demo_auth.dart';

class AuthState {
  const AuthState({this.isAuthenticated = false, this.isLoading = false, this.error, this.isLocalMode = false});
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final bool isLocalMode;

  AuthState copyWith({bool? isAuthenticated, bool? isLoading, String? error, bool clearError = false, bool? isLocalMode}) => AuthState(
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
    if (token != null) {
      state = state.copyWith(isAuthenticated: true, isLocalMode: token.startsWith('local_demo_'));
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _api.client.post('/auth/login', data: {'email': email, 'password': password});
      final body = Map<String, dynamic>.from(res.data as Map);
      final data = body['data'] is Map ? Map<String, dynamic>.from(body['data'] as Map) : body;
      final token = data['token'] as String?;
      if (token == null || token.isEmpty) throw const FormatException('Missing token');
      await _api.saveToken(token);
      state = state.copyWith(isAuthenticated: true, isLoading: false, isLocalMode: false);
    } catch (_) {
      final ok = await DemoAuth.login(email, password);
      if (ok) {
        await _api.saveToken('local_demo_${email.trim().toLowerCase()}');
        state = state.copyWith(isAuthenticated: true, isLoading: false, isLocalMode: true);
      } else {
        state = state.copyWith(isLoading: false, isAuthenticated: false,
            error: '趩賵賵賳蹠跇賵賵乇蹠賵蹠 爻蹠乇讴蹠賵鬲賵賵 賳蹠亘賵賵. 卅蹠诏蹠乇 Backend 賭鬲 賳蹠禺爻鬲賵賵蹠鬲蹠 讴丕乇貙 爻蹠乇蹠鬲丕 賴蹠跇賲丕乇蹘讴蹖 賳賵蹘 丿乇賵爻鬲 亘讴蹠.',
            isLocalMode: false);
      }
    }
  }

  Future<void> register({required String fullName, required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _api.client.post('/auth/register', data: {
        'name': fullName,
        'email': email,
        'password': password,
              });
      final body = Map<String, dynamic>.from(res.data as Map);
      final data = body['data'] is Map ? Map<String, dynamic>.from(body['data'] as Map) : body;
      final token = data['token'] as String?;
      if (token == null || token.isEmpty) throw const FormatException('Missing token');
      await _api.saveToken(token);
      state = state.copyWith(isAuthenticated: true, isLoading: false, isLocalMode: false);
    } catch (_) {
      await DemoAuth.register(fullName, email, password);
      await _api.saveToken('local_demo_${email.trim().toLowerCase()}');
      state = state.copyWith(isAuthenticated: true, isLoading: false, isLocalMode: true);
    }
  }

  Future<void> logout() async {
    await _api.clearToken();
    state = const AuthState();
  }

  /// TEMPORARY: force an authenticated local-demo session with no
  /// credentials, so the dashboard is reachable directly from the splash
  /// screen while login/backend are still being sorted out.
  Future<void> bypassForTesting() async {
    const demoToken = 'local_demo_guest@kurdistantourism.app';
    await _api.saveToken(demoToken);
    state = state.copyWith(isAuthenticated: true, isLoading: false, isLocalMode: true, clearError: true);
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(apiClientProvider)),
);    required String password,
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

      final body = res.data is Map ? Map<String, dynamic>.from(res.data as Map) : <String, dynamic>{};
      final token = _extractToken(body);
      if (token == null || token.isEmpty) throw const FormatException('Missing token');

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

  Future<void> _registerLocal(String fullName, String email, String password) async {
    await DemoAuth.register(fullName, email, password);
    await _api.saveToken('local_demo_${email.trim().toLowerCase()}');
    state = state.copyWith(
      isAuthenticated: true,
      isLoading: false,
      isLocalMode: true,
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
