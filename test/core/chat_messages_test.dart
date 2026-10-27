import 'package:flutter_test/flutter_test.dart';
import 'package:w51/core/utils/chat_messages.dart';

void main() {
  test('pesan vendor memuat nama, kategori, dan tanggal bila ada', () {
    final withDate = vendorInquiryMessage(
      vendorName: 'Sora Visual Stories',
      category: 'Photography',
      weddingDate: DateTime(2026, 10, 24),
    );
    expect(withDate, contains('Sora Visual Stories'));
    expect(withDate, contains('Photography'));
    expect(withDate, contains('Sabtu, 24 Oktober 2026'));

    final noDate = vendorInquiryMessage(
      vendorName: 'Sora Visual Stories',
      category: 'Photography',
    );
    expect(noDate, isNot(contains('Rencana pernikahan')));
  });

  test('pesan admin: topik kosong memakai kalimat umum', () {
    expect(adminInquiryMessage(), contains('layanan Aura Wedding'));
    expect(adminInquiryMessage(topic: '   '), contains('layanan Aura Wedding'));
    expect(
      adminInquiryMessage(topic: ' Paket Intimate Bali '),
      contains('tentang Paket Intimate Bali.'),
    );
  });
}
