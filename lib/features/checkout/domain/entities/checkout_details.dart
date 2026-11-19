/// Isian checkout. Disusun mengikuti tabel `bookings`, `events`, dan `clients`.
class CheckoutDetails {
  const CheckoutDetails({
    required this.vendorId,
    required this.brideName,
    required this.groomName,
    required this.eventDate,
    required this.venueName,
    required this.venueAddress,
    required this.venueCity,
    required this.venueProvince,
    required this.guestCount,
    this.ceremonyMinutes = 540, // 09:00 default jadwal di Laravel
    this.receptionMinutes = 1020, // 17:00 default jadwal di Laravel
    this.concept = '',
    this.picName = '',
    this.whatsapp = '',
    this.notes = '',
    this.venueMaps,
  });

  /// Id item yang dipesan: id paket, atau id khusus untuk Custom Order.
  final String vendorId;
  final String brideName;
  final String groomName;
  final DateTime eventDate;

  /// Menit sejak tengah malam (mis. 15:30 = 930).
  final int ceremonyMinutes;
  final int receptionMinutes;
  final String venueName;
  final String venueAddress;
  final String venueCity;
  final String venueProvince;

  /// Tautan Google Maps; null bila tidak diisi.
  final String? venueMaps;
  final int guestCount;

  /// Belum punya kolom di database; dikirim bersama catatan sampai ada.
  final String concept;
  final String picName;

  /// Format internasional, mis. +6281298743210.
  final String whatsapp;
  final String notes;
}
