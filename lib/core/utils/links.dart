/// Tautan profil Instagram dari "@nama", "nama", atau tautan instagram.com.
/// Mengembalikan null bila bukan nama pengguna Instagram yang valid atau
/// tautannya ke situs lain.
Uri? instagramUri(String raw) {
  var v = raw.trim();
  if (v.isEmpty) return null;

  final fromUrl = RegExp(
    r'^(?:https?://)?(?:www\.)?instagram\.com/([^/?#\s]+)',
    caseSensitive: false,
  ).firstMatch(v);
  if (fromUrl != null) {
    v = fromUrl.group(1) ?? '';
  } else if (v.contains('/') || v.contains(':')) {
    return null;
  }

  v = v.replaceFirst(RegExp(r'^@'), '');
  if (!RegExp(r'^[A-Za-z0-9._]{1,30}$').hasMatch(v)) return null;
  return Uri.https('instagram.com', '/$v');
}
