enum StoryVendorKind { planner, decor, photographer, other }

class StoryStat {
  const StoryStat({required this.label, required this.value});

  final String label;
  final String value;
}

class StoryPhoto {
  const StoryPhoto({this.url, this.caption});

  final String? url;
  final String? caption;
}

class StoryVendor {
  const StoryVendor({
    required this.name,
    required this.role,
    required this.kind,
    this.vendorId,
    this.rating,
    this.reviewCount,
  });

  final String name;
  final String role;
  final StoryVendorKind kind;

  /// Id vendor di direktori; bila ada, tombol "Lihat Vendor" membuka detailnya.
  final String? vendorId;
  final double? rating;
  final int? reviewCount;
}

class StoryTeaser {
  const StoryTeaser({
    required this.id,
    required this.category,
    required this.title,
    this.dateLabel,
    this.reads,
    this.photoUrl,
    this.excerpt,
    this.authorName,
    this.rating,
  });

  final String id;
  final String category;
  final String title;
  final String? dateLabel;
  final int? reads;
  final String? photoUrl;
  final String? excerpt;
  final String? authorName;
  final int? rating;
}

/// Cerita/artikel. Yang wajib hanya id dan judul; sisanya opsional dan
/// disembunyikan di layar bila kosong (database hanya punya judul, kategori,
/// ringkasan, isi, foto, penulis, tanggal, dan paket terkait).
class RealWeddingStory {
  const RealWeddingStory({
    required this.id,
    required this.title,
    this.category,
    this.tag,
    this.location,
    this.excerpt,
    this.authorName,
    this.publishedLabel,
    this.readMinutes,
    this.photoUrl,
    this.heroCaption,
    this.stats = const [],
    this.paragraphs = const [],
    this.quote,
    this.gallery = const [],
    this.vendorsTitle,
    this.vendors = const [],
    this.tipsTitle,
    this.tips = const [],
    this.likes,
    this.reads,
    this.relatedPackageId,
    this.relatedPackageName,
    this.rating,
    this.related = const [],
  });

  final String id;
  final String title;
  final String? category;
  final String? tag;
  final String? location;
  final String? excerpt;
  final String? authorName;
  final String? publishedLabel;
  final int? readMinutes;
  final String? photoUrl;
  final String? heroCaption;
  final List<StoryStat> stats;
  final List<String> paragraphs;
  final String? quote;
  final List<StoryPhoto> gallery;
  final String? vendorsTitle;
  final List<StoryVendor> vendors;
  final String? tipsTitle;
  final List<String> tips;
  final int? likes;
  final int? reads;
  final String? relatedPackageId;
  final String? relatedPackageName;
  final int? rating;
  final List<StoryTeaser> related;

  StoryTeaser toTeaser() => StoryTeaser(
        id: id,
        category: category ?? 'Artikel',
        title: title,
        dateLabel: publishedLabel,
        reads: reads,
        photoUrl: photoUrl,
        excerpt: excerpt ?? (paragraphs.isNotEmpty ? paragraphs.first : null),
        authorName: authorName,
        rating: rating,
      );
}

/// Event publik & pameran dari tabel `public_events` (selaras dengan halaman `/event` di web).
class PublicEventItem {
  const PublicEventItem({
    required this.id,
    required this.slug,
    required this.title,
    this.description,
    this.photoUrl,
    this.status = 'upcoming',
    this.dateLabel,
    this.timeLabel,
    this.location,
    this.vendors = const [],
  });

  final String id;
  final String slug;
  final String title;
  final String? description;
  final String? photoUrl;

  /// 'ongoing' | 'upcoming' | 'finished'
  final String status;
  final String? dateLabel;
  final String? timeLabel;
  final String? location;
  final List<StoryVendor> vendors;

  bool get isOngoing => status == 'ongoing';
  bool get isFinished => status == 'finished';
  bool get isUpcoming => !isOngoing && !isFinished;

  String get statusLabel => switch (status) {
        'ongoing' => 'Sedang Berlangsung',
        'finished' => 'Selesai',
        _ => 'Akan Datang',
      };
}

class InspirationsData {
  const InspirationsData({
    required this.more,
    this.story,
    this.events = const [],
  });

  /// Cerita utama yang tampil lengkap; null bila belum ada artikel.
  final RealWeddingStory? story;
  final List<StoryTeaser> more;
  final List<PublicEventItem> events;

  List<StoryTeaser> get allArticles => [
        if (story != null) story!.toTeaser(),
        ...more,
      ];

  List<String> get categories => {
        if (story?.category != null && story!.category!.trim().isNotEmpty)
          story!.category!,
        for (final s in more)
          if (s.category.trim().isNotEmpty) s.category,
      }.toList();
}
