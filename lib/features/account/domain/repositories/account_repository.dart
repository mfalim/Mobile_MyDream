abstract interface class AccountRepository {
  /// Menyimpan nama baru; mengembalikan nama yang tersimpan (sudah dirapikan).
  /// Melempar `ValidationException` bila ditolak server.
  Future<String> updateName(String name);

  Future<void> changePassword({
    required String current,
    required String password,
  });
}
