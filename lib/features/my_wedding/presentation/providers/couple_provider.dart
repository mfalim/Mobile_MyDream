import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/app/providers/api_providers.dart';
import 'package:w51/core/config/app_config.dart';
import 'package:w51/core/storage/local_storage.dart';
import 'package:w51/core/storage/storage_keys.dart';
import 'package:w51/features/my_wedding/data/couple_codec.dart';
import 'package:w51/features/my_wedding/domain/entities/couple_profile.dart';

/// Satu-satunya sumber nama dan tanggal pernikahan untuk semua layar.
/// `null` berarti belum diisi. Di mode data contoh disimpan di perangkat;
/// dengan API sungguhan dibaca dan disimpan lewat /client/profile.
final coupleProvider = NotifierProvider<CoupleController, CoupleProfile?>(
  CoupleController.new,
);

class CoupleController extends Notifier<CoupleProfile?> {
  @override
  CoupleProfile? build() {
    return CoupleCodec.decode(
      ref.read(localStorageProvider).getJson(kStorageCouple),
    );
  }

  /// Sinkronkan profil dari data MySQL (tabel `clients`).
  void syncFromServer(Map<String, dynamic>? clientData, {required bool isClientRole}) {
    if (!isClientRole || clientData == null) {
      if (!isClientRole) state = null;
      return;
    }
    final profile = CoupleCodec.fromApiClient(clientData, existing: state);
    if (profile != null) {
      state = profile;
      ref
          .read(localStorageProvider)
          .setJson(kStorageCouple, CoupleCodec.encode(profile));
    }
  }

  /// Simpan data mempelai baik lokal maupun ke API Laravel (`/client/profile`).
  Future<void> save(CoupleProfile profile) async {
    final d = profile.weddingDate;
    final updated = CoupleProfile(
      brideName: profile.brideName.trim(),
      groomName: profile.groomName.trim(),
      bridePhone: profile.bridePhone?.trim(),
      groomPhone: profile.groomPhone?.trim(),
      email: profile.email?.trim(),
      weddingDate: DateTime(d.year, d.month, d.day),
    );

    state = updated;
    ref
        .read(localStorageProvider)
        .setJson(kStorageCouple, CoupleCodec.encode(updated));

    // Jika mode API dan user login sebagai client, kirim ke PUT /client/profile
    if (!AppConfig.useMockData) {
      final token = await ref.read(tokenStorageProvider).read();
      if (token != null && token.isNotEmpty) {
        try {
          final client = ref.read(apiClientProvider);
          await client.put(
            '/client/profile',
            body: {
              'groom_name': updated.groomName,
              'bride_name': updated.brideName,
              'groom_phone': updated.groomPhone ?? '',
              'bride_phone': updated.bridePhone ?? '',
              'email': updated.email ?? '',
            },
          );
        } catch (_) {
          // Tetap tersimpan di lokal jika server offline
        }
      }
    }
  }

  void clear() => state = null;
}
