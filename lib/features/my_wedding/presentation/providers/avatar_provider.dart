import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/core/storage/local_storage.dart';
import 'package:w51/core/storage/storage_keys.dart';
import 'package:w51/features/my_wedding/data/avatar_local_repository.dart';
import 'package:w51/features/my_wedding/domain/repositories/avatar_repository.dart';

final avatarRepositoryProvider = Provider<AvatarRepository>(
  (ref) => const AvatarLocalRepository(),
);

/// Lokasi foto profil di perangkat; null = belum ada. Dihapus saat keluar akun.
final avatarPathProvider = NotifierProvider<AvatarController, String?>(
  AvatarController.new,
);

class AvatarController extends Notifier<String?> {
  @override
  String? build() {
    final path = ref.read(localStorageProvider).getString(kStorageAvatar);
    // File yang sudah tidak ada (mis. dibersihkan sistem) dianggap tidak ada.
    return (path != null && File(path).existsSync()) ? path : null;
  }

  /// Mengganti foto: menyimpan yang baru, lalu menghapus yang lama.
  Future<void> change(String sourcePath) async {
    final repository = ref.read(avatarRepositoryProvider);
    final old = state;
    final stored = await repository.save(sourcePath);
    state = stored;
    await ref.read(localStorageProvider).setString(kStorageAvatar, stored);
    if (old != null && old != stored) await repository.remove(old);
  }

  Future<void> remove() async {
    final old = state;
    state = null;
    await ref.read(localStorageProvider).remove(kStorageAvatar);
    await ref.read(avatarRepositoryProvider).remove(old);
  }
}
