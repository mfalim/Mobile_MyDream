class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.hasPassword = true,
    this.avatarUrl,
    this.role,
  });

  final String id;
  final String name;
  final String email;

  /// False untuk akun yang masuk lewat Google (tidak punya kata sandi).
  final bool hasPassword;

  /// URL foto akun; null memakai ikon bawaan.
  final String? avatarUrl;

  /// Role dari Laravel: 'client', 'member', 'admin', 'vendor'.
  final String? role;

  AppUser copyWith({String? name, String? role}) => AppUser(
        id: id,
        name: name ?? this.name,
        email: email,
        hasPassword: hasPassword,
        avatarUrl: avatarUrl,
        role: role ?? this.role,
      );
}
