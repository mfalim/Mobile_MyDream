/// Selisih hari kalender dari [now] ke [target]. Negatif bila sudah lewat.
/// Dihitung dari tanggalnya saja (jam diabaikan), dalam UTC supaya tidak
/// terpengaruh pergantian jam musim.
int daysUntil(DateTime target, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final a = DateTime.utc(today.year, today.month, today.day);
  final b = DateTime.utc(target.year, target.month, target.day);
  return b.difference(a).inDays;
}
