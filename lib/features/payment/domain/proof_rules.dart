import 'package:w51/core/utils/image_rules.dart';

/// Batas bukti transfer. Konservatif karena batas unggah bawaan PHP 2 MB;
/// nilai final mengikuti server.
const kMaxProofBytes = 2 * 1024 * 1024;
const kProofExtensions = kImageExtensions;

/// Mengembalikan pesan kesalahan, atau null bila file bukti transfer layak.
String? validateProofFile({required String name, required int bytes}) =>
    validateImageFile(name: name, bytes: bytes, maxBytes: kMaxProofBytes);
