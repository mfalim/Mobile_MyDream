import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/app/providers/api_providers.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/member_remote_datasource.dart';
import '../../domain/entities/member_dashboard_data.dart';
import '../../domain/entities/member_profile.dart';

final memberDatasourceProvider = Provider<MemberRemoteDatasource>((ref) {
  final client = ref.watch(apiClientProvider);
  return MemberRemoteDatasource(client);
});

final memberDashboardProvider =
    AsyncNotifierProvider<MemberDashboardNotifier, MemberDashboardData?>(
  MemberDashboardNotifier.new,
);

class MemberDashboardNotifier extends AsyncNotifier<MemberDashboardData?> {
  @override
  Future<MemberDashboardData?> build() async {
    final user = ref.watch(authProvider);
    if (user == null || user.role != 'member') {
      return null;
    }
    return _fetch();
  }

  Future<MemberDashboardData> _fetch() async {
    final ds = ref.read(memberDatasourceProvider);
    return ds.fetchDashboard();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  /// Toggle / update status schedule secara cepat dan optimis
  Future<void> updateScheduleStatus({
    required int scheduleId,
    required String newStatus,
  }) async {
    final current = state.value;
    if (current == null) return;

    // 1. Optimistic local update
    final oldSchedules = current.schedules;
    final updatedSchedules = oldSchedules.map((s) {
      if (s.id == scheduleId) {
        return s.copyWith(status: newStatus);
      }
      return s;
    }).toList();

    final pendingCount = updatedSchedules.where((s) => s.isPending).count;
    final approvedCount = updatedSchedules.where((s) => s.isApproved).count;
    final rejectedCount = updatedSchedules.where((s) => s.isRejected).count;

    final updatedStats = MemberDashboardStats(
      totalSchedules: updatedSchedules.length,
      pendingSchedules: pendingCount,
      approvedSchedules: approvedCount,
      rejectedSchedules: rejectedCount,
      totalEvents: current.stats.totalEvents,
      coordinatorEvents: current.stats.coordinatorEvents,
      approvedFee: current.stats.approvedFee,
      estimatedFee: current.stats.estimatedFee,
    );

    state = AsyncData(current.copyWith(
      schedules: updatedSchedules,
      stats: updatedStats,
    ));

    // 2. Call API
    try {
      final ds = ref.read(memberDatasourceProvider);
      final updatedFromServer = await ds.updateScheduleStatus(
        scheduleId: scheduleId,
        status: newStatus,
      );

      // Pastikan state konsisten dengan respons server
      final latest = state.value;
      if (latest != null) {
        final syncedSchedules = latest.schedules.map((s) {
          if (s.id == scheduleId) {
            return updatedFromServer;
          }
          return s;
        }).toList();
        state = AsyncData(latest.copyWith(schedules: syncedSchedules));
      }
    } catch (e) {
      // Rollback jika gagal
      state = AsyncData(current);
      rethrow;
    }
  }

  /// Simpan profil kru (Call Sign, No HT, Kontak Darurat, Domisili)
  Future<MemberProfile> saveProfile({
    required String callSign,
    required String phone,
    String? htCode,
    String? domicile,
    String? emergencyName,
    String? emergencyPhone,
  }) async {
    final ds = ref.read(memberDatasourceProvider);
    final saved = await ds.updateProfile(
      callSign: callSign,
      phone: phone,
      htCode: htCode,
      domicile: domicile,
      emergencyName: emergencyName,
      emergencyPhone: emergencyPhone,
    );

    // Update call sign di authProvider
    ref.read(authProvider.notifier).updateCallSign(saved.callSign ?? callSign);

    // Update state dashboard jika ada
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(member: saved));
    } else {
      await refresh();
    }

    return saved;
  }

  /// Input kehadiran tim oleh Koordinator Utama
  Future<void> submitAttendance({
    required int eventId,
    required int memberId,
    required String attendanceStatus,
    required double actualHours,
  }) async {
    final ds = ref.read(memberDatasourceProvider);
    await ds.updateTeamAttendance(
      eventId: eventId,
      memberId: memberId,
      attendanceStatus: attendanceStatus,
      actualHours: actualHours,
    );
    await refresh();
  }
}

extension _IterableCount<T> on Iterable<T> {
  int get count => length;
}

