import 'package:w51/features/my_wedding/domain/entities/profile_data.dart';

abstract interface class ProfileRepository {
  Future<ProfileData> load();
}
