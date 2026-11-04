import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:w51/features/my_wedding/domain/repositories/avatar_repository.dart';

/// Menyimpan foto profil di folder dokumen aplikasi. Foto dari pemilih foto
/// ada di folder sementara yang bisa dihapus sistem, jadi disalin dulu.
class AvatarLocalRepository implements AvatarRepository {
  const AvatarLocalRepository();

  @override
  Future<String> save(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final dot = sourcePath.lastIndexOf('.');
    final raw = dot < 0 ? '' : sourcePath.substring(dot + 1).toLowerCase();
    final ext = RegExp(r'^[a-z0-9]{1,5}$').hasMatch(raw) ? raw : 'jpg';
    final target = File(
      '${dir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.$ext',
    );
    await File(sourcePath).copy(target.path);
    return target.path;
  }

  @override
  Future<void> remove(String? storedPath) async {
    if (storedPath == null) return;
    try {
      final file = File(storedPath);
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      // Sudah hilang atau tidak bisa dihapus: bukan alasan untuk gagal.
    }
  }
}
