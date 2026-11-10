abstract interface class AvatarRepository {
  /// Menyimpan foto yang dipilih dan mengembalikan lokasinya: path lokal
  /// sekarang, nanti URL dari server setelah diunggah (POST /me/avatar).
  Future<String> save(String sourcePath);

  /// Menghapus foto yang tersimpan.
  Future<void> remove(String? storedPath);
}
