import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';

/// MOCK DATA: contoh untuk prototype, BUKAN data dari server.
class InspirationsMockDatasource {
  Future<InspirationsData> fetch() async {
    return const InspirationsData(
      story: RealWeddingStory(
        id: 'story-dewi-dimas',
        tag: 'REAL LOVE STORY',
        location: 'Uluwatu, Bali',
        title:
            'Pernikahan Intimate Outdoor di Tebing Uluwatu: Kisah Dewi & Dimas',
        excerpt:
            'Balutan rona senja laut selatan, palet terakota berbisik lembut, '
            'dan sumpah suci di hadapan 45 kerabat terdekat.',
        authorName: 'Dewi Mayangsari',
        publishedLabel: '18 Okt 2026',
        readMinutes: 6,
        heroCaption: 'Sora Visual Stories • Cliffside Edge Uluwatu',
        stats: [
          StoryStat(label: 'Tamu', value: '45 Undangan'),
          StoryStat(label: 'Tema', value: 'Ocean Boho'),
          StoryStat(label: 'Waktu', value: 'Sunset Ritual'),
        ],
        body:
            'Menyelenggarakan pernikahan berlatar Samudra Hindia selalu menjadi '
            'mimpi bersama sejak pertama kali kami bertualang ke tebing selatan '
            'Bali. Bagi kami, kemewahan sejati bukanlah pesta megah ribuan '
            'undangan, melainkan kehangatan saat setiap hembusan angin laut '
            'membawa doa dari orang-orang tersayang.',
        quote:
            '“Sinar matahari terbenam menyentuh debur ombak persis saat kami '
            'bertukar cincin. Semuanya hening, hangat, dan abadi.”',
        photoCaptions: [
          'Gaun custom hand-beaded french lace',
          'Meja perjamuan twilight candles',
          'Altar tebing saat golden hour',
        ],
        vendorsTitle: 'Vendor Pilihan Dewi & Dimas',
        vendors: [
          StoryVendor(
            name: 'Mattana Wedding Planner',
            role: 'Wedding Organizer • Bali',
            rating: 4.9,
            reviewCount: 128,
            kind: StoryVendorKind.planner,
          ),
          StoryVendor(
            name: 'Vivaldi Decor Atelier',
            role: 'Floral & Space Design',
            rating: 5.0,
            reviewCount: 94,
            kind: StoryVendorKind.decor,
          ),
          StoryVendor(
            name: 'Sora Visual Stories',
            role: 'Dokumentasi & Cinematic Film',
            rating: 4.9,
            reviewCount: 150,
            kind: StoryVendorKind.photographer,
          ),
        ],
        tipsTitle: 'Tips Khusus Menikah di Cuaca Tebing Pantai',
        tips: [
          'Pilih waktu akad pukul 16:30 WITA: panas terik matahari tropis '
              'telah melunak dan menghasilkan pencahayaan keemasan sempurna '
              'untuk foto tanpa squinting.',
          'Sediakan Refreshment Bar Dingin: coconut water infused lemongrass '
              'untuk tamu saat baru tiba menyegarkan hawa terik pesisir.',
          'Struktur Bunga Berbobot Berat: angin tebing Uluwatu sangat kencang '
              'di sore hari; minta dekorator menyematkan pemberat tak kasat '
              'mata pada garland altar.',
        ],
        likes: 384,
        reads: 1842,
      ),
      more: [
        StoryTeaser(
          id: 'story-uang-panai',
          category: 'Tradisi & Adat',
          title:
              'Mengenal Makna Uang Japuik & Uang Panai dalam Keanggunan Adat',
          dateLabel: '5 Okt 2026',
          reads: 412,
        ),
        StoryTeaser(
          id: 'story-veil',
          category: 'Bridal Fashion',
          title: '8 Tips Memilih Wedding Veil yang Tepat untuk Menyempurnakan '
              'Siluet',
          dateLabel: '28 Sep 2026',
          reads: 920,
        ),
        StoryTeaser(
          id: 'story-pinus',
          category: 'Highland Dream',
          title: 'Sejuk Kabut Hutan Pinus: Kisah Pernikahan Nadia & Reza di '
              'Dataran Tinggi',
          dateLabel: '21 Sep 2026',
          reads: 1400,
        ),
      ],
    );
  }
}
