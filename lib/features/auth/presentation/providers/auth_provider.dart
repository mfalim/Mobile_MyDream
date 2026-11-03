import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/core/config/app_config.dart';
import 'package:w51/core/storage/local_storage.dart';
import 'package:w51/core/storage/storage_keys.dart';
import 'package:w51/features/auth/data/user_codec.dart';

import '../../domain/entities/app_user.dart';

/// Status login. `null` berarti tamu (belum login).
final authProvider = NotifierProvider<AuthController, AppUser?>(
  AuthController.new,
);

class AuthController extends Notifier<AppUser?> {
  @override
  AppUser? build() {
    // PROTOTYPE: sesi palsu ikut tersimpan supaya tidak masuk ulang di tiap
    // peluncuran. Dengan API sungguhan, sesi dipulihkan dari token (penyimpanan
    // aman) dan GET /me, bukan dari sini.
    if (!AppConfig.useMockData) return null;
    return UserCodec.decode(
        ref.read(localStorageProvider).getJson(kStorageUser));
  }

  /// PROTOTYPE: login palsu tanpa server. Nanti isi method ini diganti
  /// dengan API; router dan layar tidak perlu berubah.
  void signInDemo({String? email, bool viaGoogle = false}) {
    final mail = email ?? 'demo@example.com';
    state = AppUser(
      id: 'demo-user',
      name: mail.split('@').first,
      email: mail,
      hasPassword: !viaGoogle,
    );
  }

  /// PROTOTYPE: pendaftaran palsu (belum disimpan di server).
  void register({required String name, required String email}) {
    state = AppUser(id: 'demo-user', name: name, email: email);
  }

  void updateName(String name) {
    final user = state;
    if (user == null) return;
    state = user.copyWith(name: name);
  }

  void signOut() => state = null;
}
