import 'package:w51/features/support/data/datasources/support_datasource.dart';
import 'package:w51/features/support/domain/entities/support_report.dart';
import 'package:w51/features/support/domain/repositories/support_repository.dart';

class SupportRepositoryImpl implements SupportRepository {
  const SupportRepositoryImpl(this._datasource);

  final SupportDatasource _datasource;

  @override
  Future<String> submit(SupportReport report) => _datasource.submit(report);
}
