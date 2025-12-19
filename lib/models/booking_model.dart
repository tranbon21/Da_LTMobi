enum BookingType { hotel, tour }

enum BookingStatus { pending, confirmed, cancelled, completed }

class Booking {
  final String id;
  final String userId;
  final BookingType type;
  final String itemId; // hotelId or tourId
  final String itemName;
  final DateTime bookingDate;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfGuests;
  final double totalPrice;
  final BookingStatus status;
  final String? specialRequests;
  final Map<String, dynamic>? additionalInfo;

  Booking({
    required this.id,
    required this.userId,
    required this.type,
    required this.itemId,
    required this.itemName,
    required this.bookingDate,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
    required this.totalPrice,
    required this.status,
    this.specialRequests,
    this.additionalInfo,
  });

  factory Booking.fromMap(Map<String, dynamic> map, String id) {
    return Booking(
      id: id,
      userId: map['userId'] ?? '',
      type: BookingType.values.firstWhere(
        (e) => e.toString() == 'BookingType.${map['type']}',
        orElse: () => BookingType.hotel,
      ),
      itemId: map['itemId'] ?? '',
      itemName: map['itemName'] ?? '',
      bookingDate: DateTime.parse(
        map['bookingDate'] ?? DateTime.now().toIso8601String(),
      ),
      checkInDate: DateTime.parse(
        map['checkInDate'] ?? DateTime.now().toIso8601String(),
      ),
      checkOutDate: DateTime.parse(
        map['checkOutDate'] ?? DateTime.now().toIso8601String(),
      ),
      numberOfGuests: map['numberOfGuests'] ?? 1,
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == 'BookingStatus.${map['status']}',
        orElse: () => BookingStatus.pending,
      ),
      specialRequests: map['specialRequests'],
      additionalInfo: map['additionalInfo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.toString().split('.').last,
      'itemId': itemId,
      'itemName': itemName,
      'bookingDate': bookingDate.toIso8601String(),
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'numberOfGuests': numberOfGuests,
      'totalPrice': totalPrice,
      'status': status.toString().split('.').last,
      'specialRequests': specialRequests,
      'additionalInfo': additionalInfo,
    };
  }

  int get numberOfNights => checkOutDate.difference(checkInDate).inDays;

  Booking copyWith({
    String? id,
    String? userId,
    BookingType? type,
    String? itemId,
    String? itemName,
    DateTime? bookingDate,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? numberOfGuests,
    double? totalPrice,
    BookingStatus? status,
    String? specialRequests,
    Map<String, dynamic>? additionalInfo,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      bookingDate: bookingDate ?? this.bookingDate,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      specialRequests: specialRequests ?? this.specialRequests,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}
