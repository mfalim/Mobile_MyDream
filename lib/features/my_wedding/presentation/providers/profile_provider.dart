import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/core/config/app_config.dart';
import 'package:w51/features/my_wedding/data/datasources/profile_mock_datasource.dart';
import 'package:w51/features/my_wedding/data/repositories/profile_repository_impl.dart';
import 'package:w51/features/my_wedding/domain/entities/profile_data.dart';
import 'package:w51/features/my_wedding/domain/repositories/profile_repository.dart';
import 'package:w51/features/payment/presentation/providers/payments_provider.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ProfileMockDatasource()),
);

final profileDataProvider = FutureProvider<ProfileData>((ref) async {
  final base = await ref.watch(profileRepositoryProvider).load();
  if (AppConfig.useMockData) {
    return base;
  }

  final bookings = await ref.watch(clientBookingsProvider.future);
  if (bookings.isEmpty) {
    return base;
  }

  final totalVendorSchedules =
      bookings.fold<int>(0, (sum, b) => sum + b.totalSchedules);
  final hasApproved = bookings.any((b) => b.bookingStatus == 'approved');

  return ProfileData(
    isVerified: hasApproved,
    inspirationBoards: bookings.length,
    vendorsContacted: totalVendorSchedules,
    boards: base.boards,
    newCollections: base.newCollections,
    lastUpdateLabel: base.lastUpdateLabel,
  );
});
