import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/features/notifications/domain/entities/notification_prefs.dart';

/// Preferensi notifikasi. Saat ini hanya di memori (prototype); nanti
/// disimpan lewat API.
final notificationPrefsProvider =
    NotifierProvider<NotificationPrefsController, NotificationPrefs>(
  NotificationPrefsController.new,
);

class NotificationPrefsController extends Notifier<NotificationPrefs> {
  @override
  NotificationPrefs build() => const NotificationPrefs();

  void setOrders(bool value) => state = state.copyWith(orders: value);
  void setReminders(bool value) => state = state.copyWith(reminders: value);
  void setPromos(bool value) => state = state.copyWith(promos: value);
}
