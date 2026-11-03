import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/features/info/domain/entities/info_document.dart';

/// MOCK: teks contoh untuk prototype, BUKAN ketentuan resmi. Teks resmi
/// nanti diisi oleh tim dan diambil dari server.
class InfoMockDatasource {
  Future<InfoDocument> fetch(String slug) async {
    final doc = _documents[slug];
    if (doc == null) throw NotFoundException('info $slug');
    return doc;
  }

  static const _documents = <String, InfoDocument>{
    'terms': InfoDocument(
      slug: 'terms',
      title: 'Syarat & Ketentuan Layanan',
      updatedLabel: 'Contoh • belum resmi',
      sections: [
        InfoSection(
          heading: 'Penggunaan layanan',
          body: 'Bagian ini akan menjelaskan siapa yang boleh memakai aplikasi '
              'dan apa yang diperbolehkan.',
        ),
        InfoSection(
          heading: 'Pemesanan dan pembayaran',
          body: 'Bagian ini akan menjelaskan alur pemesanan, uang muka, '
              'pelunasan, dan metode pembayaran.',
        ),
        InfoSection(
          heading: 'Perubahan dan pembatalan',
          body: 'Bagian ini akan menjelaskan aturan perubahan jadwal dan '
              'pembatalan pesanan.',
        ),
      ],
    ),
    'guarantee': InfoDocument(
      slug: 'guarantee',
      title: 'Ketentuan Garansi Aman',
      updatedLabel: 'Contoh • belum resmi',
      sections: [
        InfoSection(
          heading: 'Escrow protection',
          body: 'Dana pembayaran disimpan di rekening bersama dan baru '
              'diteruskan ke vendor sesuai progres pekerjaan.',
        ),
        InfoSection(
          heading: 'Garansi tanggal dan uang muka',
          body: 'Bagian ini akan menjelaskan perlindungan tanggal acara dan '
              'syarat pengembalian uang muka.',
        ),
        InfoSection(
          heading: 'Pengajuan keluhan',
          body: 'Bagian ini akan menjelaskan cara melapor dan batas waktu '
              'penanganannya.',
        ),
      ],
    ),
    'privacy': InfoDocument(
      slug: 'privacy',
      title: 'Kebijakan Privasi',
      updatedLabel: 'Contoh • belum resmi',
      sections: [
        InfoSection(
          heading: 'Data yang dikumpulkan',
          body: 'Bagian ini akan menjelaskan data apa saja yang diminta '
              'aplikasi dan untuk apa.',
        ),
        InfoSection(
          heading: 'Penyimpanan dan keamanan',
          body: 'Bagian ini akan menjelaskan bagaimana data disimpan dan '
              'dilindungi.',
        ),
      ],
    ),
  };
}
