enum StoryVendorKind { planner, decor, photographer }

class StoryStat {
  const StoryStat({required this.label, required this.value});

  final String label;
  final String value;
}

class StoryVendor {
  const StoryVendor({
    required this.name,
    required this.role,
    required this.rating,
    required this.reviewCount,
    required this.kind,
  });

  final String name;
  final String role;
  final double rating;
  final int reviewCount;
  final StoryVendorKind kind;
}

class StoryTeaser {
  const StoryTeaser({
    required this.id,
    required this.category,
    required this.title,
    required this.dateLabel,
    required this.reads,
  });

  final String id;
  final String category;
  final String title;
  final String dateLabel;
  final int reads;
}

class RealWeddingStory {
  const RealWeddingStory({
    required this.id,
    required this.tag,
    required this.location,
    required this.title,
    required this.excerpt,
    required this.authorName,
    required this.publishedLabel,
    required this.readMinutes,
    required this.heroCaption,
    required this.stats,
    required this.body,
    required this.quote,
    required this.photoCaptions,
    required this.vendorsTitle,
    required this.vendors,
    required this.tipsTitle,
    required this.tips,
    required this.likes,
    required this.reads,
  });

  final String id;
  final String tag;
  final String location;
  final String title;
  final String excerpt;
  final String authorName;
  final String publishedLabel;
  final int readMinutes;
  final String heroCaption;
  final List<StoryStat> stats;
  final String body;
  final String quote;
  final List<String> photoCaptions;
  final String vendorsTitle;
  final List<StoryVendor> vendors;
  final String tipsTitle;
  final List<String> tips;
  final int likes;
  final int reads;
}

class InspirationsData {
  const InspirationsData({required this.story, required this.more});

  final RealWeddingStory story;
  final List<StoryTeaser> more;

  List<String> get categories => more.map((s) => s.category).toSet().toList();
}
