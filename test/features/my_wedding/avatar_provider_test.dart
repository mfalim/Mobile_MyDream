import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:w51/app/providers/app_state_sync.dart';
import 'package:w51/core/storage/local_storage.dart';
import 'package:w51/core/storage/storage_keys.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/my_wedding/domain/repositories/avatar_repository.dart';
import 'package:w51/features/my_wedding/presentation/providers/avatar_provider.dart';

/// Menyalin ke folder sementara, seperti repository asli menyalin ke folder dokumen.
/// Menyalin ke folder sementara, seperti repository asli menyalin ke folder dokumen.
class _CopyRepo implements AvatarRepository {
  _CopyRepo(this.dir);

  final Directory dir;
  final removed = <String>[];
  final _firstRemoval = Completer<void>();
  int _n = 0;

  /// Selesai setelah penghapusan file pertama tuntas. IO file berjalan di
  /// luar antrean tes, jadi tes harus menunggu ini.
  Future<void> get firstRemoval => _firstRemoval.future;

  @override
  Future<String> save(String sourcePath) async {
    final target = File('${dir.path}/stored_${_n++}.jpg');
    await File(sourcePath).copy(target.path);
    return target.path;
  }

  @override
  Future<void> remove(String? storedPath) async {
    if (storedPath == null) return;
    removed.add(storedPath);
    try {
      final file = File(storedPath);
      if (await file.exists()) await file.delete();
    } finally {
      if (!_firstRemoval.isCompleted) _firstRemoval.complete();
    }
  }
}

void main() {
  late Directory dir;
  late File source;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('mydream_avatar_test');
    source = File('${dir.path}/source.jpg')..writeAsBytesSync([1, 2, 3]);
  });

  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  ProviderContainer launch(LocalStorage storage, _CopyRepo repo) {
    final container = ProviderContainer(
      overrides: [
        localStorageProvider.overrideWithValue(storage),
        avatarRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    container.read(appStateSyncProvider);
    return container;
  }

  test('mengganti foto menyimpannya dan dipulihkan di peluncuran berikutnya',
      () async {
    final storage = MemoryLocalStorage();
    final repo = _CopyRepo(dir);
    final first = launch(storage, repo);

    await first.read(avatarPathProvider.notifier).change(source.path);

    final path = first.read(avatarPathProvider)!;
    expect(File(path).existsSync(), isTrue);
    expect(storage.getString(kStorageAvatar), path);

    final second = launch(storage, repo);
    expect(second.read(avatarPathProvider), path);
  });

  test('foto yang diganti menghapus foto lama', () async {
    final repo = _CopyRepo(dir);
    final container = launch(MemoryLocalStorage(), repo);
    final avatar = container.read(avatarPathProvider.notifier);

    await avatar.change(source.path);
    final first = container.read(avatarPathProvider)!;
    await avatar.change(source.path);
    final second = container.read(avatarPathProvider)!;

    expect(second, isNot(first));
    expect(File(first).existsSync(), isFalse);
    expect(File(second).existsSync(), isTrue);
    expect(repo.removed, [first]);
  });

  test('menghapus foto: status, penyimpanan, dan file bersih', () async {
    final storage = MemoryLocalStorage();
    final container = launch(storage, _CopyRepo(dir));
    final avatar = container.read(avatarPathProvider.notifier);
    await avatar.change(source.path);
    final path = container.read(avatarPathProvider)!;

    await avatar.remove();

    expect(container.read(avatarPathProvider), isNull);
    expect(storage.getString(kStorageAvatar), isNull);
    expect(File(path).existsSync(), isFalse);
  });

  test('file yang sudah hilang dianggap tidak ada', () {
    final storage = MemoryLocalStorage();
    storage.setString(kStorageAvatar, '${dir.path}/tidak-ada.jpg');
    expect(launch(storage, _CopyRepo(dir)).read(avatarPathProvider), isNull);
  });

  test('keluar akun menghapus foto profil', () async {
    final storage = MemoryLocalStorage();
    final repo = _CopyRepo(dir);
    final container = launch(storage, repo);
    container.read(authProvider.notifier).signInDemo(email: 'dewi@mail.com');
    await container.read(avatarPathProvider.notifier).change(source.path);
    final path = container.read(avatarPathProvider)!;

    container.read(authProvider.notifier).signOut();

    // Status dan penyimpanan dibersihkan seketika.
    expect(container.read(avatarPathProvider), isNull);
    expect(storage.getString(kStorageAvatar), isNull);

    // File dihapus di latar belakang: tunggu sampai tuntas.
    await repo.firstRemoval.timeout(const Duration(seconds: 5));
    expect(File(path).existsSync(), isFalse);
  });
}
