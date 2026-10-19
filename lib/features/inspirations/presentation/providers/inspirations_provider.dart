import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/features/inspirations/data/datasources/inspirations_mock_datasource.dart';
import 'package:w51/features/inspirations/data/repositories/inspirations_repository_impl.dart';
import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';
import 'package:w51/features/inspirations/domain/repositories/inspirations_repository.dart';

final inspirationsRepositoryProvider = Provider<InspirationsRepository>(
  (ref) => InspirationsRepositoryImpl(InspirationsMockDatasource()),
);

final inspirationsDataProvider = FutureProvider<InspirationsData>(
  (ref) => ref.watch(inspirationsRepositoryProvider).load(),
);
