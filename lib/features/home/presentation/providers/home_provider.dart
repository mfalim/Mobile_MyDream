import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/features/home/data/datasources/home_mock_datasource.dart';
import 'package:w51/features/home/data/repositories/home_repository_impl.dart';
import 'package:w51/features/home/domain/entities/home_entities.dart';
import 'package:w51/features/home/domain/repositories/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepositoryImpl(HomeMockDatasource()),
);

final homeDataProvider = FutureProvider<HomeData>(
  (ref) => ref.watch(homeRepositoryProvider).load(),
);
