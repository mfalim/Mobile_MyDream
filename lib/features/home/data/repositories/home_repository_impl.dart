import 'package:w51/features/home/data/datasources/home_mock_datasource.dart';
import 'package:w51/features/home/domain/entities/home_entities.dart';
import 'package:w51/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._datasource);

  final HomeMockDatasource _datasource;

  @override
  Future<HomeData> load() => _datasource.fetch();
}
