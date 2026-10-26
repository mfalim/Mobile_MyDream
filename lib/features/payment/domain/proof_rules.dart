/// Batas bukti transfer. Konservatif karena batas unggah bawaan PHP 2 MB;
/// nilai final mengikuti server.
const kMaxProofBytes = 2 * 1024 * 1024;
const kProofExtensions = ['jpg', 'jpeg', 'png', 'webp'];

/// Mengembalikan pesan kesalahan, atau null bila file bukti transfer layak.
String? validateProofFile({required String name, required int bytes}) {
  final dot = name.lastIndexOf('.');
  final ext = dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
  if (!kProofExtensions.contains(ext)) {
    return 'Format file harus JPG, PNG, atau WEBP.';
  }
  if (bytes <= 0) return 'File kosong atau tidak bisa dibaca.';
  if (bytes > kMaxProofBytes) {
    final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
    return 'Ukuran file maksimal 2 MB (file ini $mb MB).';
  }
  return null;
}
