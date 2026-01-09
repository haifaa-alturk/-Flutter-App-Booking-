class Booking {
  final int id;
  final int apartmentId;
  final String apartmentName;
  final String userPhone;
  final DateTime fromDate;
  final DateTime toDate;
  final int guests;
  final double pricePerNight;
  final double totalPrice;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.apartmentId,
    required this.apartmentName,
    required this.userPhone,
    required this.fromDate,
    required this.toDate,
    required this.guests,
    required this.pricePerNight,
    required this.totalPrice,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
