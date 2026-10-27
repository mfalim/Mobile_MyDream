import 'package:w51/core/utils/formatters.dart';

String _datePart(DateTime? date) =>
    date == null ? '' : ' Rencana pernikahan saya: ${formatDateId(date)}.';

/// Pesan awal ke vendor.
String vendorInquiryMessage({
  required String vendorName,
  required String category,
  DateTime? weddingDate,
}) =>
    'Halo $vendorName, saya melihat layanan $category Anda di aplikasi '
    'Aura Wedding.${_datePart(weddingDate)} Apakah masih tersedia dan boleh '
    'saya tahu detail paketnya? Terima kasih.';

/// Pesan awal ke admin; [topic] boleh kosong.
String adminInquiryMessage({String? topic, DateTime? weddingDate}) {
  final subject = (topic == null || topic.trim().isEmpty)
      ? 'layanan Aura Wedding'
      : topic.trim();
  return 'Halo Admin Aura Wedding, saya ingin bertanya tentang '
      '$subject.${_datePart(weddingDate)} Terima kasih.';
}
