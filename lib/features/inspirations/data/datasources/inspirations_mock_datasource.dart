import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/features/inspirations/data/models/story_model.dart';
import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';

/// MOCK: meniru server (GET /articles dan GET /articles/{id}). Bukan data asli.
/// Cerita pertama berisi semua bagian opsional; tiga cerita lain berbentuk data
/// database (hanya kolom `articles`) untuk menguji tampilan minimal.
class InspirationsMockDatasource {
  Future<InspirationsData> fetch() async => InspirationsData(
        story: StoryModel.story(_stories.first),
        more: [for (final json in _stories.skip(1)) StoryModel.teaser(json)],
      );

  Future<RealWeddingStory> fetchStory(String id) async {
    final json = _stories.where((j) => j['id'] == id).firstOrNull;
    if (json == null) throw NotFoundException('story $id');
    return StoryModel.story(json);
  }

  static final List<Map<String, dynamic>> _stories = [
    {
      'id': 'story-dewi-dimas',
      'slug': 'pernikahan-intimate-uluwatu',
      'title':
          'Pernikahan Intimate Outdoor di Tebing Uluwatu: Kisah Dewi & Dimas',
      'category': 'Real Weddings',
      'tag': 'REAL LOVE STORY',
      'location': 'Uluwatu, Bali',
      'excerpt':
          'Balutan rona senja laut selatan, palet terakota berbisik lembut, '
              'dan sumpah suci di hadapan 45 kerabat terdekat.',
      'author': 'Dewi Mayangsari',
      'published_at': '2026-10-18',
      'read_minutes': 6,
      'hero_caption': 'Sora Visual Stories • Cliffside Edge Uluwatu',
      'stats': [
        {'label': 'Tamu', 'value': '45 Undangan'},
        {'label': 'Tema', 'value': 'Ocean Boho'},
        {'label': 'Waktu', 'value': 'Sunset Ritual'},
      ],
      'content':
          'Menyelenggarakan pernikahan berlatar Samudra Hindia selalu menjadi '
              'mimpi bersama sejak pertama kali kami bertualang ke tebing selatan '
              'Bali. Bagi kami, kemewahan sejati bukanlah pesta megah ribuan '
              'undangan, melainkan kehangatan saat setiap hembusan angin laut '
              'membawa doa dari orang-orang tersayang.',
      'quote':
          '“Sinar matahari terbenam menyentuh debur ombak persis saat kami '
              'bertukar cincin. Semuanya hening, hangat, dan abadi.”',
      'gallery': [
        {'caption': 'Gaun custom hand-beaded french lace'},
        {'caption': 'Meja perjamuan twilight candles'},
        {'caption': 'Altar tebing saat golden hour'},
      ],
      'vendors_title': 'Vendor Pilihan Dewi & Dimas',
      'vendors': [
        {
          'name': 'Mattana Wedding Planner',
          'role': 'Wedding Organizer • Bali',
          'rating': 4.9,
          'review_count': 128,
          'kind': 'planner',
        },
        {
          'name': 'Vivaldi Decor Atelier',
          'role': 'Floral & Space Design',
          'rating': 4.9,
          'review_count': 160,
          'kind': 'decor',
        },
        {
          'name': 'Sora Visual Stories',
          'role': 'Dokumentasi & Cinematic Film',
          'rating': 4.9,
          'review_count': 142,
          'kind': 'photographer',
        },
      ],
      'tips_title': 'Tips Khusus Menikah di Cuaca Tebing Pantai',
      'tips': [
        'Pilih waktu akad pukul 16:30 WITA: panas terik matahari tropis '
            'telah melunak dan menghasilkan pencahayaan keemasan sempurna '
            'untuk foto tanpa squinting.',
        'Sediakan Refreshment Bar Dingin: coconut water infused lemongrass '
            'untuk tamu saat baru tiba menyegarkan hawa terik pesisir.',
        'Struktur Bunga Berbobot Berat: angin tebing Uluwatu sangat kencang '
            'di sore hari; minta dekorator menyematkan pemberat tak kasat '
            'mata pada garland altar.',
      ],
      'likes': 384,
      'reads': 1842,
      'package_id': 'pkg-intimate-bali',
    },
    // Berbentuk data database asli: hanya kolom tabel `articles`.
    {
      'id': 'story-uang-panai',
      'slug': 'makna-uang-japuik-uang-panai',
      'title': 'Mengenal Makna Uang Japuik & Uang Panai dalam Keanggunan Adat',
      'category': 'Tradisi & Adat',
      'excerpt': 'Dua tradisi pemberian dalam pernikahan adat Nusantara.',
      'content': 'Dalam banyak adat Nusantara, pernikahan tidak hanya menyatukan dua '
          'orang, tetapi juga dua keluarga. Salah satu wujudnya adalah '
          'pemberian yang disepakati kedua pihak.\n\n'
          'Uang japuik dikenal dalam adat Minangkabau, khususnya di Pariaman, '
          'sebagai pemberian dari pihak perempuan kepada pihak laki-laki. '
          'Uang panai dikenal dalam adat Bugis-Makassar sebagai pemberian dari '
          'pihak laki-laki kepada keluarga perempuan untuk membantu kebutuhan '
          'pesta pernikahan.\n\n'
          'Besarnya nilai dan tata caranya berbeda di tiap daerah dan keluarga, '
          'sehingga paling baik dibicarakan lebih dulu bersama para tetua dan '
          'keluarga kedua pihak.',
      'photo': null,
      'author': 'Tim MyDream',
      'published_at': '2026-10-05',
      'reads': 412,
      'package_id': null,
    },
    {
      'id': 'story-veil',
      'slug': 'tips-memilih-wedding-veil',
      'title':
          '8 Tips Memilih Wedding Veil yang Tepat untuk Menyempurnakan Siluet',
      'category': 'Bridal Fashion',
      'excerpt':
          'Panjang veil memengaruhi tampilan gaun dari kepala hingga kaki.',
      'content': 'Veil memengaruhi tampilan gaun dari ujung kepala hingga kaki. Pilih '
          'panjangnya setelah menentukan siluet gaun.\n\n'
          'Blusher menutupi wajah dan cocok untuk prosesi singkat. Fingertip '
          'mencapai ujung jari dan mudah dipakai di hampir semua gaun. Chapel '
          'dan cathedral menjuntai panjang di belakang dan paling indah untuk '
          'gaun berekor serta lorong yang luas.\n\n'
          'Coba beberapa panjang saat fitting dan minta foto dari depan, '
          'samping, dan belakang sebelum memutuskan.',
      'photo': null,
      'author': 'Tim MyDream',
      'published_at': '2026-09-28',
      'reads': 920,
      'package_id': null,
    },
    {
      'id': 'story-pinus',
      'slug': 'kisah-nadia-reza-dataran-tinggi',
      'title':
          'Sejuk Kabut Hutan Pinus: Kisah Pernikahan Nadia & Reza di Dataran Tinggi',
      'category': 'Highland Dream',
      'excerpt': 'Janji yang diucapkan di antara pohon pinus dan kabut tipis.',
      'content': 'Kabut tipis turun perlahan ketika Nadia dan Reza bertukar janji di '
          'antara pohon pinus. Hanya 60 tamu yang hadir, semuanya mengenakan '
          'warna tanah yang senada dengan hutan.\n\n'
          'Tim dekorasi memakai ranting kering dan bunga liar agar suasananya '
          'menyatu dengan alam. Untuk menjaga tamu tetap hangat, panitia '
          'menyiapkan selimut kecil dan minuman jahe hangat.\n\n'
          'Resepsi ditutup dengan api unggun kecil dan lagu-lagu akustik hingga '
          'malam.',
      'photo': null,
      'author': 'Tim MyDream',
      'published_at': '2026-09-21',
      'reads': 1400,
      'package_id': 'pkg-garden-jakarta',
    },
  ];
}
