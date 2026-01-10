import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper class để quản lý thông báo của user
/// 
/// Lưu thông báo vào collection 'user_notifications' trên Firebase
class UserNotificationHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tạo thông báo mới cho user
  /// 
  /// **Parameters:**
  /// - `userId`: ID của user nhận thông báo
  /// - `type`: Loại thông báo (booking, promotion, payment, review, system, general)
  /// - `title`: Tiêu đề thông báo
  /// - `message`: Nội dung chi tiết
  /// - `data`: Dữ liệu thêm (optional) - ví dụ: bookingId, promotionId, etc.
  static Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore.collection('user_notifications').add({
        'userId': userId,
        'type': type,
        'title': title,
        'message': message,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
        ...?data, // Merge thêm data nếu có
      });
      
      print('✅ Đã tạo thông báo cho user: $userId');
      print('   📌 Type: $type');
      print('   📝 Title: $title');
    } catch (e) {
      print('❌ Lỗi tạo thông báo: $e');
    }
  }

  /// Tạo thông báo đặt tour thành công
  static Future<void> createTourBookingNotification({
    required String userId,
    required String tourName,
    required String bookingId,
    required double totalPrice,
  }) async {
    await createNotification(
      userId: userId,
      type: 'booking',
      title: '🎉 Đặt tour thành công!',
      message: 'Tour "$tourName" đã được đặt thành công. Tổng tiền: ${_formatCurrency(totalPrice)}',
      data: {
        'bookingId': bookingId,
        'tourName': tourName,
        'totalPrice': totalPrice,
        'bookingType': 'tour',
      },
    );
  }

  /// Tạo thông báo đặt phòng khách sạn thành công
  static Future<void> createHotelBookingNotification({
    required String userId,
    required String hotelName,
    required String bookingId,
    required double totalPrice,
    required int nights,
  }) async {
    await createNotification(
      userId: userId,
      type: 'booking',
      title: '🏨 Đặt phòng thành công!',
      message: 'Khách sạn "$hotelName" đã được đặt thành công ($nights đêm). Tổng tiền: ${_formatCurrency(totalPrice)}',
      data: {
        'bookingId': bookingId,
        'hotelName': hotelName,
        'totalPrice': totalPrice,
        'nights': nights,
        'bookingType': 'hotel',
      },
    );
  }

  /// Tạo thông báo khuyến mãi
  static Future<void> createPromotionNotification({
    required String userId,
    required String title,
    required String message,
    String? promotionId,
  }) async {
    await createNotification(
      userId: userId,
      type: 'promotion',
      title: title,
      message: message,
      data: promotionId != null ? {'promotionId': promotionId} : null,
    );
  }

  /// Tạo thông báo thanh toán
  static Future<void> createPaymentNotification({
    required String userId,
    required String title,
    required String message,
    String? bookingId,
  }) async {
    await createNotification(
      userId: userId,
      type: 'payment',
      title: title,
      message: message,
      data: bookingId != null ? {'bookingId': bookingId} : null,
    );
  }

  /// Format tiền tệ VND
  static String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}₫';
  }
}
