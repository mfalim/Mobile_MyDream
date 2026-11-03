class CoupleProfile {
  const CoupleProfile({
    required this.brideName,
    required this.groomName,
    required this.weddingDate,
  });

  final String brideName;
  final String groomName;
  final DateTime weddingDate;

  /// "Clarissa & Adrian" (nama depan keduanya), untuk kartu Home.
  String get shortNames => '${_first(brideName)} & ${_first(groomName)}';

  /// "Clarissa Wijaya & Adrian" (nama lengkap wanita, nama depan pria),
  /// untuk header Profil.
  String get profileNames => '$brideName & ${_first(groomName)}';

  static String _first(String name) => name.trim().split(RegExp(r'\s+')).first;
}
