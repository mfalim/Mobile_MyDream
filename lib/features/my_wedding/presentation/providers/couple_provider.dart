import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/core/config/app_config.dart';
import 'package:w51/core/storage/local_storage.dart';
import 'package:w51/core/storage/storage_keys.dart';
import 'package:w51/features/my_wedding/data/couple_codec.dart';
import 'package:w51/features/my_wedding/domain/entities/couple_profile.dart';

/// Satu-satunya sumber nama dan tanggal pernikahan untuk semua layar.
/// `null` berarti belum diisi. Di mode data contoh disimpan di perangkat;
/// dengan API sungguhan dibaca dan disimpan lewat /me/couple.
final coupleProvider = NotifierProvider<CoupleController, CoupleProfile?>(
  CoupleController.new,
);

class CoupleController extends Notifier<CoupleProfile?> {
  @override
  CoupleProfile? build() {
    if (!AppConfig.useMockData) return null;
    return CoupleCodec.decode(
      ref.read(localStorageProvider).getJson(kStorageCouple),
    );
  }

  /// Spasi di tepi nama dan jam pada tanggal dibuang.
  void save(CoupleProfile profile) {
    final d = profile.weddingDate;
    state = CoupleProfile(
      brideName: profile.brideName.trim(),
      groomName: profile.groomName.trim(),
      weddingDate: DateTime(d.year, d.month, d.day),
    );
  }

  void clear() => state = null;
}
