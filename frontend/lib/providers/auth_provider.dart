import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/user.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref.read(apiServiceProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final ApiService _api;

  AuthNotifier(this._api) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    await _api.init();
    if (_api.isAuthenticated) {
      try {
        final user = await _api.getMe();
        state = AsyncValue.data(user);
      } catch (e) {
        state = const AsyncValue.data(null);
      }
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _api.login(email, password);
      final user = await _api.getMe();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register(String email, String password, String displayName) async {
    state = const AsyncValue.loading();
    try {
      await _api.register(email, password, displayName);
      final user = await _api.getMe();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await _api.clearTokens();
    state = const AsyncValue.data(null);
  }
}
