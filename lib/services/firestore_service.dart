import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/hotel_model.dart';
import '../models/tour_model.dart';
import '../models/booking_model.dart';
import '../models/promotion_model.dart';

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

  /// Tạo hotel mới (cho hotel owner)
  ///
  /// Method này cho phép chủ khách sạn đăng bài khách sạn mới
  /// Tham số:
  /// - hotel: Object Hotel chứa thông tin khách sạn
  ///
  /// Trả về: ID của hotel vừa tạo
  Future<String> createHotel(Hotel hotel) async {
    try {
      // Thêm hotel vào collection 'hotels'
      // add() sẽ tự động tạo ID mới
      DocumentReference docRef = await _db
          .collection('hotels')
          .add(hotel.toMap());

      // Trả về ID của document vừa tạo
      return docRef.id;
    } catch (e) {
      // In lỗi ra console để debug
      print('Error creating hotel: $e');

      // Throw lại exception để UI có thể xử lý
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

  /// Tạo tour mới (cho tour operator)
  ///
  /// Method này cho phép nhà cung cấp tour đăng bài tour du lịch mới
  /// Tham số:
  /// - tour: Object Tour chứa thông tin tour
  ///
  /// Trả về: ID của tour vừa tạo
  Future<String> createTour(Tour tour) async {
    try {
      // Thêm tour vào collection 'tours'
      // add() sẽ tự động tạo ID mới
      DocumentReference docRef = await _db
          .collection('tours')
          .add(tour.toMap());

      // Trả về ID của document vừa tạo
      return docRef.id;
    } catch (e) {
      // In lỗi ra console để debug
      print('Error creating tour: $e');

      // Throw lại exception để UI có thể xử lý
      rethrow;
    }
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

  /// Hủy booking (cập nhật status thành cancelled)
  ///
  /// Method này cho phép user hủy booking của mình
  /// Chỉ nên gọi method này nếu:
  /// - Booking status = pending hoặc confirmed
  /// - Chưa quá 24 giờ kể từ khi đặt
  ///
  /// Tham số:
  /// - bookingId: ID của booking cần hủy
  ///
  /// Method này sẽ:
  /// 1. Cập nhật status của booking thành 'cancelled'
  /// 2. Thêm timestamp 'cancelledAt' để ghi nhận thời gian hủy
  Future<void> cancelBooking(String bookingId) async {
    try {
      // Cập nhật document trong collection 'bookings'
      await _db.collection('bookings').doc(bookingId).update({
        // Cập nhật status thành 'cancelled'
        'status': 'cancelled',
        // Thêm timestamp để ghi nhận thời gian hủy
        'cancelledAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // In lỗi ra console để debug
      print('Error cancelling booking: $e');

      // Throw lại exception để UI có thể xử lý
      rethrow;
    }
  }

  // ==================== PROMOTION OPERATIONS ====================

  /// Lấy danh sách promotions (khuyến mãi) từ Firestore
  ///
  /// Method này trả về Stream để lắng nghe realtime updates
  /// Chỉ lấy các promotions đang active (isActive = true)
  ///
  /// Sử dụng trong HomeScreen để hiển thị ưu đãi
  // Stream<List<Promotion>> getPromotions() {
  //   return _db
  //       .collection('promotions')
  //       // Chỉ lấy promotions đang active
  //       .where('isActive', isEqualTo: true)
  //       // Lắng nghe realtime updates
  //       .snapshots()
  //       // Map snapshot thành List<Promotion>
  //       .map((snapshot) {
  //         return snapshot.docs.map((doc) {
  //           // Convert mỗi document thành Promotion object
  //           return Promotion.fromMap(doc.data(), doc.id);
  //         }).toList();
  //       });
  // }

    // ==================== USER PROMOTION OPERATIONS ====================

  /// Lưu khuyến mại cho người dùng (user claim promotion)
  ///
  /// Tham số:
  /// - userId: ID của user claim promotion
  /// - promotion: Promotion object được claim
  /// - type: Loại promotion (hotel_promotion, welcome_package, etc.)
  Future<void> saveUserPromotion({
    required String userId,
    required Promotion promotion,
    String type = 'hotel_promotion',
  }) async {
    try {
      // Kiểm tra xem user đã claim promotion này chưa
      final existingPromotion = await _db
          .collection('user_promotions')
          .where('userId', isEqualTo: userId)
          .where('promotionId', isEqualTo: promotion.id)
          .get();

      if (existingPromotion.docs.isNotEmpty) {
        throw Exception('Bạn đã nhận khuyến mại này rồi');
      }

      // Tạo user_promotion document
      await _db.collection('user_promotions').add({
        'userId': userId,
        'promotionId': promotion.id,
        'hotelId': promotion.hotelId,
        'type': type,
        'discountPercentage': promotion.discountPercentage,
        'endDate': Timestamp.fromDate(promotion.endDate),
        'isUsed': false,
        'claimedAt': FieldValue.serverTimestamp(),
      });

      print('✅ User promotion saved for user $userId');
    } catch (e) {
      print('❌ Error saving user promotion: $e');
      rethrow;
    }
  }

  /// Lấy danh sách promotions của user
  ///
  /// Tham số:
  /// - userId: ID của user
  Stream<List<Map<String, dynamic>>> getUserPromotions(String userId) {
    return _db
        .collection('user_promotions')
        .where('userId', isEqualTo: userId)
        .orderBy('claimedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> result = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        
        // Lấy thông tin promotion chi tiết
        Promotion? promotion;
        try {
          final promotionDoc = await _db
              .collection('promotions')
              .doc(data['promotionId'] as String)
              .get();
          
          if (promotionDoc.exists) {
            promotion = Promotion.fromFirestore(promotionDoc);
          }
        } catch (e) {
          print('Error getting promotion detail: $e');
        }

        result.add({
          'id': doc.id,
          ...data,
          'promotion': promotion,
          'isValid': promotion?.isValid ?? false,
        });
      }

      return result;
    });
  }

  /// Kiểm tra xem user đã claim welcome package chưa
  ///
  /// Tham số:
  /// - userId: ID của user
  Future<bool> hasUserClaimedWelcomePackage(String userId) async {
    try {
      final snapshot = await _db
          .collection('user_promotions')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'welcome_package')
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error checking welcome package: $e');
      return false;
    }
  }

  /// Lấy tất cả promotions từ hệ thống
  Stream<List<Promotion>> getAllPromotions() {
    return _db
        .collection('promotions')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Promotion.fromFirestore(doc);
      }).toList();
    });
  }
}
