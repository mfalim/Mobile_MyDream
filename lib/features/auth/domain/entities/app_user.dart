class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.hasPassword = true,
  });

  final String id;
  final String name;
  final String email;

  /// False untuk akun yang masuk lewat Google (tidak punya kata sandi).
  final bool hasPassword;

  AppUser copyWith({String? name}) => AppUser(
        id: id,
        name: name ?? this.name,
        email: email,
        hasPassword: hasPassword,
      );
}
