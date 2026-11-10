class MemberSchedule {
  const MemberSchedule({
    required this.id,
    required this.eventId,
    this.eventName,
    this.clientName,
    required this.title,
    this.startTime,
    this.endTime,
    this.location,
    required this.status,
    this.notes,
    this.vendorName,
    this.vendorCategory,
    this.memberId,
    this.picName,
  });

  final int id;
  final int eventId;
  final String? eventName;
  final String? clientName;
  final String title;
  final String? startTime;
  final String? endTime;
  final String? location;
  final String status; // 'pending', 'approved', 'rejected'
  final String? notes;
  final String? vendorName;
  final String? vendorCategory;
  final int? memberId;
  final String? picName;

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  MemberSchedule copyWith({
    String? status,
    int? memberId,
    String? picName,
  }) =>
      MemberSchedule(
        id: id,
        eventId: eventId,
        eventName: eventName,
        clientName: clientName,
        title: title,
        startTime: startTime,
        endTime: endTime,
        location: location,
        status: status ?? this.status,
        notes: notes,
        vendorName: vendorName,
        vendorCategory: vendorCategory,
        memberId: memberId ?? this.memberId,
        picName: picName ?? this.picName,
      );

  factory MemberSchedule.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final event = root['event'] as Map<String, dynamic>?;
    final booking = event?['booking'] as Map<String, dynamic>?;
    final client = booking?['client'] as Map<String, dynamic>?;
    final vendor = root['vendor'] as Map<String, dynamic>?;
    final rawCat = vendor?['category'];
    final catName = rawCat is Map<String, dynamic>
        ? rawCat['name']?.toString()
        : (rawCat is String ? rawCat : root['vendor_category']?.toString());
    final member = root['member'] as Map<String, dynamic>?;

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
    clientName ??= root['client_name']?.toString();

    int toInt(dynamic val) {
      if (val is int) return val;
      return int.tryParse(val?.toString() ?? '') ?? 0;
    }

    int? toNullableInt(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      return int.tryParse(val.toString());
    }

    return MemberSchedule(
      id: toInt(root['id']),
      eventId: toInt(root['event_id']),
      eventName: event?['name']?.toString() ?? root['event_name']?.toString(),
      clientName: clientName,
      title: root['activity']?.toString() ??
          root['activity_name']?.toString() ??
          root['title']?.toString() ??
          'Aktivitas Jadwal',
      startTime: root['start_time']?.toString(),
      endTime: root['end_time']?.toString(),
      location: root['location']?.toString(),
      status: root['status']?.toString() ?? 'pending',
      notes: root['notes']?.toString(),
      vendorName: vendor?['name']?.toString() ?? root['vendor_name']?.toString(),
      vendorCategory: catName,
      memberId: toNullableInt(root['member_id']),
      picName: member?['name']?.toString() ?? root['pic_name']?.toString(),
    );
  }
}

