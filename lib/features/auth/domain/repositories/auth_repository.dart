import 'package:spendra/core/utils/result.dart';
import 'package:spendra/features/auth/domain/entities/app_user.dart';

abstract interface class AuthRepository {
  /// Stream of current user's authentication state.
  Stream<AppUser?> authStateChanges();

  /// Gets the currently authenticated user (if any).
  AppUser? get currentUser;

  /// Whether a user is currently logged in.
  bool get isAuthenticated;

  /// Signs up with email, password, and optional full name.
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    String? name,
  });

  /// Signs in with email and password.
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  });

  /// Sends a password reset email.
  Future<Result<void>> resetPassword(String email);

  /// Signs in using Google OAuth.
  Future<Result<bool>> signInWithGoogle();

  /// Signs out the current user.
  Future<Result<void>> signOut();

  /// Updates user profile information (such as display name).
  Future<Result<AppUser>> updateProfile({String? name});
}
