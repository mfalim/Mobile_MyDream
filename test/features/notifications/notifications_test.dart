import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/notifications/presentation/providers/notification_prefs_provider.dart';
import 'package:w51/features/notifications/presentation/providers/notifications_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  test('jumlah belum dibaca mengikuti daftar', () async {
    final list = await container.read(notificationsProvider.future);
    final unread = list.where((n) => !n.read).length;
    expect(unread, greaterThan(0));
    expect(container.read(unreadCountProvider), unread);
  });

  test('markRead mengubah satu notifikasi, markAllRead semuanya', () async {
    final list = await container.read(notificationsProvider.future);
    final unread = list.where((n) => !n.read).length;
    final first = list.firstWhere((n) => !n.read);

    container.read(notificationsProvider.notifier).markRead(first.id);
    expect(container.read(unreadCountProvider), unread - 1);

    container.read(notificationsProvider.notifier).markAllRead();
    expect(container.read(unreadCountProvider), 0);
  });

  test('berganti akun memuat ulang daftar dan mereset status baca', () async {
    await container.read(notificationsProvider.future);
    container.read(notificationsProvider.notifier).markAllRead();
    expect(container.read(unreadCountProvider), 0);

    container.read(authProvider.notifier).signInDemo(email: 'a@b.com');
    final reloaded = await container.read(notificationsProvider.future);
    expect(reloaded.where((n) => !n.read), isNotEmpty);
  });

  test('preferensi: awalnya semua aktif, dan masing-masing bisa diubah', () {
    var prefs = container.read(notificationPrefsProvider);
    expect(prefs.orders && prefs.reminders && prefs.promos, isTrue);

    final c = container.read(notificationPrefsProvider.notifier);
    c.setPromos(false);
    prefs = container.read(notificationPrefsProvider);
    expect(prefs.promos, isFalse);
    expect(prefs.orders, isTrue);
    expect(prefs.reminders, isTrue);

    c.setOrders(false);
    c.setReminders(false);
    prefs = container.read(notificationPrefsProvider);
    expect(prefs.orders || prefs.reminders || prefs.promos, isFalse);
  });

  test('notifikasi yang punya tujuan memakai alamat internal', () async {
    final list = await container.read(notificationsProvider.future);
    final withRoute = list.where((n) => n.route != null).toList();
    expect(withRoute, isNotEmpty);
    for (final n in withRoute) {
      expect(n.route!.startsWith('/'), isTrue, reason: n.id);
    }
  });
}
