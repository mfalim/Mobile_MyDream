import 'package:w51/features/my_wedding/domain/entities/profile_data.dart';

/// MOCK DATA: contoh untuk prototype, BUKAN data dari server.
class ProfileMockDatasource {
  Future<ProfileData> fetch() async {
    return const ProfileData(
      coupleNames: 'Clarissa Wijaya & Adrian',
      isVerified: true,
      inspirationBoards: 48,
      vendorsContacted: 12,
      boards: [
        VisionBoard('Floral'),
        VisionBoard('Dekor'),
        VisionBoard('Gaun')
      ],
      newCollections: 3,
      lastUpdateLabel: 'kemarin malam',
      appVersion: '3.1.5 (20261024-LuxuryBuild)',
    );
  }
}
