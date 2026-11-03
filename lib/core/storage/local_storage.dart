import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Penyimpanan kunci-nilai sederhana di perangkat, untuk data yang boleh
/// terlihat (keranjang, data pasangan). Token masuk TIDAK boleh disimpan di
/// sini; pakai TokenStorage (penyimpanan aman).
abstract interface class LocalStorage {
  String? getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
}

class SharedPrefsStorage implements LocalStorage {
  const SharedPrefsStorage(this._prefs);

  final SharedPreferences _prefs;

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}

/// Hanya di memori: bawaan untuk tes.
class MemoryLocalStorage implements LocalStorage {
  final Map<String, String> _data = {};

  @override
  String? getString(String key) => _data[key];

  @override
  Future<void> setString(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _data.remove(key);
  }
}

extension LocalStorageJson on LocalStorage {
  /// Objek JSON yang tersimpan; null bila belum ada atau rusak.
  Map<String, dynamic>? getJson(String key) {
    final raw = getString(key);
    if (raw == null) return null;
    try {
      final value = jsonDecode(raw);
      return value is Map<String, dynamic> ? value : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> setJson(String key, Map<String, dynamic> value) =>
      setString(key, jsonEncode(value));
}

/// Bawaan di memori (tes). main.dart menggantinya dengan penyimpanan perangkat.
final localStorageProvider = Provider<LocalStorage>(
  (ref) => MemoryLocalStorage(),
);
