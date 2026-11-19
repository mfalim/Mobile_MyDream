class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    this.hasPassword = true,
    this.avatarUrl,
    this.role,
    this.callSign,
  });

  final String id;
  final String name;
  final String email;
  final String? username;

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
    String? username,
    String? role,
    String? callSign,
  }) =>
      AppUser(
        id: id,
        name: name ?? this.name,
        email: email,
        username: username ?? this.username,
        hasPassword: hasPassword,
        avatarUrl: avatarUrl,
        role: role ?? this.role,
        callSign: callSign ?? this.callSign,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          username == other.username &&
          hasPassword == other.hasPassword &&
          avatarUrl == other.avatarUrl &&
          role == other.role &&
          callSign == other.callSign;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        email,
        username,
        hasPassword,
        avatarUrl,
        role,
        callSign,
      );
}
