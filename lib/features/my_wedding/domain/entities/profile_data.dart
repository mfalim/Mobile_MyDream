class VisionBoard {
  const VisionBoard(this.label);

  final String label;
}

class ProfileData {
  const ProfileData({
    required this.coupleNames,
    required this.isVerified,
    required this.weddingDateLabel,
    required this.daysLeft,
    required this.inspirationBoards,
    required this.vendorsContacted,
    required this.boards,
    required this.newCollections,
    required this.lastUpdateLabel,
    required this.appVersion,
  });

  final String coupleNames;
  final bool isVerified;
  final String weddingDateLabel;
  final int daysLeft;
  final int inspirationBoards;
  final int vendorsContacted;
  final List<VisionBoard> boards;
  final int newCollections;
  final String lastUpdateLabel;
  final String appVersion;
}
