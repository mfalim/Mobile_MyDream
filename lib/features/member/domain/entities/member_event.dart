class MemberEventTeamItem {
  const MemberEventTeamItem({
    required this.memberId,
    required this.name,
    this.callSign,
    this.role,
    this.position,
    this.attendanceStatus,
    this.isCoordinator = false,
  });

  final int memberId;
  final String name;
  final String? callSign;
  final String? role;
  final String? position;
  final String? attendanceStatus;
  final bool isCoordinator;

  factory MemberEventTeamItem.fromJson(Map<String, dynamic> json) {
    final member = json['member'] as Map<String, dynamic>?;
    final role = json['role']?.toString();
    final roleStr = (role ?? '').toLowerCase();
    final isCoord = roleStr.contains('coordinator') ||
        roleStr.contains('koordinator') ||
        roleStr.contains('lead') ||
        roleStr.contains('director') ||
        (json['is_coordinator'] == true);

    final rawPos = member?['position'] ?? json['position'];
    final posName = rawPos is Map<String, dynamic>
        ? rawPos['name']?.toString()
        : rawPos?.toString();

    final rawMemberId = json['member_id'] ?? member?['id'] ?? json['id'];
    final memberId = rawMemberId is int
        ? rawMemberId
        : (int.tryParse(rawMemberId?.toString() ?? '') ?? 0);

    return MemberEventTeamItem(
      memberId: memberId,
      name: member?['name']?.toString() ?? json['name']?.toString() ?? '',
      callSign: member?['call_sign']?.toString() ?? json['call_sign']?.toString(),
      role: role ?? 'Anggota Tim Pelaksana',
      position: posName,
      attendanceStatus: json['attendance_status']?.toString(),
      isCoordinator: isCoord,
    );
  }
}

class MemberEvent {
  const MemberEvent({
    required this.id,
    required this.eventId,
    required this.eventName,
    this.date,
    this.venue,
    this.clientName,
    this.role,
    this.isCoordinator = false,
    this.attendanceStatus,
    this.actualHours = 0,
    this.totalFee = 0,
    this.paymentStatus,
    this.teamMembers = const [],
  });

  final int id;
  final int eventId;
  final String eventName;
  final String? date;
  final String? venue;
  final String? clientName;
  final String? role;
  final bool isCoordinator;
  final String? attendanceStatus;
  final double actualHours;
  final double totalFee;
  final String? paymentStatus;
  final List<MemberEventTeamItem> teamMembers;

  factory MemberEvent.fromEventMemberJson(Map<String, dynamic> json) {
    final event = json['event'] as Map<String, dynamic>?;
    final booking = event?['booking'] as Map<String, dynamic>?;
    final client = booking?['client'] as Map<String, dynamic>?;
    final role = json['role']?.toString();
    final roleStr = (role ?? '').toLowerCase();
    final isCoord = roleStr.contains('coordinator') ||
        roleStr.contains('koordinator') ||
        roleStr.contains('lead') ||
        roleStr.contains('director') ||
        (json['is_coordinator'] == true);

    final rawTeam = event?['event_members'] as List<dynamic>? ??
        event?['eventMembers'] as List<dynamic>? ??
        [];

    final team = rawTeam
        .whereType<Map<String, dynamic>>()
        .map(MemberEventTeamItem.fromJson)
        .toList();

    String? clientName;
    if (client != null) {
      final groom = client['groom_name']?.toString();
      final bride = client['bride_name']?.toString();
      if (groom != null && bride != null && groom.isNotEmpty && bride.isNotEmpty) {
        clientName = '$groom & $bride';
      } else {
        clientName = groom ?? bride ?? client['name']?.toString();
      }
    }
    clientName ??= booking?['customer_name']?.toString();

    final venue = booking?['venue_name']?.toString() ??
        event?['location']?.toString() ??
        event?['venue']?.toString();

    return MemberEvent(
      id: json['id'] is int
          ? json['id'] as int
          : (int.tryParse(json['id']?.toString() ?? '') ?? 0),
      eventId: json['event_id'] is int
          ? json['event_id'] as int
          : (event?['id'] is int
              ? event!['id'] as int
              : (int.tryParse(json['event_id']?.toString() ?? event?['id']?.toString() ?? '') ?? 0)),
      eventName: event?['name']?.toString() ?? 'Event Wedding',
      date: event?['event_date']?.toString() ?? event?['date']?.toString(),
      venue: venue,
      clientName: clientName,
      role: role ?? 'Anggota Tim Pelaksana',
      isCoordinator: isCoord,
      attendanceStatus: json['attendance_status']?.toString() ?? 'pending',
      actualHours: json['actual_hours'] is num
          ? (json['actual_hours'] as num).toDouble()
          : (double.tryParse(json['actual_hours']?.toString() ?? '') ?? 0.0),
      totalFee: json['total_fee'] is num
          ? (json['total_fee'] as num).toDouble()
          : (double.tryParse(json['total_fee']?.toString() ?? '') ?? 0.0),
      paymentStatus: json['payment_status']?.toString() ?? 'pending',
      teamMembers: team,
    );
  }
}

