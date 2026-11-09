import 'package:w51/features/my_wedding/domain/entities/profile_data.dart';

/// MOCK: data tambahan Profil. Sengaja kosong: lencana verifikasi, statistik,
/// dan papan visi tidak punya sumber di database, jadi tidak ada angka karangan.
/// Saat tersambung API, isinya boleh diisi server dan layar menampilkannya.
class ProfileMockDatasource {
  Future<ProfileData> fetch() async => const ProfileData();
}
