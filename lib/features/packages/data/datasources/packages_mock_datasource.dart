import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/features/packages/data/models/wedding_package_model.dart';
import 'package:w51/features/packages/domain/entities/wedding_package.dart';

/// MOCK: meniru jawaban server (GET /packages dan GET /packages/{id}).
/// Bukan data asli. Nama vendor dan harganya sama dengan daftar vendor
/// contoh (tes memeriksanya). Kolom `price` meniru harga yang nanti
/// ditetapkan admin lewat API.
class PackagesMockDatasource {
  Future<List<WeddingPackage>> fetchAll() async => [
        for (final json in _packages) WeddingPackageModel.fromJson(json),
      ];

  Future<WeddingPackage> fetch(String id) async {
    final json = _packages.where((p) => p['id'] == id).firstOrNull;
    if (json == null) throw NotFoundException('package $id');
    return WeddingPackageModel.fromJson(json);
  }

  static final List<Map<String, dynamic>> _packages = [
    {
      'id': 'pkg-intimate-bali',
      'slug': 'paket-intimate-bali',
      'name': 'Paket Intimate Bali',
      'description':
          'Pernikahan intimate dengan perencana, dokumentasi, rias pengantin, '
              'dan katering dalam satu paket.',
      'availability_date': '2027-03-31',
      'duration': 8.0,
      'event_period': 'Akad & Resepsi',
      'guest_capacity': 100,
      'is_featured': true,
      'price': 95000000,
      'vendors': [
        {
          'id': 'vendor-mattana',
          'name': 'Mattana Wedding Planner',
          'category': 'Wedding Planner',
          'city': 'Bali',
          'price': 45000000,
        },
        {
          'id': 'vendor-sora',
          'name': 'Sora Visual Stories',
          'category': 'Photography',
          'city': 'Bali',
          'price': 18500000,
        },
        {
          'id': 'vendor-ethereal',
          'name': 'Ethereal Glow Bridal MUA',
          'category': 'Hair & Makeup',
          'city': 'Jakarta',
          'price': 21000000,
        },
        {
          'id': 'vendor-santap',
          'name': 'Santap Rasa Catering',
          'category': 'Catering',
          'city': 'Jakarta & Bali',
          'price': 17500000,
        },
      ],
    },
    {
      'id': 'pkg-grand-uluwatu',
      'slug': 'paket-grand-venue-uluwatu',
      'name': 'Paket Grand Venue Uluwatu',
      'description':
          'Venue tebing Uluwatu lengkap dengan dekorasi, dokumentasi, dan '
              'perencana acara.',
      'availability_date': '2027-06-30',
      'duration': 10.0,
      'event_period': 'Resepsi',
      'guest_capacity': 250,
      'is_featured': true,
      'price': 199000000,
      'vendors': [
        {
          'id': 'vendor-glasshouse',
          'name': 'The Glasshouse Cliff Sanctuary',
          'category': 'Venue',
          'city': 'Bali',
          'price': 85000000,
        },
        {
          'id': 'vendor-vivaldi',
          'name': 'Vivaldi Floral & Scenery',
          'category': 'Decoration',
          'city': 'Jakarta & Bali',
          'price': 65000000,
        },
        {
          'id': 'vendor-sora',
          'name': 'Sora Visual Stories',
          'category': 'Photography',
          'city': 'Bali',
          'price': 18500000,
        },
        {
          'id': 'vendor-mattana',
          'name': 'Mattana Wedding Planner',
          'category': 'Wedding Planner',
          'city': 'Bali',
          'price': 45000000,
        },
      ],
    },
    {
      'id': 'pkg-garden-jakarta',
      'slug': 'paket-garden-party-jakarta',
      'name': 'Paket Garden Party Jakarta',
      'description':
          'Pesta kebun dengan katering, dekorasi bunga, dan film sinematik.',
      'availability_date': '2027-01-31',
      'duration': 6.0,
      'event_period': 'Resepsi',
      'guest_capacity': 150,
      'is_featured': false,
      'price': 92000000,
      'vendors': [
        {
          'id': 'vendor-santap',
          'name': 'Santap Rasa Catering',
          'category': 'Catering',
          'city': 'Jakarta & Bali',
          'price': 17500000,
        },
        {
          'id': 'vendor-vivaldi',
          'name': 'Vivaldi Floral & Scenery',
          'category': 'Decoration',
          'city': 'Jakarta & Bali',
          'price': 65000000,
        },
        {
          'id': 'vendor-lumiere',
          'name': 'Lumière Cinematic Films',
          'category': 'Videography',
          'city': 'Jakarta',
          'price': 15000000,
        },
      ],
    },
    {
      // Sengaja tanpa kapasitas, periode, dan tanggal: menguji data kosong.
      'id': 'pkg-photo-glam',
      'slug': 'paket-photo-glam',
      'name': 'Paket Photo & Glam',
      'description': 'Dokumentasi foto-video dan rias pengantin untuk hari-H.',
      'availability_date': null,
      'duration': 8.0,
      'event_period': null,
      'guest_capacity': null,
      'is_featured': false,
      'price': 36000000,
      'vendors': [
        {
          'id': 'vendor-sora',
          'name': 'Sora Visual Stories',
          'category': 'Photography',
          'city': 'Bali',
          'price': 18500000,
        },
        {
          'id': 'vendor-ethereal',
          'name': 'Ethereal Glow Bridal MUA',
          'category': 'Hair & Makeup',
          'city': 'Jakarta',
          'price': 21000000,
        },
      ],
    },
  ];
}
