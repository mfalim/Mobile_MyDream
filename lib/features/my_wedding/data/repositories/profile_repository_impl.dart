import 'package:w51/features/my_wedding/data/datasources/profile_mock_datasource.dart';
import 'package:w51/features/my_wedding/domain/entities/profile_data.dart';
import 'package:w51/features/my_wedding/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._datasource);

  final ProfileMockDatasource _datasource;

  @override
  Future<ProfileData> load() => _datasource.fetch();
}
