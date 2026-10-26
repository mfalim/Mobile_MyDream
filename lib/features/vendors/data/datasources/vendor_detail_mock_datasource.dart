import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/features/vendors/data/models/vendor_detail_model.dart';
import 'package:w51/features/vendors/domain/entities/vendor_detail.dart';

/// MOCK: meniru jawaban server (GET /vendors/{id}). Bentuk datanya, termasuk
/// nama kunci snake_case, adalah rancangan kontrak API. Bukan data asli.
class VendorDetailMockDatasource {
  Future<VendorDetail> fetch(String id) async {
    final json = _responses[id];
    if (json == null) throw NotFoundException('vendor $id');
    return VendorDetailModel.fromJson(json);
  }

  static const _guarantee = {
    'title': '100% Refundable Deposit Guarantee',
    'note': 'Garansi proteksi tanggal & kemudahan reschedule hingga 60 hari '
        'sebelum acara.',
  };

  static final Map<String, Map<String, dynamic>> _responses = {
    'vendor-glasshouse': {
      'id': 'vendor-glasshouse',
      'name': 'The Glasshouse Cliff Sanctuary',
      'category': 'Venue',
      'location': 'Uluwatu, Badung - Bali',
      'package_label': 'All Inclusive 100 Pax',
      'price': 85000000,
      'original_price': 92000000,
      'valid_until': 'Valid s/d Des 2026',
      'photo_count': 14,
      'pax_included': 100,
      'facts': [
        {'icon': 'groups', 'text': '100 Pax Included'},
        {'icon': 'sun', 'text': 'Cliff & Ocean View'},
      ],
      'cashback_percent': 8.0,
      'cashback_note': 'Tukarkan langsung untuk honeymoon & souvenir',
      'installment_months': 12,
      'provider': {
        'name': 'Glasshouse Events Team',
        'tagline': 'Venue Specialist Uluwatu',
        'rating': 4.9,
        'review_count': 124,
      },
      'sections': [
        {
          'title': 'Ceremony & Glasshouse Hall',
          'subtitle': 'Sunset cliff ceremony & panoramic glass hall',
          'icon': 'ceremony',
          'inclusions': [
            'Exclusive use of the glass hall and cliff-edge terrace for 6 hours.',
            'Ocean-facing aisle with fresh floral installation and hand-crafted arch.',
            'Bridal suite with private lounge and makeup station for 4 hours.',
            'Dedicated event captain and 6 service crew for the whole event.',
            'Sound system with 2 wireless microphones and ambient lighting.',
          ],
        },
        {
          'title': 'Reception Dinner',
          'subtitle': '4-course dinner & signature mocktail bar',
          'icon': 'restaurant',
          'inclusions': [
            'Plated 4-course dinner for up to 100 guests.',
            'Signature welcome drinks and unlimited mocktail bar for 3 hours.',
            'Round-table setup with linen, charger plates, and candle centerpiece.',
          ],
        },
        {
          'title': 'Facilities & Access',
          'subtitle': 'Parking, shuttle & family rooms',
          'icon': 'bed',
          'inclusions': [
            'Complimentary valet parking for 40 vehicles.',
            'Guest shuttle from the Uluwatu main road (2 units).',
            'Standby room for immediate family (2 rooms, 1 night).',
          ],
        },
      ],
      'guarantee': _guarantee,
    },
    'vendor-maison': {
      'id': 'vendor-maison',
      'name': "Maison de L'Amour Bridal",
      'category': 'Bridal & Gown',
      'location': 'Menteng, Jakarta Pusat',
      'package_label': 'Paket D-Day',
      'price': 38000000,
      'original_price': 45000000,
      'valid_until': 'Valid s/d Jan 2027',
      'photo_count': 10,
      'pax_included': 0,
      'facts': [
        {'icon': 'dress', 'text': 'Veil & Accessories Termasuk'},
        {'icon': 'event', 'text': 'Flexi Fitting 3x'},
      ],
      'cashback_percent': 5.0,
      'cashback_note': 'Tukarkan untuk fitting tambahan & aksesori',
      'installment_months': 12,
      'provider': {
        'name': "Maison de L'Amour Atelier",
        'tagline': 'Couture Bridal House Jakarta',
        'rating': 5.0,
        'review_count': 89,
      },
      'sections': [
        {
          'title': 'Gaun Pengantin',
          'subtitle': 'Custom couture & rental premium',
          'icon': 'dress',
          'inclusions': [
            'Pemakaian 1 gaun akad dan 1 gaun resepsi untuk hari-H.',
            'Fitting 3 kali dengan penyesuaian ukuran oleh penjahit atelier.',
            'Veil katedral, tiara, dan aksesori rambut sesuai tema gaun.',
          ],
        },
        {
          'title': 'Pendamping Pria & Keluarga',
          'subtitle': 'Jas pengantin pria & kebaya keluarga',
          'icon': 'groups',
          'inclusions': [
            'Setelan jas pengantin pria lengkap dengan dasi atau bow tie.',
            'Kebaya untuk 2 orang ibu dengan penyesuaian ukuran.',
            'Garment steaming dan penyimpanan sehari sebelum acara.',
          ],
        },
        {
          'title': 'Layanan Hari-H',
          'subtitle': 'Dresser & perawatan gaun',
          'icon': 'sparkle',
          'inclusions': [
            'Dresser profesional mendampingi selama akad dan resepsi.',
            'Perawatan gaun setelah acara (dry cleaning) sudah termasuk.',
            'Pengantaran dan pengambilan gaun ke lokasi di area Jabodetabek.',
          ],
        },
      ],
      'guarantee': _guarantee,
    },
    'vendor-vivaldi': {
      'id': 'vendor-vivaldi',
      'name': 'Vivaldi Floral & Scenery',
      'category': 'Decoration',
      'location': 'Jakarta & Bali',
      'package_label': 'Paket All-In Decor',
      'price': 65000000,
      'original_price': 72000000,
      'valid_until': 'Book by Nov 2026',
      'photo_count': 18,
      'pax_included': 0,
      'facts': [
        {'icon': 'flower', 'text': 'Full Venue Styling'},
        {'icon': 'sparkle', 'text': '3D Visual Rendering'},
      ],
      'cashback_percent': 3.0,
      'cashback_note': 'Tukarkan untuk upgrade bunga atau lighting',
      'installment_months': 12,
      'provider': {
        'name': 'Vivaldi Decor Atelier',
        'tagline': 'Floral & Space Design',
        'rating': 4.9,
        'review_count': 160,
      },
      'sections': [
        {
          'title': 'Concept & Design',
          'subtitle': '3D rendering & mood board',
          'icon': 'palette',
          'inclusions': [
            'Sesi konsultasi konsep dan survei lokasi venue.',
            'Mood board dan 3D visual rendering dengan 3 kali revisi.',
            'Daftar bunga dan palet warna yang disepakati sebelum produksi.',
          ],
        },
        {
          'title': 'Floral & Styling',
          'subtitle': 'Altar, aisle & centerpiece',
          'icon': 'flower',
          'inclusions': [
            'Backdrop altar dengan rangkaian bunga segar dan dried foliage.',
            'Dekor lorong (aisle) dengan petal runner dan standing flowers.',
            '15 centerpiece meja tamu dan 1 meja welcome.',
            'Hand bouquet pengantin gratis (promo Book by Nov 2026).',
          ],
        },
        {
          'title': 'Execution & Lighting',
          'subtitle': 'Pemasangan, rigging & pembongkaran',
          'icon': 'sparkle',
          'inclusions': [
            'Free lighting rigging dan warm string lights di area utama.',
            'Tim pemasangan dan pembongkaran sehari penuh.',
            'Satu florist standby untuk merapikan bunga saat acara.',
          ],
        },
      ],
      'guarantee': _guarantee,
    },
    'vendor-sora': {
      'id': 'vendor-sora',
      'name': 'Sora Visual Stories',
      'category': 'Photography',
      'location': 'Bali',
      'package_label': 'Paket D-Day Photo & Video',
      'price': 18500000,
      'original_price': 22000000,
      'valid_until': 'Valid s/d Des 2026',
      'photo_count': 24,
      'pax_included': 0,
      'facts': [
        {'icon': 'camera', 'text': '8 Jam Coverage'},
        {'icon': 'video', 'text': '2 Fotografer + 1 Videografer'},
      ],
      'cashback_percent': 2.0,
      'cashback_note': 'Tukarkan untuk sesi foto tambahan',
      'installment_months': 6,
      'provider': {
        'name': 'Sora Visual Stories',
        'tagline': 'Photography & Videography Specialist',
        'rating': 4.9,
        'review_count': 142,
      },
      'sections': [
        {
          'title': 'Coverage Hari-H',
          'subtitle': 'Persiapan, akad & resepsi',
          'icon': 'camera',
          'inclusions': [
            'Liputan 8 jam: persiapan, akad, dan resepsi.',
            '2 fotografer dan 1 videografer berpengalaman.',
            'Sesi couple portrait 45 menit saat golden hour.',
          ],
        },
        {
          'title': 'Hasil Foto & Album',
          'subtitle': 'Foto edit & album cetak',
          'icon': 'sparkle',
          'inclusions': [
            'Minimal 500 foto hasil edit resolusi tinggi.',
            '1 album cetak 30 halaman dengan box eksklusif.',
            'Galeri online privat untuk dibagikan ke keluarga.',
          ],
        },
        {
          'title': 'Highlight Film',
          'subtitle': 'Sinematik 3 menit',
          'icon': 'video',
          'inclusions': [
            'Highlight film sinematik 3 menit dengan musik berlisensi.',
            'Teaser vertikal 30 detik untuk media sosial.',
            'Pengiriman hasil maksimal 21 hari kerja.',
          ],
        },
      ],
      'guarantee': _guarantee,
    },
    'vendor-ethereal': {
      'id': 'vendor-ethereal',
      'name': 'Ethereal Glow Bridal MUA',
      'category': 'Hair & Makeup',
      'location': 'Jakarta',
      'package_label': 'Paket Bridal Akad + Resepsi',
      'price': 21000000,
      'original_price': 28500000,
      'valid_until': 'Valid s/d Feb 2027',
      'photo_count': 12,
      'pax_included': 0,
      'facts': [
        {'icon': 'brush', 'text': '2 Sesi Makeup'},
        {'icon': 'verified', 'text': 'Termasuk Retouch'},
      ],
      'cashback_percent': 3.0,
      'cashback_note': 'Tukarkan untuk sesi makeup tambahan',
      'installment_months': 6,
      'provider': {
        'name': 'Ethereal Glow Studio',
        'tagline': 'Bridal MUA Specialist',
        'rating': 4.8,
        'review_count': 97,
      },
      'sections': [
        {
          'title': 'Bridal Makeup',
          'subtitle': 'Trial, akad & resepsi',
          'icon': 'brush',
          'inclusions': [
            'Sesi trial makeup 1 kali sebelum hari-H.',
            'Makeup akad dan makeup resepsi (2 look berbeda).',
            'Touch-up dan retouch selama acara oleh MUA pendamping.',
          ],
        },
        {
          'title': 'Hair & Styling',
          'subtitle': 'Hairdo & aksesori',
          'icon': 'sparkle',
          'inclusions': [
            'Hairdo pengantin untuk akad dan resepsi.',
            'Pemasangan veil dan aksesori rambut.',
            'Hijab styling tersedia atas permintaan.',
          ],
        },
        {
          'title': 'Keluarga & Pendamping',
          'subtitle': 'Ibu & bridesmaid',
          'icon': 'groups',
          'inclusions': [
            'Makeup untuk 2 orang ibu.',
            'Hairdo untuk 4 bridesmaid.',
            'Biaya transport dalam area Jakarta sudah termasuk.',
          ],
        },
      ],
      'guarantee': _guarantee,
    },
    'vendor-mattana': {
      'id': 'vendor-mattana',
      'name': 'Mattana Wedding Planner',
      'category': 'Wedding Planner',
      'location': 'Bali',
      'package_label': 'Full Planning 100 Pax',
      'price': 45000000,
      'original_price': 52000000,
      'valid_until': 'Valid s/d Mar 2027',
      'photo_count': 9,
      'pax_included': 100,
      'facts': [
        {'icon': 'event', 'text': 'Full Planning & Day-Of'},
        {'icon': 'groups', 'text': 'Hingga 100 Pax'},
      ],
      'cashback_percent': 2.5,
      'cashback_note': 'Tukarkan untuk layanan koordinasi tambahan',
      'installment_months': 12,
      'provider': {
        'name': 'Mattana Wedding',
        'tagline': 'Top Tier Bali Wedding Specialist',
        'rating': 4.9,
        'review_count': 128,
      },
      'sections': [
        {
          'title': 'Perencanaan & Konsultasi',
          'subtitle': 'Konsep, budget & timeline',
          'icon': 'event',
          'inclusions': [
            'Konsultasi konsep dan budget sebanyak 5 sesi.',
            'Timeline persiapan dan checklist 6 bulan.',
            'Rekomendasi dan negosiasi vendor sesuai budget.',
          ],
        },
        {
          'title': 'Koordinasi Vendor',
          'subtitle': 'Satu penanggung jawab',
          'icon': 'groups',
          'inclusions': [
            'Satu penanggung jawab untuk seluruh vendor.',
            'Survei lokasi dan technical meeting sebelum acara.',
            'Pengawasan kontrak dan jadwal pembayaran vendor.',
          ],
        },
        {
          'title': 'Manajemen Hari-H',
          'subtitle': 'Tim koordinator di lokasi',
          'icon': 'ceremony',
          'inclusions': [
            'Tim koordinator 6 orang selama acara.',
            'Rundown akad dan resepsi serta briefing keluarga.',
            'Pendamping pengantin dan penanganan kendala di lokasi.',
          ],
        },
      ],
      'guarantee': _guarantee,
    },
    'vendor-lumiere': {
      'id': 'vendor-lumiere',
      'name': 'Lumière Cinematic Films',
      'category': 'Videography',
      'location': 'Jakarta',
      'package_label': 'Paket Cinematic Film',
      'price': 15000000,
      'original_price': 18000000,
      'valid_until': 'Valid s/d Des 2026',
      'photo_count': 8,
      'pax_included': 0,
      'facts': [
        {'icon': 'video', 'text': 'Cinematic 4K'},
        {'icon': 'drone', 'text': 'Drone & Same-Day Edit'},
      ],
      'cashback_percent': 2.0,
      'cashback_note': 'Tukarkan untuk durasi liputan tambahan',
      'installment_months': 6,
      'provider': {
        'name': 'Lumière Studio',
        'tagline': 'Wedding Film Studio',
        'rating': 4.8,
        'review_count': 76,
      },
      'sections': [
        {
          'title': 'Produksi',
          'subtitle': '4K, gimbal & drone',
          'icon': 'video',
          'inclusions': [
            'Liputan 6 jam dengan 2 videografer.',
            'Rekaman 4K dengan gimbal dan audio recorder.',
            'Drone footage di lokasi (menyesuaikan izin venue).',
          ],
        },
        {
          'title': 'Hasil Akhir',
          'subtitle': 'Highlight, full film & same-day edit',
          'icon': 'sparkle',
          'inclusions': [
            'Film highlight sinematik 4 menit.',
            'Full film upacara dan resepsi (±15 menit).',
            'Same-day edit 1 menit diputar saat resepsi.',
          ],
        },
        {
          'title': 'Ketentuan',
          'subtitle': 'Revisi & pengiriman',
          'icon': 'check',
          'inclusions': [
            'Revisi minor sebanyak 2 kali.',
            'File hasil dikirim via cloud dalam 30 hari kerja.',
            'Overtime dikenakan biaya per jam sesuai kesepakatan.',
          ],
        },
      ],
      'guarantee': _guarantee,
    },
    'vendor-santap': {
      'id': 'vendor-santap',
      'name': 'Santap Rasa Catering',
      'category': 'Catering',
      'location': 'Jakarta & Bali',
      'package_label': 'Paket Buffet 100 Pax',
      'price': 17500000,
      'original_price': 19500000,
      'valid_until': 'Valid s/d Jan 2027',
      'photo_count': 11,
      'pax_included': 100,
      'facts': [
        {'icon': 'restaurant', 'text': 'Buffet 100 Pax'},
        {'icon': 'check', 'text': 'Free Tasting'},
      ],
      'cashback_percent': 3.0,
      'cashback_note': 'Tukarkan untuk tambahan menu atau live station',
      'installment_months': 6,
      'provider': {
        'name': 'Santap Rasa Catering',
        'tagline': 'Wedding Catering Nusantara & Western',
        'rating': 4.7,
        'review_count': 203,
      },
      'sections': [
        {
          'title': 'Menu Buffet',
          'subtitle': 'Nusantara atau Western',
          'icon': 'restaurant',
          'inclusions': [
            '5 main course, 3 appetizer, dan 4 dessert pilihan.',
            'Pilihan menu Nusantara atau Western.',
            'Satu live station (sate, pasta, atau dimsum).',
          ],
        },
        {
          'title': 'Minuman & Dessert',
          'subtitle': 'Welcome drink & dessert table',
          'icon': 'sparkle',
          'inclusions': [
            'Welcome drink dan free-flow es teh serta air mineral.',
            'Dessert table dengan 4 pilihan kue.',
            'Kopi dan teh untuk seluruh tamu.',
          ],
        },
        {
          'title': 'Layanan & Peralatan',
          'subtitle': 'Tim servis & perlengkapan',
          'icon': 'groups',
          'inclusions': [
            'Tim servis 10 orang dan 1 captain.',
            'Peralatan makan, meja buffet, dan linen.',
            'Free tasting menu untuk 4 orang sebelum kontrak.',
          ],
        },
      ],
      'guarantee': _guarantee,
    },
  };
}
