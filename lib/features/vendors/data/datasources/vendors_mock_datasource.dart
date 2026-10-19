import 'package:flutter/material.dart';
import 'package:w51/features/vendors/domain/entities/vendor_entities.dart';

/// MOCK DATA: contoh untuk prototype, BUKAN data dari server.
class VendorsMockDatasource {
  Future<VendorsData> fetch() async {
    return const VendorsData(
      popularSearches: ['Glasshouse Bali', 'Intimate Jakarta', 'Garden Party'],
      filters: ['Semua Kategori', 'Lokasi: Bali & Jakarta', 'Estimasi Budget'],
      categories: [
        VendorCategory(
          label: 'Venue',
          subtitle: 'Ballroom & Outdoor',
          icon: Icons.villa_outlined,
        ),
        VendorCategory(
          label: 'Bridal & Gown',
          subtitle: 'Custom & Rental',
          icon: Icons.checkroom_outlined,
        ),
        VendorCategory(
          label: 'Photography',
          subtitle: 'Prewedding & D-Day',
          icon: Icons.photo_camera_outlined,
        ),
        VendorCategory(
          label: 'Decoration',
          subtitle: 'Floral & Ambient',
          icon: Icons.local_florist_outlined,
        ),
        VendorCategory(
          label: 'Hair & Makeup',
          subtitle: 'Bridal MUA Pro',
          icon: Icons.face_retouching_natural,
        ),
        VendorCategory(
          label: 'Wedding Planner',
          subtitle: 'Full & Day-Of WO',
          icon: Icons.event_note_outlined,
        ),
      ],
      quickCategories: [
        QuickCategory(label: 'Videography', icon: Icons.videocam_outlined),
        QuickCategory(label: 'Catering', icon: Icons.restaurant),
        QuickCategory(label: 'Entertainment', icon: Icons.music_note),
      ],
      featured: [
        FeaturedVendor(
          id: 'vendor-glasshouse',
          name: 'The Glasshouse Cliff Sanctuary',
          categoryLabel: 'Venue • Bali',
          tag: 'Top Tier',
          tagIcon: Icons.verified_outlined,
          rating: 4.9,
          reviewCount: 124,
          badge: "Editor's Choice",
          description:
              'Uluwatu, Bali • Kapasitas hingga 350 pax • Ocean cliff view panoramic',
          priceLabel: 'Mulai dari',
          price: 850000,
          priceUnit: '/ pax',
          promoBadge: 'Cashback 8%',
          promoNote: 'Min. 150 pax',
        ),
        FeaturedVendor(
          id: 'vendor-maison',
          name: "Maison de L'Amour Bridal",
          categoryLabel: 'Bridal & Gown • Jakarta',
          tag: 'Couture',
          tagIcon: Icons.checkroom_outlined,
          rating: 5.0,
          reviewCount: 89,
          badge: 'Bridestory Pay',
          description:
              'Menteng, Jakarta Pusat • Termasuk Veil & Accessories • Flexi Fitting',
          priceLabel: 'Paket D-Day',
          price: 38000000,
          originalPrice: 45000000,
          promoBadge: 'Hemat 7jt',
          promoNote: 'Cicilan 0% 12 Bln',
        ),
        FeaturedVendor(
          id: 'vendor-vivaldi',
          name: 'Vivaldi Floral & Scenery',
          categoryLabel: 'Decoration • Jakarta & Bali',
          tag: 'Artisan',
          tagIcon: Icons.auto_awesome_outlined,
          rating: 4.9,
          reviewCount: 160,
          description:
              'Specialized Concept Design • 3D Visual Rendering • Free Lighting Rigging',
          priceLabel: 'Paket All-In Decor',
          price: 65000000,
          promoBadge: 'Free Hand Bouquet',
          promoNote: 'Book by Nov 2026',
        ),
      ],
    );
  }
}
