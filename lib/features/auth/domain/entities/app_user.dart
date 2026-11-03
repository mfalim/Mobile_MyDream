class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.hasPassword = true,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;

  /// False untuk akun yang masuk lewat Google (tidak punya kata sandi).
  final bool hasPassword;

  /// URL foto akun; null memakai ikon bawaan.
  final String? avatarUrl;

  AppUser copyWith({String? name}) => AppUser(
        id: id,
        name: name ?? this.name,
        email: email,
        hasPassword: hasPassword,
        avatarUrl: avatarUrl,
      );
}
