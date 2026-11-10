class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.hasPassword = true,
    this.avatarUrl,
    this.role,
    this.callSign,
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

  /// Call Sign radio HT untuk akun dengan role 'member'.
  final String? callSign;

  AppUser copyWith({
    String? name,
    String? role,
    String? callSign,
  }) =>
      AppUser(
        id: id,
        name: name ?? this.name,
        email: email,
        hasPassword: hasPassword,
        avatarUrl: avatarUrl,
        role: role ?? this.role,
        callSign: callSign ?? this.callSign,
      );
}
