import 'package:w51/features/inspirations/data/datasources/inspirations_mock_datasource.dart';
import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';
import 'package:w51/features/inspirations/domain/repositories/inspirations_repository.dart';

class InspirationsRepositoryImpl implements InspirationsRepository {
  const InspirationsRepositoryImpl(this._datasource);

  final InspirationsMockDatasource _datasource;

  @override
  Future<InspirationsData> load() => _datasource.fetch();
}
