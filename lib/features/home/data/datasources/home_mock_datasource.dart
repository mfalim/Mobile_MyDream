import 'package:flutter/material.dart';
import 'package:w51/features/home/domain/entities/home_entities.dart';

/// MOCK DATA: contoh untuk prototype, BUKAN data dari server.
/// Deal dan vendor pilihan memakai id vendor yang sama dengan daftar Vendors;
/// nama, harga, dan rating harus sama (tes memeriksanya).
class HomeMockDatasource {
  Future<HomeData> fetch() async {
    return const HomeData(
      countdown: WeddingCountdown(
        readiness: 0.62,
        nextTask: 'Finalisasi Undangan & RSVP',
      ),
      services: [
        ServiceCategory(
          label: 'All-In Package',
          icon: Icons.celebration,
          route: '/packages',
        ),
        ServiceCategory(
          label: 'Venue Deals',
          icon: Icons.villa,
          vendorCategory: 'Venue',
        ),
        ServiceCategory(
          label: 'Photography',
          icon: Icons.photo_camera,
          vendorCategory: 'Photography',
        ),
        ServiceCategory(
          label: 'Bridal & MUA',
          icon: Icons.face_retouching_natural,
          vendorCategory: 'Hair & Makeup',
        ),
        ServiceCategory(
          label: 'Dekorasi',
          icon: Icons.local_florist,
          vendorCategory: 'Decoration',
        ),
        ServiceCategory(
          label: 'Catering',
          icon: Icons.restaurant,
          vendorCategory: 'Catering',
        ),
        ServiceCategory(
          label: 'Honeymoon',
          icon: Icons.flight,
          vendorCategory: 'Honeymoon',
        ),
        ServiceCategory(label: 'Lainnya', icon: Icons.apps),
      ],
      deals: [
        DealItem(
          id: 'vendor-glasshouse',
          voucherCode: 'DREAMWEDDING',
          title: 'The Glasshouse Cliff Sanctuary',
          badge: 'Hemat 7 Jt',
          isDiscount: true,
          locationLabel: 'Uluwatu, Bali',
          tag: 'All-Inclusive',
          detail: 'Paket 100 Tamu',
          detailIcon: Icons.groups_outlined,
          originalPrice: 92000000,
          price: 85000000,
        ),
        DealItem(
          id: 'vendor-ethereal',
          voucherCode: 'NEWCOUPLE',
          title: 'Ethereal Glow Bridal MUA',
          badge: 'Best Price',
          isDiscount: false,
          tag: 'Signature MUA',
          detail: 'Termasuk Retouch',
          detailIcon: Icons.verified_outlined,
          originalPrice: 28500000,
          price: 21000000,
        ),
      ],
      vendorCategories: [
        'Semua Kategori',
        'Venue',
        'Photography',
        'Bridal & Gown'
      ],
      vendors: [
        CuratedVendor(
          id: 'vendor-sora',
          name: 'Sora Visual Stories',
          subtitle: 'Photography & Videography • Bali',
          category: 'Photography',
          rating: 4.9,
          reviewCount: 142,
          highlight: 'Fast RSVP',
          startingPrice: 18500000,
          tag: 'Top 1%',
        ),
        CuratedVendor(
          id: 'vendor-maison',
          name: "Maison de L'Amour Bridal",
          subtitle: 'Bridal Gown & Kebaya • Jakarta',
          category: 'Bridal & Gown',
          rating: 5.0,
          reviewCount: 89,
          highlight: 'Fitting Gratis',
          startingPrice: 38000000,
          tag: 'Couture',
        ),
        CuratedVendor(
          id: 'vendor-glasshouse',
          name: 'The Glasshouse Cliff Sanctuary',
          subtitle: 'Venue • Uluwatu, Bali',
          category: 'Venue',
          rating: 4.9,
          reviewCount: 124,
          highlight: 'Cashback 8%',
          startingPrice: 85000000,
          tag: 'Top Tier',
        ),
      ],
      articles: [
        InspirationArticle(
          id: 'article-1',
          category: 'Fashion & Style',
          title: '8 Tips Memilih Wedding Veil yang Tepat Sesuai Siluet Gaun',
          excerpt: 'Panduan lengkap dari veil katedral hingga blusher.',
        ),
        InspirationArticle(
          id: 'article-2',
          category: 'Outdoor Planning',
          title: '9 Tips Menikah saat Cuaca Terik agar Riasan Tahan Lama',
          excerpt: 'Kiat menjaga kenyamanan tamu di bawah matahari.',
        ),
      ],
    );
  }
}
