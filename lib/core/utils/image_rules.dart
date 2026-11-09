const kMaxImageBytes = 2 * 1024 * 1024;
const kImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];

/// Mengembalikan pesan kesalahan, atau null bila file gambar layak.
String? validateImageFile({
  required String name,
  required int bytes,
  int maxBytes = kMaxImageBytes,
}) {
  final dot = name.lastIndexOf('.');
  final ext = dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
  if (!kImageExtensions.contains(ext)) {
    return 'Format file harus JPG, PNG, atau WEBP.';
  }
  if (bytes <= 0) return 'File kosong atau tidak bisa dibaca.';
  if (bytes > maxBytes) {
    final limit = (maxBytes / (1024 * 1024)).toStringAsFixed(0);
    final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
    return 'Ukuran file maksimal $limit MB (file ini $mb MB).';
  }
  return null;
}
