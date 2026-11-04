import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/core/storage/local_storage.dart';
import 'package:w51/core/storage/storage_keys.dart';
import 'package:w51/core/utils/json_helpers.dart';

/// Id vendor yang disimpan pengguna. Disimpan di perangkat; dihapus saat keluar
/// akun. (Belum ada tabel bookmark di database, jadi hanya lokal.)
final savedVendorsProvider =
    NotifierProvider<SavedVendorsController, Set<String>>(
  SavedVendorsController.new,
);

class SavedVendorsController extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final json = ref.read(localStorageProvider).getJson(kStorageSavedVendors);
    if (json == null || json['v'] != kStorageVersion) return <String>{};
    final ids = json['ids'];
    return ids is List
        ? ids.map(jsonString).whereType<String>().toSet()
        : <String>{};
  }

  void toggle(String vendorId) {
    final next = {...state};
    if (!next.remove(vendorId)) next.add(vendorId);
    state = next;
    _save();
  }

  void clear() {
    state = <String>{};
    _save();
  }

  void _save() {
    final storage = ref.read(localStorageProvider);
    if (state.isEmpty) {
      storage.remove(kStorageSavedVendors);
    } else {
      storage.setJson(kStorageSavedVendors, {
        'v': kStorageVersion,
        'ids': state.toList(),
      });
    }
  }
}
