import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendra/core/database/isar_provider.dart';
import 'package:spendra/core/providers/providers.dart';
import 'package:spendra/core/utils/result.dart';
import 'package:spendra/features/auth/domain/entities/app_user.dart';
import 'package:spendra/features/auth/domain/repositories/auth_repository.dart';

class AppAuthState {
  const AppAuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isSyncing = false,
  });

  final AppUser? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isSyncing;

  bool get isAuthenticated => user != null;

  AppAuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? errorMessage,
    bool? isSyncing,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AppAuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

class AuthController extends StateNotifier<AppAuthState> {
  AuthController(this._authRepo, this._ref)
      : super(AppAuthState(user: _authRepo.currentUser)) {
    _authRepo.authStateChanges().listen((user) {
      state = state.copyWith(user: user, clearUser: user == null);
      if (user != null) {
        syncData();
      }
    });
  }

  final AuthRepository _authRepo;
  final Ref _ref;

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _authRepo.signIn(
      email: email,
      password: password,
    );

    return result.when(
      success: (user) {
        state = state.copyWith(user: user, isLoading: false);
        syncData();
        return true;
      },
      failure: (f) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: f.message,
        );
        return false;
      },
    );
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _authRepo.signUp(
      email: email,
      password: password,
      name: name,
    );

    return result.when(
      success: (user) {
        state = state.copyWith(user: user, isLoading: false);
        syncData();
        return true;
      },
      failure: (f) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: f.message,
        );
        return false;
      },
    );
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _authRepo.signInWithGoogle();
    return result.when(
      success: (ok) {
        state = state.copyWith(isLoading: false);
        return ok;
      },
      failure: (f) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: f.message,
        );
        return false;
      },
    );
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _authRepo.signOut();
    state = const AppAuthState();
  }

  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _authRepo.resetPassword(email);
    return result.when(
      success: (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
      failure: (f) {
        state = state.copyWith(isLoading: false, errorMessage: f.message);
        return false;
      },
    );
  }

  Future<void> syncData() async {
    if (state.isSyncing) return;
    state = state.copyWith(isSyncing: true);
    try {
      final syncService = _ref.read(supabaseSyncServiceProvider);
      final isar = _ref.read(isarProvider);

      // 1. Push local changes
      await syncService.pushAllLocalData(isar);
      // 2. Pull remote changes
      await syncService.pullAllCloudData(isar);
    } catch (e) {
      // ignore
    } finally {
      state = state.copyWith(isSyncing: false);
    }
  }

  Future<bool> updateProfileName(String name) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _authRepo.updateProfile(name: name);
    return result.when(
      success: (user) {
        state = state.copyWith(user: user, isLoading: false);
        return true;
      },
      failure: (f) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: f.message,
        );
        return false;
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
