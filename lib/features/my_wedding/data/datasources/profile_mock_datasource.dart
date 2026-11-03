import 'package:w51/features/my_wedding/domain/entities/profile_data.dart';

/// MOCK DATA: contoh untuk prototype, BUKAN data dari server. Saat tersambung
/// API, nilai-nilai ini boleh kosong dan layarnya menyembunyikannya.
class ProfileMockDatasource {
  Future<ProfileData> fetch() async {
    return const ProfileData(
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
    );
  }
}
