class NotificationPrefs {
  const NotificationPrefs({
    this.orders = true,
    this.reminders = true,
    this.promos = true,
  });

  final bool orders;
  final bool reminders;
  final bool promos;

  NotificationPrefs copyWith({bool? orders, bool? reminders, bool? promos}) =>
      NotificationPrefs(
        orders: orders ?? this.orders,
        reminders: reminders ?? this.reminders,
        promos: promos ?? this.promos,
      );
}
