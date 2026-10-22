import 'package:w51/features/info/data/datasources/info_mock_datasource.dart';
import 'package:w51/features/info/domain/entities/info_document.dart';
import 'package:w51/features/info/domain/repositories/info_repository.dart';

class InfoRepositoryImpl implements InfoRepository {
  const InfoRepositoryImpl(this._datasource);

  final InfoMockDatasource _datasource;

  @override
  Future<InfoDocument> load(String slug) => _datasource.fetch(slug);
}
