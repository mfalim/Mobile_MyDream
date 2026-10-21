import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_user.dart';

/// Status login. `null` berarti tamu (belum login).
final authProvider = NotifierProvider<AuthController, AppUser?>(
  AuthController.new,
);

class AuthController extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  /// PROTOTYPE: login palsu tanpa server. Nanti isi method ini diganti
  /// dengan Firebase / API; router dan layar tidak perlu berubah.
  void signInDemo({String? email}) {
    final mail = email ?? 'demo@example.com';
    state = AppUser(id: 'demo-user', name: mail.split('@').first, email: mail);
  }

  /// PROTOTYPE: pendaftaran palsu (belum disimpan di mana pun).
  void register({required String name, required String email}) {
    state = AppUser(id: 'demo-user', name: name, email: email);
  }

  void signOut() => state = null;
}
