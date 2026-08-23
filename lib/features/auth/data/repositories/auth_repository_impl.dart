import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendra/core/utils/result.dart';
import 'package:spendra/features/auth/domain/entities/app_user.dart';
import 'package:spendra/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Stream<AppUser?> authStateChanges() {
    return _supabase.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      return user != null ? AppUser.fromSupabaseUser(user) : null;
    });
  }

  @override
  AppUser? get currentUser {
    final user = _supabase.auth.currentUser;
    return user != null ? AppUser.fromSupabaseUser(user) : null;
  }

  @override
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  @override
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: name != null && name.trim().isNotEmpty
            ? {'name': name.trim(), 'full_name': name.trim()}
            : null,
      );

      final user = response.user;
      if (user == null) {
        return const Failure(AuthFailure('Sign up failed: User is null'));
      }

      // If signUp did not automatically establish a session, sign in explicitly
      if (response.session == null) {
        try {
          final signInRes = await _supabase.auth.signInWithPassword(
            email: email.trim(),
            password: password,
          );
          final activeUser = signInRes.user ?? user;
          return Success(AppUser.fromSupabaseUser(activeUser));
        } on AuthException catch (e) {
          if (e.message.toLowerCase().contains('email not confirmed') ||
              e.message.toLowerCase().contains('confirm')) {
            return const Failure(AuthFailure(
              'A verification link was sent to your email. Please click the link to activate, or turn OFF "Confirm email" in your Supabase Dashboard to login instantly!',
            ));
          }
          return Failure(AuthFailure(e.message));
        }
      }

      return Success(AppUser.fromSupabaseUser(user));
    } on AuthException catch (e, st) {
      if (e.message.toLowerCase().contains('email not confirmed') ||
          e.message.toLowerCase().contains('confirm')) {
        return const Failure(AuthFailure(
          'Email not confirmed yet. Please check your inbox/spam or disable "Confirm email" in Supabase Dashboard.',
        ));
      }
      return Failure(AuthFailure(e.message), stackTrace: st);
    } catch (e, st) {
      return Failure(AuthFailure(e.toString()), stackTrace: st);
    }
  }

  @override
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) {
        return const Failure(AuthFailure('Sign in failed: User is null'));
      }

      return Success(AppUser.fromSupabaseUser(user));
    } on AuthException catch (e, st) {
      if (e.message.toLowerCase().contains('email not confirmed') ||
          e.message.toLowerCase().contains('confirm')) {
        return const Failure(AuthFailure(
          'Email is not confirmed yet. Please verify the link sent to your inbox, or turn OFF "Confirm email" in Supabase Dashboard -> Authentication -> Providers -> Email.',
        ));
      }
      return Failure(AuthFailure(e.message), stackTrace: st);
    } catch (e, st) {
      return Failure(AuthFailure(e.toString()), stackTrace: st);
    }
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email.trim());
      return const Success(null);
    } on AuthException catch (e, st) {
      return Failure(AuthFailure(e.message), stackTrace: st);
    } catch (e, st) {
      return Failure(AuthFailure(e.toString()), stackTrace: st);
    }
  }

  @override
  Future<Result<bool>> signInWithGoogle() async {
    try {
      final success = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.spendra://login-callback',
      );
      return Success(success);
    } on AuthException catch (e, st) {
      return Failure(AuthFailure(e.message), stackTrace: st);
    } catch (e, st) {
      return Failure(AuthFailure(e.toString()), stackTrace: st);
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return const Success(null);
    } on AuthException catch (e, st) {
      return Failure(AuthFailure(e.message), stackTrace: st);
    } catch (e, st) {
      return Failure(AuthFailure(e.toString()), stackTrace: st);
    }
  }

  @override
  Future<Result<AppUser>> updateProfile({String? name}) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(
          data: name != null
              ? {'name': name.trim(), 'full_name': name.trim()}
              : null,
        ),
      );

      final user = response.user;
      if (user == null) {
        return const Failure(AuthFailure('Update profile failed: User is null'));
      }

      return Success(AppUser.fromSupabaseUser(user));
    } on AuthException catch (e, st) {
      return Failure(AuthFailure(e.message), stackTrace: st);
    } catch (e, st) {
      return Failure(AuthFailure(e.toString()), stackTrace: st);
    }
  }
}
