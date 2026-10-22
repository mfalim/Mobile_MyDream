import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/features/info/data/datasources/info_mock_datasource.dart';
import 'package:w51/features/info/data/repositories/info_repository_impl.dart';
import 'package:w51/features/info/domain/entities/info_document.dart';
import 'package:w51/features/info/domain/repositories/info_repository.dart';

final infoRepositoryProvider = Provider<InfoRepository>(
  (ref) => InfoRepositoryImpl(InfoMockDatasource()),
);

final infoDocumentProvider = FutureProvider.family<InfoDocument, String>(
  (ref, slug) => ref.watch(infoRepositoryProvider).load(slug),
);
