import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/app/providers/api_providers.dart';
import 'package:w51/core/config/app_config.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/home/presentation/providers/home_provider.dart';
import 'package:w51/features/inspirations/presentation/providers/inspirations_provider.dart';
import 'package:w51/features/my_wedding/domain/entities/client_portal_models.dart';
import 'package:w51/features/payment/presentation/providers/payments_provider.dart';

/// Mengambil daftar rangkaian acara & jadwal rundown klien (`GET /api/client/events`).
final clientEventsProvider =
    FutureProvider<List<ClientEventItem>>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null || user.role == 'member') {
    return const [];
  }
  if (AppConfig.useMockData) {
    final bookings = await ref.watch(clientBookingsProvider.future);
    return bookings.expand((b) => b.events).toList();
  }

  final api = ref.watch(apiClientProvider);
  final raw = await api.get('/client/events');
  final list = raw is List
      ? raw
      : (raw is Map && raw['data'] is List ? raw['data'] as List : const []);
  return [
    for (final item in list.whereType<Map>())
      ClientEventItem.fromJson(Map<String, dynamic>.from(item)),
  ];
});

/// Mengajukan rangkaian acara baru pada reservasi klien (`POST /api/client/events`).
Future<void> createClientEvent(
  WidgetRef ref, {
  required int bookingId,
  required String name,
  required String eventType,
  required DateTime eventDate,
  required int guestCount,
  String? notes,
}) async {
  if (AppConfig.useMockData) return;

  final dateStr =
      '${eventDate.year.toString().padLeft(4, '0')}-'
      '${eventDate.month.toString().padLeft(2, '0')}-'
      '${eventDate.day.toString().padLeft(2, '0')}';

  await ref.read(apiClientProvider).post(
    '/client/events',
    body: {
      'booking_id': bookingId,
      'name': name.trim(),
      'event_type': eventType.trim(),
      'event_date': dateStr,
      'guest_count': guestCount,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    },
  );
}

/// Mengirim rating & ulasan untuk acara yang telah selesai (`POST /api/client/reviews`).
Future<void> submitClientReview(
  WidgetRef ref, {
  required int eventId,
  required int rating,
  String? excerpt,
  String? comment,
}) async {
  if (AppConfig.useMockData) return;

  await ref.read(apiClientProvider).post(
    '/client/reviews',
    body: {
      'event_id': eventId,
      'rating': rating,
      if (excerpt != null && excerpt.trim().isNotEmpty)
        'excerpt': excerpt.trim(),
      if (comment != null && comment.trim().isNotEmpty)
        'comment': comment.trim(),
    },
  );
  ref.invalidate(inspirationsDataProvider);
  ref.invalidate(homeDataProvider);
}
