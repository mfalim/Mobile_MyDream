class VisionBoard {
  const VisionBoard(this.label);

  final String label;
}

/// Data tambahan Profil yang belum punya sumber di database. Semuanya
/// opsional: yang kosong disembunyikan di layar.
class ProfileData {
  const ProfileData({
    this.isVerified = false,
    this.inspirationBoards,
    this.vendorsContacted,
    this.boards = const [],
    this.newCollections,
    this.lastUpdateLabel,
  });

  final bool isVerified;
  final int? inspirationBoards;
  final int? vendorsContacted;
  final List<VisionBoard> boards;
  final int? newCollections;
  final String? lastUpdateLabel;
}
