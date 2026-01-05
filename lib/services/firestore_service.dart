import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/hotel_model.dart';
import '../models/tour_model.dart';
import '../models/booking_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== USER OPERATIONS ====================

  Future<void> createUser(UserModel user) async {
    try {
      await _db.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      rethrow;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _db.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _db.collection('users').doc(userId).delete();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  // ==================== HOTEL OPERATIONS ====================

  Stream<List<Hotel>> getHotels() {
    return _db.collection('hotels').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Hotel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<Hotel?> getHotel(String hotelId) async {
    try {
      DocumentSnapshot doc = await _db.collection('hotels').doc(hotelId).get();
      if (doc.exists) {
        return Hotel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting hotel: $e');
      rethrow;
    }
  }

  Stream<List<Hotel>> searchHotels({String? city, double? maxPrice}) {
    Query query = _db.collection('hotels');

    if (city != null && city.isNotEmpty) {
      query = query.where('city', isEqualTo: city);
    }

    if (maxPrice != null) {
      query = query.where('pricePerNight', isLessThanOrEqualTo: maxPrice);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Hotel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> updateHotelAvailableRooms(
    String hotelId,
    int roomsBooked,
  ) async {
    try {
      await _db.collection('hotels').doc(hotelId).update({
        'availableRooms': FieldValue.increment(-roomsBooked),
      });
    } catch (e) {
      print('Error updating hotel available rooms: $e');
      rethrow;
    }
  }

  // ==================== TOUR OPERATIONS ====================

  Stream<List<Tour>> getTours() {
    return _db.collection('tours').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Tour.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<Tour?> getTour(String tourId) async {
    try {
      DocumentSnapshot doc = await _db.collection('tours').doc(tourId).get();
      if (doc.exists) {
        return Tour.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting tour: $e');
      rethrow;
    }
  }

  Stream<List<Tour>> searchTours({String? destination, double? maxPrice}) {
    Query query = _db.collection('tours');

    if (destination != null && destination.isNotEmpty) {
      query = query.where('destination', isEqualTo: destination);
    }

    if (maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: maxPrice);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Tour.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // ==================== BOOKING OPERATIONS ====================

  Future<String> createBooking(Booking booking) async {
    try {
      DocumentReference docRef = await _db
          .collection('bookings')
          .add(booking.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating booking: $e');
      rethrow;
    }
  }

  Stream<List<Booking>> getUserBookings(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        // Bỏ orderBy để tránh cần tạo composite index
        // Sẽ sắp xếp ở client side trong UI
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Booking.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  Future<Booking?> getBooking(String bookingId) async {
    try {
      DocumentSnapshot doc = await _db
          .collection('bookings')
          .doc(bookingId)
          .get();
      if (doc.exists) {
        return Booking.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting booking: $e');
      rethrow;
    }
  }

  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    try {
      await _db.collection('bookings').doc(bookingId).update({
        'status': status.toString().split('.').last,
      });
    } catch (e) {
      print('Error updating booking status: $e');
      rethrow;
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await updateBookingStatus(bookingId, BookingStatus.cancelled);
    } catch (e) {
      print('Error cancelling booking: $e');
      rethrow;
    }
  }
}
