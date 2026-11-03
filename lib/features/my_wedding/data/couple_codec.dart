import 'package:w51/core/storage/storage_keys.dart';
import 'package:w51/core/utils/json_helpers.dart';
import 'package:w51/features/my_wedding/domain/entities/couple_profile.dart';

abstract final class CoupleCodec {
  static String _two(int n) => n.toString().padLeft(2, '0');

  static Map<String, dynamic> encode(CoupleProfile c) => {
        'v': kStorageVersion,
        'bride_name': c.brideName,
        'groom_name': c.groomName,
        'wedding_date': '${c.weddingDate.year.toString().padLeft(4, '0')}-'
            '${_two(c.weddingDate.month)}-${_two(c.weddingDate.day)}',
      };

  static CoupleProfile? decode(Map<String, dynamic>? json) {
    if (json == null || json['v'] != kStorageVersion) return null;
    final bride = jsonString(json['bride_name']);
    final groom = jsonString(json['groom_name']);
    final raw = jsonString(json['wedding_date']);
    final date = raw == null ? null : DateTime.tryParse(raw);
    if (bride == null || groom == null || date == null) return null;
    return CoupleProfile(
      brideName: bride,
      groomName: groom,
      weddingDate: DateTime(date.year, date.month, date.day),
    );
  }
}
