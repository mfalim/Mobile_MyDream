import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/features/my_wedding/domain/entities/couple_profile.dart';

/// Satu-satunya sumber nama dan tanggal pernikahan untuk semua layar.
/// `null` berarti belum diisi. Saat ini hanya di memori (prototype);
/// nanti dibaca dan disimpan lewat API.
final coupleProvider = NotifierProvider<CoupleController, CoupleProfile?>(
  CoupleController.new,
);

class CoupleController extends Notifier<CoupleProfile?> {
  @override
  CoupleProfile? build() => null;

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
