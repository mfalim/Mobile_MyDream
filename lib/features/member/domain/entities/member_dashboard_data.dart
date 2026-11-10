import 'member_event.dart';
import 'member_profile.dart';
import 'member_schedule.dart';

class MemberDashboardStats {
  const MemberDashboardStats({
    this.totalSchedules = 0,
    this.pendingSchedules = 0,
    this.approvedSchedules = 0,
    this.rejectedSchedules = 0,
    this.totalEvents = 0,
    this.coordinatorEvents = 0,
    this.approvedFee = 0,
    this.estimatedFee = 0,
  });

  final int totalSchedules;
  final int pendingSchedules;
  final int approvedSchedules;
  final int rejectedSchedules;
  final int totalEvents;
  final int coordinatorEvents;
  final double approvedFee;
  final double estimatedFee;

  factory MemberDashboardStats.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val) {
      if (val is num) return val.toInt();
      return int.tryParse(val?.toString() ?? '') ?? 0;
    }

    double toDouble(dynamic val) {
      if (val is num) return val.toDouble();
      return double.tryParse(val?.toString() ?? '') ?? 0.0;
    }

    return MemberDashboardStats(
      totalSchedules: toInt(json['total_schedules']),
      pendingSchedules: toInt(json['pending']),
      approvedSchedules: toInt(json['approved']),
      rejectedSchedules: toInt(json['rejected']),
      totalEvents: toInt(json['total_events']),
      coordinatorEvents: toInt(json['coordinator_events']),
      approvedFee: toDouble(json['approved_fee']),
      estimatedFee: toDouble(json['estimated_fee']),
    );
  }
}

class MemberDashboardData {
  const MemberDashboardData({
    required this.member,
    this.schedules = const [],
    this.events = const [],
    this.stats = const MemberDashboardStats(),
  });

  final MemberProfile member;
  final List<MemberSchedule> schedules;
  final List<MemberEvent> events;
  final MemberDashboardStats stats;

  MemberDashboardData copyWith({
    MemberProfile? member,
    List<MemberSchedule>? schedules,
    List<MemberEvent>? events,
    MemberDashboardStats? stats,
  }) {
    return MemberDashboardData(
      member: member ?? this.member,
      schedules: schedules ?? this.schedules,
      events: events ?? this.events,
      stats: stats ?? this.stats,
    );
  }

  factory MemberDashboardData.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final memberJson = root['member'] as Map<String, dynamic>? ?? {};
    final schedulesRaw = root['schedules'] as List<dynamic>? ?? [];
    final eventsRaw = root['event_members'] as List<dynamic>? ?? [];
    final statsJson = root['stats'] as Map<String, dynamic>? ?? {};

    return MemberDashboardData(
      member: MemberProfile.fromJson(memberJson),
      schedules: schedulesRaw
          .whereType<Map<String, dynamic>>()
          .map(MemberSchedule.fromJson)
          .toList(),
      events: eventsRaw
          .whereType<Map<String, dynamic>>()
          .map(MemberEvent.fromEventMemberJson)
          .toList(),
      stats: MemberDashboardStats.fromJson(statsJson),
    );
  }
}

