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
    this.rating,
    this.reviewCount,
  });

  final String name;
  final String role;
  final StoryVendorKind kind;
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
  });

  final String id;
  final String category;
  final String title;
  final String? dateLabel;
  final int? reads;
  final String? photoUrl;
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
}

class InspirationsData {
  const InspirationsData({required this.more, this.story});

  /// Cerita utama yang tampil lengkap; null bila belum ada artikel.
  final RealWeddingStory? story;
  final List<StoryTeaser> more;

  List<String> get categories => more.map((s) => s.category).toSet().toList();
}
