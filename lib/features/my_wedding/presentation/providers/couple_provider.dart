import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/app/providers/api_providers.dart';
import 'package:w51/core/config/app_config.dart';
import 'package:w51/core/storage/local_storage.dart';
import 'package:w51/core/storage/storage_keys.dart';
import 'package:w51/features/my_wedding/data/couple_codec.dart';
import 'package:w51/features/my_wedding/domain/entities/couple_profile.dart';

/// Satu-satunya sumber nama dan tanggal pernikahan untuk semua layar.
/// `null` berarti belum diisi. Di mode data contoh disimpan di perangkat;
/// dengan API sungguhan dibaca dan disimpan lewat /me/couple.
/// `null` berarti belum diisi (di MySQL tabel `clients` belum ada).
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

  /// Simpan profil mempelai ke lokal dan ke server Laravel (`PUT /api/client/profile`).
  Future<void> save(CoupleProfile profile) async {
    final d = profile.weddingDate;
    final normalized = CoupleProfile(
      brideName: profile.brideName.trim(),
      groomName: profile.groomName.trim(),
      weddingDate: DateTime(d.year, d.month, d.day),
      bridePhone: profile.bridePhone?.trim(),
      groomPhone: profile.groomPhone?.trim(),
      email: profile.email?.trim(),
    );

    state = normalized;
    ref
        .read(localStorageProvider)
        .setJson(kStorageCouple, CoupleCodec.encode(normalized));

    if (!AppConfig.useMockData) {
      final token = await ref.read(tokenStorageProvider).read();
      if (token != null && token.isNotEmpty) {
        try {
          final client = ref.read(apiClientProvider);
          final emailVal = normalized.email?.trim() ?? '';
          final validEmail =
              emailVal.isNotEmpty && !emailVal.startsWith('@') ? emailVal : null;
          await client.put(
            '/client/profile',
            body: {
              'groom_name': normalized.groomName,
              'bride_name': normalized.brideName,
              'groom_phone': normalized.groomPhone ?? '',
              'bride_phone': normalized.bridePhone ?? '',
              if (validEmail != null) 'email': validEmail,
            },
          );
        } catch (_) {
          // Tetap tersimpan di lokal jika server offline
        }
      }
    }
  }

  /// Sinkronkan state dari data `client` yang dikembalikan oleh API Laravel (`/auth/google` atau `/me`).
  void syncFromServer(Map<String, dynamic>? clientJson, {required bool isClientRole}) {
    if (!isClientRole) return;
    if (clientJson == null) {
      state = null;
      return;
    }
    final mapped = CoupleCodec.fromApiClient(clientJson, existing: state);
    state = mapped;
  }

  void clear() => state = null;
}
