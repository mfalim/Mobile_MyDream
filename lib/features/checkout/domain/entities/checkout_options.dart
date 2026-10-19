class GuestTier {
  const GuestTier({
    required this.guests,
    required this.label,
    required this.extraCost,
  });

  final int guests;
  final String label;
  final int extraCost;

  String get note =>
      extraCost == 0 ? 'Termasuk paket' : '+ IDR ${extraCost ~/ 1000000}jt';
}

/// MOCK: tambahan biaya per kapasitas, diambil dari Figma. Nanti dari server.
const kGuestTiers = [
  GuestTier(guests: 100, label: 'INTIMATE', extraCost: 0),
  GuestTier(guests: 250, label: 'MEDIUM', extraCost: 62000000),
  GuestTier(guests: 500, label: 'GRAND BALL', extraCost: 125000000),
];

const kWeddingConcepts = [
  'Intimate Beachfront',
  'Modern Romantic',
  'Traditional Elegant',
  'Rustic Garden',
];
