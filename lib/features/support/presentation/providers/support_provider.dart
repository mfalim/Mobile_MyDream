import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/features/support/data/datasources/support_mock_datasource.dart';
import 'package:w51/features/support/data/repositories/support_repository_impl.dart';
import 'package:w51/features/support/domain/repositories/support_repository.dart';

final supportRepositoryProvider = Provider<SupportRepository>(
  (ref) => const SupportRepositoryImpl(SupportMockDatasource()),
);
