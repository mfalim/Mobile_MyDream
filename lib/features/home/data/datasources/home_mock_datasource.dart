import 'package:flutter/material.dart';
import 'package:w51/features/home/domain/entities/home_entities.dart';

/// MOCK DATA: contoh untuk prototype, BUKAN data dari server.
/// Saat API siap, buat datasource baru dan ganti di home_repository_impl.dart.
class HomeMockDatasource {
  Future<HomeData> fetch() async {
    return const HomeData(
      countdown: WeddingCountdown(
        coupleNames: 'Clarissa & Adrian',
        readiness: 0.62,
        nextTask: 'Finalisasi Undangan & RSVP',
      ),
      services: [
        ServiceCategory(label: 'All-In Package', icon: Icons.celebration),
        ServiceCategory(label: 'Venue Deals', icon: Icons.villa),
        ServiceCategory(label: 'Photography', icon: Icons.photo_camera),
        ServiceCategory(
          label: 'Bridal & MUA',
          icon: Icons.face_retouching_natural,
        ),
        ServiceCategory(label: 'Dekorasi', icon: Icons.local_florist),
        ServiceCategory(label: 'Catering', icon: Icons.restaurant),
        ServiceCategory(label: 'Honeymoon', icon: Icons.flight),
        ServiceCategory(label: 'Lainnya', icon: Icons.apps),
      ],
      deals: [
        DealItem(
          id: 'deal-1',
          title: 'The Cliff Oceanfront Villa',
          badge: 'Hemat 13 Jt',
          isDiscount: true,
          locationLabel: 'Nusa Dua, Bali',
          tag: 'All-Inclusive',
          detail: 'Hingga 350 Tamu',
          detailIcon: Icons.groups_outlined,
          originalPrice: 260459800,
          price: 247459800,
        ),
        DealItem(
          id: 'deal-2',
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
        'Dress & Attire'
      ],
      vendors: [
        CuratedVendor(
          id: 'vendor-1',
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
          id: 'vendor-2',
          name: 'Maison de Belle Bridal',
          subtitle: 'Bridal Gown & Kebaya • Jakarta',
          category: 'Dress & Attire',
          rating: 5.0,
          reviewCount: 98,
          highlight: 'Fitting Gratis',
          startingPrice: 25000000,
          tag: 'Couture',
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
