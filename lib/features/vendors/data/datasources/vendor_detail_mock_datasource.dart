import 'package:flutter/material.dart';
import 'package:w51/features/vendors/domain/entities/vendor_detail.dart';

/// MOCK DATA: contoh untuk prototype, BUKAN data dari server.
/// Nama dan lokasi mengikuti id vendor; isi paket dan harga sama untuk semua.
class VendorDetailMockDatasource {
  static const _known = <String, (String, String)>{
    'vendor-glasshouse': (
      'The Glasshouse Cliff Sanctuary',
      'Uluwatu, Badung - Bali',
    ),
    'vendor-maison': ("Maison de L'Amour Bridal", 'Menteng, Jakarta Pusat'),
    'vendor-vivaldi': ('Vivaldi Floral & Scenery', 'Jakarta & Bali'),
  };

  Future<VendorDetail> fetch(String id) async {
    final (name, location) = _known[id] ??
        ('The Westin Resort Nusa Dua, Bali', 'Nusa Dua, Badung - Bali');

    return VendorDetail(
      id: id,
      name: name,
      location: location,
      price: 247459800,
      originalPrice: 260484000,
      savePercent: 5,
      savingsBadge: 'Hemat 13 Jt',
      validUntil: 'Valid s/d Des 2026',
      photoCount: 12,
      paxIncluded: 100,
      setting: 'Beachfront & Garden',
      cashbackPoints: 61865,
      cashbackPercent: 2.5,
      cashbackNote: 'Tukarkan langsung untuk honeymoon & souvenir',
      installmentMonths: 24,
      installmentPerMonth: 10310825,
      provider: const VendorProviderInfo(
        name: 'Mattana Wedding',
        tagline: 'Top Tier Bali Wedding Specialist',
        rating: 5.0,
        reviewCount: 6,
      ),
      sections: const [
        PackageSection(
          title: 'Wedding Ceremony',
          subtitle: 'Sandy beach setup & floral aesthetics',
          icon: Icons.celebration_outlined,
          inclusions: [
            'Two (2) hours exclusive usage of pristine white sandy beachfront or elevated garden lawn.',
            'Contemporary botanical wedding floral arch with imported roses and tropical foliage.',
            "Bespoke bridal hand bouquet & groom's boutonniere by award-winning floral stylist.",
            'Up to 100 white tiffany chairs with elegant sash and fresh petal virgin aisle runner.',
            'English-speaking celebratory wedding officiant with commemorative certificate.',
            'Acoustic violin & cello live duet accompaniment during solemnization.',
            'High-definition sound system with 2 wireless microphones for vow exchange.',
          ],
        ),
        PackageSection(
          title: 'Dinner Reception & Canape Flow',
          subtitle: '5-Course gourmet banquet & beverage free-flow',
          icon: Icons.restaurant,
          inclusions: [
            'Welcome canape selection during sunset cocktail hour.',
            '5-course gourmet plated dinner for up to 100 guests.',
            'Free-flow soft drinks, house wine, and local beer for 3 hours.',
          ],
        ),
        PackageSection(
          title: 'Complimentary Stay',
          subtitle: 'Ocean Suite & Deluxe rooms',
          icon: Icons.bed_outlined,
          inclusions: [
            'Two nights in an Ocean Suite for the couple, with breakfast.',
            'Complimentary Deluxe rooms for immediate family.',
          ],
        ),
      ],
      guaranteeTitle: '100% Refundable Deposit Guarantee',
      guaranteeNote:
          'Garansi proteksi tanggal & kemudahan reschedule hingga 60 hari sebelum acara.',
    );
  }
}
