import 'package:w51/core/utils/json_helpers.dart';
import 'package:w51/features/my_wedding/domain/entities/client_portal_models.dart';

class ClientBookingSummary {
  const ClientBookingSummary({
    required this.id,
    required this.title,
    required this.paymentStatus,
    required this.total,
    required this.paid,
    required this.pending,
    required this.remaining,
    required this.dpPercent,
    required this.dpAmount,
    required this.percentPaid,
    required this.isOverdue,
    required this.isUrgent,
    this.invoiceNumber,
    this.venueName,
    this.venueCity,
    this.eventDate,
    this.deadline,
    this.deadlineType,
    this.daysToDeadline,
    this.latestPaymentHasProof = false,
    this.bookingStatus = 'pending',
    this.guestCount = 0,
    this.approvedSchedules = 0,
    this.totalSchedules = 0,
    this.payments = const [],
    this.events = const [],
  });

  final int id;
  final String? invoiceNumber;
  final String title;
  final String? venueName;
  final String? venueCity;
  final DateTime? eventDate;
  final String paymentStatus;
  final int total;
  final int paid;
  final int pending;
  final int remaining;
  final int dpPercent;
  final int dpAmount;
  final int percentPaid;
  final DateTime? deadline;
  final String? deadlineType;
  final int? daysToDeadline;
  final bool isOverdue;
  final bool isUrgent;
  final bool latestPaymentHasProof;
  final String bookingStatus;
  final int guestCount;
  final int approvedSchedules;
  final int totalSchedules;
  final List<ClientPaymentRecord> payments;
  final List<ClientEventItem> events;

  bool get isDpPaid => paymentStatus == 'dp_paid';
  bool get isPaid => paymentStatus == 'paid' || (total > 0 && remaining <= 0);
  bool get needsPayment => total > 0 && !isPaid;

  String get bookingStatusLabel => switch (bookingStatus) {
        'approved' => 'Disetujui Admin',
        'rejected' => 'Ditolak Admin',
        _ => 'Menunggu Persetujuan Admin',
      };

  String get paymentStatusLabel => switch (paymentStatus) {
        'paid' => 'Lunas',
        'dp_paid' => 'DP Terverifikasi',
        'awaiting_verification' => 'Menunggu Verifikasi',
        _ => 'Belum Bayar',
      };

  factory ClientBookingSummary.fromJson(Map<String, dynamic> json) {
    final summary = json['payment_summary'] is Map
        ? Map<String, dynamic>.from(json['payment_summary'] as Map)
        : const <String, dynamic>{};

    final eventsRaw = json['events'] is List ? json['events'] as List : const [];
    final parsedEvents = [
      for (final e in eventsRaw.whereType<Map>())
        ClientEventItem.fromJson(Map<String, dynamic>.from(e)),
    ];

    DateTime? firstEventDate;
    for (final e in parsedEvents) {
      final parsed = e.eventDate;
      if (parsed != null &&
          (firstEventDate == null || parsed.isBefore(firstEventDate))) {
        firstEventDate = parsed;
      }
    }

    final paymentsRaw =
        json['payments'] is List ? json['payments'] as List : const [];
    final parsedPayments = [
      for (final p in paymentsRaw.whereType<Map>())
        ClientPaymentRecord.fromJson(Map<String, dynamic>.from(p)),
    ];
    final hasProof = parsedPayments.isNotEmpty &&
        (parsedPayments.first.proofPath ?? '').isNotEmpty;

    final progressMap = json['schedule_progress'] is Map
        ? Map<String, dynamic>.from(json['schedule_progress'] as Map)
        : null;
    final allSchedules = parsedEvents.expand((e) => e.schedules).toList();
    final approvedCount = jsonInt(progressMap?['approved']) ??
        allSchedules.where((s) => s.status == 'approved').length;
    final totalSchedulesCount =
        jsonInt(progressMap?['total']) ?? allSchedules.length;

    final totalVal =
        jsonInt(summary['total']) ?? jsonInt(json['total_price']) ?? 0;
    final paidVal =
        jsonInt(summary['paid']) ?? jsonInt(json['paid_amount']) ?? 0;
    final remainingVal = jsonInt(summary['remaining']) ??
        (totalVal - paidVal > 0 ? totalVal - paidVal : 0);
    final percentPaidVal = jsonInt(summary['percent_paid']) ??
        (totalVal > 0 ? ((paidVal / totalVal) * 100).round().clamp(0, 100) : 0);

    return ClientBookingSummary(
      id: jsonInt(json['id']) ?? 0,
      invoiceNumber: jsonString(json['invoice_number']),
      title: jsonNameOf(json['package']) ?? 'Pernikahan Custom',
      venueName: jsonString(json['venue_name']),
      venueCity: jsonString(json['venue_city']),
      eventDate: firstEventDate,
      paymentStatus: jsonString(summary['status']) ??
          jsonString(json['payment_status']) ??
          'unpaid',
      total: totalVal,
      paid: paidVal,
      pending: jsonInt(summary['pending']) ?? 0,
      remaining: remainingVal,
      dpPercent: jsonInt(summary['dp_percent']) ?? 10,
      dpAmount: jsonInt(summary['dp_amount']) ?? 0,
      percentPaid: percentPaidVal,
      deadline: summary['deadline'] != null
          ? DateTime.tryParse('${summary['deadline']}')
          : null,
      deadlineType: jsonString(summary['deadline_type']),
      daysToDeadline: jsonInt(summary['days_to_deadline']),
      isOverdue: summary['is_overdue'] == true,
      isUrgent: summary['is_urgent'] == true,
      latestPaymentHasProof: hasProof,
      bookingStatus: jsonString(json['status']) ?? 'pending',
      guestCount: jsonInt(json['guest_count']) ?? 0,
      approvedSchedules: approvedCount,
      totalSchedules: totalSchedulesCount,
      payments: parsedPayments,
      events: parsedEvents,
    );
  }
}
