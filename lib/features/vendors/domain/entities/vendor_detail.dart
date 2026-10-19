import 'package:flutter/widgets.dart';

class PackageSection {
  const PackageSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.inclusions,
  });

  final String title;
  final String subtitle;
  final IconData icon;
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
    required this.price,
    required this.originalPrice,
    required this.savePercent,
    required this.savingsBadge,
    required this.validUntil,
    required this.photoCount,
    required this.paxIncluded,
    required this.setting,
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
  final int price;
  final int originalPrice;
  final int savePercent;
  final String savingsBadge;
  final String validUntil;
  final int photoCount;
  final int paxIncluded;
  final String setting;
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
