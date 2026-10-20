/// Satu poin ringkas di kartu harga, mis. "100 Pax Included".
class VendorFact {
  const VendorFact({required this.iconKey, required this.text});

  final String iconKey;
  final String text;
}

class PackageSection {
  const PackageSection({
    required this.title,
    required this.subtitle,
    required this.iconKey,
    required this.inclusions,
  });

  final String title;
  final String subtitle;
  final String iconKey;
  final List<String> inclusions;
}

class VendorProviderInfo {
  const VendorProviderInfo({
    required this.name,
    required this.tagline,
    required this.rating,
    required this.reviewCount,
  });

  final String name;
  final String tagline;
  final double rating;
  final int reviewCount;
}

class VendorDetail {
  const VendorDetail({
    required this.id,
    required this.name,
    required this.location,
    required this.packageLabel,
    required this.price,
    required this.originalPrice,
    required this.savePercent,
    required this.savingsBadge,
    required this.validUntil,
    required this.photoCount,
    required this.paxIncluded,
    required this.facts,
    required this.cashbackPoints,
    required this.cashbackPercent,
    required this.cashbackNote,
    required this.installmentMonths,
    required this.installmentPerMonth,
    required this.provider,
    required this.sections,
    required this.guaranteeTitle,
    required this.guaranteeNote,
  });

  final String id;
  final String name;
  final String location;

  /// Nama paket, mis. "All Inclusive 100 Pax" atau "Paket D-Day".
  final String packageLabel;
  final int price;
  final int originalPrice;
  final int savePercent;
  final String savingsBadge;
  final String validUntil;
  final int photoCount;

  /// Jumlah tamu yang dicakup paket; 0 bila harganya tidak berbasis tamu
  /// (fotografi, rias, busana, dan sejenisnya).
  final int paxIncluded;
  final List<VendorFact> facts;
  final int cashbackPoints;
  final double cashbackPercent;
  final String cashbackNote;
  final int installmentMonths;
  final int installmentPerMonth;
  final VendorProviderInfo provider;
  final List<PackageSection> sections;
  final String guaranteeTitle;
  final String guaranteeNote;
}
