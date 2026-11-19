import 'package:w51/core/utils/json_helpers.dart';

class ClientPaymentRecord {
  const ClientPaymentRecord({
    required this.id,
    required this.type,
    required this.amount,
    required this.method,
    required this.status,
    this.transactionStatus,
    this.midtransOrderId,
    this.bankInfo,
    this.proofPath,
    this.adminNote,
    this.createdAt,
    this.verifiedAt,
  });

  final int id;
  final String type; // dp, full, remaining
  final int amount;
  final String method; // midtrans, bank_transfer
  final String status; // initiated, pending, verified, rejected
  final String? transactionStatus;
  final String? midtransOrderId;
  final String? bankInfo;
  final String? proofPath;
  final String? adminNote;
  final DateTime? createdAt;
  final DateTime? verifiedAt;

  String get typeLabel => switch (type) {
        'dp' => 'Down Payment (DP)',
        'full' => 'Pelunasan Penuh (100%)',
        'remaining' => 'Pelunasan Sisa',
        _ => type.toUpperCase(),
      };

  String get statusLabel => switch (status) {
        'verified' => 'Terverifikasi',
        'pending' => 'Menunggu Verifikasi',
        'initiated' => 'Menunggu Pembayaran',
        'rejected' => 'Ditolak / Kedaluwarsa',
        _ => status,
      };

  factory ClientPaymentRecord.fromJson(Map<String, dynamic> json) {
    return ClientPaymentRecord(
      id: jsonInt(json['id']) ?? 0,
      type: jsonString(json['type']) ?? 'dp',
      amount: jsonInt(json['amount']) ?? 0,
      method: jsonString(json['method']) ?? 'midtrans',
      status: jsonString(json['status']) ?? 'pending',
      transactionStatus: jsonString(json['transaction_status']),
      midtransOrderId: jsonString(json['midtrans_order_id']),
      bankInfo: jsonString(json['bank_info']),
      proofPath: jsonString(json['proof_path']),
      adminNote: jsonString(json['admin_note']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse('${json['created_at']}')
          : null,
      verifiedAt: json['verified_at'] != null
          ? DateTime.tryParse('${json['verified_at']}')
          : null,
    );
  }
}

class ClientScheduleItem {
  const ClientScheduleItem({
    required this.id,
    required this.activity,
    required this.status,
    this.vendorId,
    this.vendorName,
    this.vendorCategory,
    this.startTime,
    this.endTime,
    this.location,
    this.notes,
    this.picMemberName,
    this.picMemberCallSign,
  });

  final int id;
  final String activity;
  final String status; // pending, approved, rejected
  final int? vendorId;
  final String? vendorName;
  final String? vendorCategory;
  final String? startTime;
  final String? endTime;
  final String? location;
  final String? notes;
  final String? picMemberName;
  final String? picMemberCallSign;

  String get timeRangeLabel {
    final start = _extractTime(startTime);
    final end = _extractTime(endTime);
    if (start != null && end != null) return '$start – $end WIB';
    if (start != null) return '$start WIB';
    return 'Waktu diatur Admin';
  }

  String get statusLabel => switch (status) {
        'approved' => 'Siap / Terjadwal',
        'rejected' => 'Perlu Penyesuaian',
        _ => 'Disusun Admin',
      };

  static String? _extractTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parts = raw.trim().split(RegExp(r'[ T]'));
    final segments = parts.last.split(':');
    if (segments.length >= 2) {
      return '${segments[0].padLeft(2, '0')}:${segments[1].padLeft(2, '0')}';
    }
    return raw.trim();
  }

  factory ClientScheduleItem.fromJson(Map<String, dynamic> json) {
    final vendor = json['vendor'] is Map
        ? Map<String, dynamic>.from(json['vendor'] as Map)
        : null;
    final category = vendor != null && vendor['category'] is Map
        ? Map<String, dynamic>.from(vendor['category'] as Map)
        : null;
    final member = json['member'] is Map
        ? Map<String, dynamic>.from(json['member'] as Map)
        : null;

    return ClientScheduleItem(
      id: jsonInt(json['id']) ?? 0,
      activity: jsonString(json['activity']) ??
          jsonString(vendor?['name']) ??
          'Aktivitas Acara',
      status: jsonString(json['status']) ?? 'pending',
      vendorId: jsonInt(json['vendor_id']) ?? jsonInt(vendor?['id']),
      vendorName: jsonString(vendor?['name']),
      vendorCategory: jsonString(category?['name']),
      startTime: jsonString(json['start_time']),
      endTime: jsonString(json['end_time']),
      location: jsonString(json['location']),
      notes: jsonString(json['notes']),
      picMemberName: jsonString(member?['name']),
      picMemberCallSign: jsonString(member?['call_sign']),
    );
  }
}

class ClientEventCrew {
  const ClientEventCrew({
    required this.id,
    required this.memberName,
    required this.role,
    required this.status,
    this.callSign,
  });

  final int id;
  final String memberName;
  final String role;
  final String status;
  final String? callSign;

  factory ClientEventCrew.fromJson(Map<String, dynamic> json) {
    final member = json['member'] is Map
        ? Map<String, dynamic>.from(json['member'] as Map)
        : null;
    return ClientEventCrew(
      id: jsonInt(json['id']) ?? 0,
      memberName: jsonString(member?['name']) ?? 'Kru MyDream',
      role: jsonString(json['role']) ?? 'Crew',
      status: jsonString(json['status']) ?? 'assigned',
      callSign: jsonString(member?['call_sign']),
    );
  }
}

class ClientEventItem {
  const ClientEventItem({
    required this.id,
    required this.bookingId,
    required this.name,
    required this.eventType,
    required this.status,
    required this.guestCount,
    this.eventDate,
    this.packageName,
    this.notes,
    this.schedules = const [],
    this.crew = const [],
    this.hasReview = false,
    this.reviewRating,
    this.reviewExcerpt,
    this.reviewContent,
  });

  final int id;
  final int bookingId;
  final String name;
  final String eventType;
  final String status; // pending, upcoming, ongoing, completed, cancelled
  final int guestCount;
  final DateTime? eventDate;
  final String? packageName;
  final String? notes;
  final List<ClientScheduleItem> schedules;
  final List<ClientEventCrew> crew;
  final bool hasReview;
  final int? reviewRating;
  final String? reviewExcerpt;
  final String? reviewContent;

  bool get isCompleted => status == 'completed';

  int get approvedScheduleCount =>
      schedules.where((s) => s.status == 'approved').length;

  String get statusLabel => switch (status) {
        'completed' => 'Selesai Dilaksanakan',
        'ongoing' => 'Sedang Berlangsung',
        'upcoming' => 'Akan Datang',
        'cancelled' => 'Dibatalkan',
        _ => 'Menunggu Konfirmasi',
      };

  factory ClientEventItem.fromJson(Map<String, dynamic> json) {
    final schedulesRaw =
        json['schedules'] is List ? json['schedules'] as List : const [];
    final crewRaw = json['event_members'] is List
        ? json['event_members'] as List
        : const [];
    final bookingMap = json['booking'] is Map
        ? Map<String, dynamic>.from(json['booking'] as Map)
        : null;
    final reviewMap = json['review'] is Map
        ? Map<String, dynamic>.from(json['review'] as Map)
        : null;

    return ClientEventItem(
      id: jsonInt(json['id']) ?? 0,
      bookingId: jsonInt(json['booking_id']) ?? jsonInt(bookingMap?['id']) ?? 0,
      name: jsonString(json['name']) ?? 'Acara Pernikahan',
      eventType: jsonString(json['event_type']) ?? 'wedding',
      status: jsonString(json['status']) ?? 'upcoming',
      guestCount: jsonInt(json['guest_count']) ?? 0,
      eventDate: json['event_date'] != null
          ? DateTime.tryParse('${json['event_date']}')
          : null,
      packageName: jsonNameOf(json['package']) ??
          jsonNameOf(bookingMap?['package']),
      notes: jsonString(json['notes']),
      schedules: [
        for (final item in schedulesRaw.whereType<Map>())
          ClientScheduleItem.fromJson(Map<String, dynamic>.from(item)),
      ],
      crew: [
        for (final item in crewRaw.whereType<Map>())
          ClientEventCrew.fromJson(Map<String, dynamic>.from(item)),
      ],
      hasReview: json['has_review'] == true || reviewMap != null,
      reviewRating: jsonInt(reviewMap?['rating']),
      reviewExcerpt: jsonString(reviewMap?['excerpt']),
      reviewContent: jsonString(reviewMap?['content']),
    );
  }
}
