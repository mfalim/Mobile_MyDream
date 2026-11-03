import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Tempat menyimpan token masuk. Token tidak boleh disimpan di penyimpanan
/// biasa (SharedPreferences atau file teks).
abstract interface class TokenStorage {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}

/// Keystore (Android) dan Keychain (iOS).
class SecureTokenStorage implements TokenStorage {
  const SecureTokenStorage([this._storage = const FlutterSecureStorage()]);

  static const _key = 'auth_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

/// Hanya di memori: untuk mode data contoh dan tes.
class MemoryTokenStorage implements TokenStorage {
  MemoryTokenStorage([this._token]);

  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}
