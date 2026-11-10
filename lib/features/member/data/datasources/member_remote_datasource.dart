import 'package:w51/core/network/api_client.dart';
import '../../domain/entities/member_dashboard_data.dart';
import '../../domain/entities/member_profile.dart';
import '../../domain/entities/member_schedule.dart';

class MemberRemoteDatasource {
  const MemberRemoteDatasource(this._client);

  final ApiClient _client;

  Future<MemberDashboardData> fetchDashboard() async {
    final raw = await _client.get('/member/dashboard');
    final map = raw as Map<String, dynamic>;
    return MemberDashboardData.fromJson(map);
  }

  Future<MemberProfile> updateProfile({
    required String callSign,
    required String phone,
    String? htCode,
    String? domicile,
    String? emergencyName,
    String? emergencyPhone,
  }) async {
    final payload = {
      'call_sign': callSign.trim(),
      'phone': phone.trim(),
      if (htCode != null && htCode.trim().isNotEmpty) 'ht_code': htCode.trim(),
      if (domicile != null && domicile.trim().isNotEmpty)
        'domicile': domicile.trim(),
      if (emergencyName != null && emergencyName.trim().isNotEmpty)
        'emergency_name': emergencyName.trim(),
      if (emergencyPhone != null && emergencyPhone.trim().isNotEmpty)
        'emergency_phone': emergencyPhone.trim(),
    };

    final raw = await _client.put('/member/profile', body: payload);
    final map = raw as Map<String, dynamic>;
    final data = map['data'] is Map<String, dynamic>
        ? map['data'] as Map<String, dynamic>
        : map;
    return MemberProfile.fromJson(data);
  }

  Future<MemberSchedule> updateScheduleStatus({
    required int scheduleId,
    required String status,
  }) async {
    final raw = await _client.patch(
      '/member/schedules/$scheduleId/status',
      body: {'status': status},
    );
    final map = raw as Map<String, dynamic>;
    final data = map['data'] is Map<String, dynamic>
        ? map['data'] as Map<String, dynamic>
        : map;
    return MemberSchedule.fromJson(data);
  }

  Future<void> updateTeamAttendance({
    required int eventId,
    required int memberId,
    required String attendanceStatus,
    required double actualHours,
  }) async {
    await _client.post(
      '/member/events/$eventId/members/$memberId/attendance',
      body: {
        'attendance_status': attendanceStatus,
        'actual_hours': actualHours,
      },
    );
  }
}

