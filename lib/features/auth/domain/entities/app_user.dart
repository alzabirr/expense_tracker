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

  factory AppUser.fromSupabaseUser(dynamic user) {
    final metadata = user.userMetadata as Map<String, dynamic>? ?? {};
    return AppUser(
      id: user.id as String,
      email: (user.email as String?) ?? '',
      name: metadata['name'] as String? ?? metadata['full_name'] as String?,
      avatarUrl: metadata['avatar_url'] as String?,
    );
  }
}
