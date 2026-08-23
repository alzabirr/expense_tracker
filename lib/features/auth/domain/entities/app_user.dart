class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;

  /// Returns avatar url from Supabase / Google OAuth or email avatar service
  String? get photoUrl {
    if (avatarUrl != null && avatarUrl!.trim().isNotEmpty) {
      return avatarUrl!.trim();
    }
    if (email.isNotEmpty) {
      return 'https://unavatar.io/${email.trim().toLowerCase()}';
    }
    return null;
  }

  factory AppUser.fromSupabaseUser(dynamic user) {
    final metadata = user.userMetadata as Map<String, dynamic>? ?? {};
    final avatar = (metadata['avatar_url'] as String?) ??
        (metadata['picture'] as String?) ??
        (metadata['avatar'] as String?);

    return AppUser(
      id: user.id as String,
      email: (user.email as String?) ?? '',
      name: metadata['name'] as String? ?? metadata['full_name'] as String?,
      avatarUrl: avatar,
    );
  }
}
