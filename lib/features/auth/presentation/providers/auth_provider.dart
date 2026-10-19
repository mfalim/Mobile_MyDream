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
    state = AppUser(
      id: 'demo-user',
      name: 'Clarissa Wijaya',
      email: email ?? 'demo@example.com',
    );
  }

  void signOut() => state = null;
}
