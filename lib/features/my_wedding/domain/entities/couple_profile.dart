class CoupleProfile {
  const CoupleProfile({
    required this.brideName,
    required this.groomName,
    required this.weddingDate,
    this.bridePhone,
    this.groomPhone,
    this.email,
  });

  final String brideName;
  final String groomName;
  final DateTime weddingDate;
  final String? bridePhone;
  final String? groomPhone;
  final String? email;

  /// "Clarissa & Adrian" (nama depan keduanya), untuk kartu Home.
  String get shortNames => '${_first(brideName)} & ${_first(groomName)}';

  /// "Clarissa Wijaya & Adrian" (nama lengkap wanita, nama depan pria),
  /// untuk header Profil.
  String get profileNames => '$brideName & ${_first(groomName)}';

  static String _first(String name) => name.trim().split(RegExp(r'\s+')).first;
}
