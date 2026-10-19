class CheckoutDetails {
  const CheckoutDetails({
    required this.vendorId,
    required this.brideName,
    required this.groomName,
    required this.eventDate,
    required this.ceremonyTime,
    required this.receptionTime,
    required this.city,
    required this.hallDetail,
    required this.guestCount,
    required this.guestExtraCost,
    required this.concept,
    required this.picName,
    required this.whatsapp,
    required this.notes,
  });

  final String vendorId;
  final String brideName;
  final String groomName;
  final DateTime eventDate;
  final String ceremonyTime;
  final String receptionTime;
  final String city;
  final String hallDetail;
  final int guestCount;
  final int guestExtraCost;
  final String concept;
  final String picName;
  final String whatsapp;
  final String notes;
}
