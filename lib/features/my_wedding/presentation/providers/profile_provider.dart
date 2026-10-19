import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/features/my_wedding/data/datasources/profile_mock_datasource.dart';
import 'package:w51/features/my_wedding/data/repositories/profile_repository_impl.dart';
import 'package:w51/features/my_wedding/domain/entities/profile_data.dart';
import 'package:w51/features/my_wedding/domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ProfileMockDatasource()),
);

final profileDataProvider = FutureProvider<ProfileData>(
  (ref) => ref.watch(profileRepositoryProvider).load(),
);
