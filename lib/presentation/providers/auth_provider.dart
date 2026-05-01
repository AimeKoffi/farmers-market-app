import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/storage_keys.dart';

class AuthState {
  final String? token;
  final Map<String, dynamic>? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.token,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    String? token,
    Map<String, dynamic>? user,
    bool? isLoading,
    String? error,
    bool clearToken = false,
  }) {
    return AuthState(
      token: clearToken ? null : token ?? this.token,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _loadStoredToken();
  }

  Future<void> _loadStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageKeys.authToken);
    if (token != null) {
      state = state.copyWith(token: token);
    }
  }

  Future<bool> login(String email, String password, Function(String, String) apiCall) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // apiCall vient du service — inject proprement
      final result = await apiCall(email, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.authToken, result['token']);
      state = state.copyWith(
        token: result['token'],
        user: result['user'],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.authToken);
    await prefs.remove(StorageKeys.currentUser);
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);