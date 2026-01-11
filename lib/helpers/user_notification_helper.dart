import 'package:cloud_firestore/cloud_firestore.dart';

/// ============================================================================
/// USER NOTIFICATION HELPER
/// ============================================================================
/// 
/// **Mục đích:**
/// Helper class để quản lý việc tạo và lưu thông báo cho user vào Firebase
/// 
/// **Chức năng chính:**
/// - Lưu thông báo vào collection 'user_notifications' trên Firestore
/// - Tự động tạo thông báo khi user đặt tour/hotel thành công
/// - Hỗ trợ nhiều loại thông báo: booking, promotion, payment, review, system
/// 
/// **Cách sử dụng:**
/// ```dart
/// // Tạo thông báo đặt tour
/// await UserNotificationHelper.createTourBookingNotification(
///   userId: 'user123',
///   tourName: 'Tour Hạ Long',
///   bookingId: 'booking456',
///   totalPrice: 8500000,
/// );
/// ```
/// ============================================================================
class UserNotificationHelper {
  // Firebase Firestore instance để tương tác với database
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ==========================================================================
  /// TẠO THÔNG BÁO CHUNG
  /// ==========================================================================
  /// 
  /// **Chức năng:**
  /// Method cơ bản để tạo một thông báo mới trong Firestore
  /// Tất cả các method khác đều gọi method này
  /// 
  /// **Parameters:**
  /// - `userId`: ID của user sẽ nhận thông báo (required)
  /// - `type`: Loại thông báo (booking/promotion/payment/review/system/general)
  /// - `title`: Tiêu đề thông báo hiển thị cho user
  /// - `message`: Nội dung chi tiết thông báo
  /// - `data`: Map chứa dữ liệu bổ sung (bookingId, totalPrice, etc.)
  /// 
  /// **Cấu trúc document trong Firestore:**
  /// ```
  /// user_notifications/{auto-generated-id}
  /// {
  ///   userId: "user123",
  ///   type: "booking",
  ///   title: "🎉 Đặt tour thành công!",
  ///   message: "Tour 'Hạ Long' đã được đặt...",
  ///   read: false,
  ///   createdAt: Timestamp,
  ///   bookingId: "booking456",
  ///   totalPrice: 8500000,
  ///   ...
  /// }
  /// ```
  /// 
  /// **Luồng xử lý:**
  /// 1. Thêm document mới vào collection 'user_notifications'
  /// 2. Set trường 'read' = false (thông báo chưa đọc)
  /// 3. Set 'createdAt' = server timestamp (thời gian tạo)
  /// 4. Merge thêm data bổ sung nếu có
  /// 5. Print log để debug
  /// ==========================================================================
  static Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Thêm thông báo mới vào Firestore
      await _firestore.collection('user_notifications').add({
        // Thông tin cơ bản
        'userId': userId,           // User nào nhận thông báo
        'type': type,               // Loại thông báo (booking, promotion...)
        'title': title,             // Tiêu đề hiển thị
        'message': message,         // Nội dung chi tiết
        'read': false,              // Mặc định chưa đọc
        
        // Timestamp tự động từ server (đảm bảo thời gian chính xác)
        'createdAt': FieldValue.serverTimestamp(),
        
        // Merge thêm data bổ sung (bookingId, totalPrice, etc.)
        // Toán tử ...? nghĩa là: nếu data != null thì spread các key-value vào map
        ...?data,
      });
      
      // Log để debug (chỉ dùng khi development)
      print('✅ Đã tạo thông báo cho user: $userId');
      print('   📌 Type: $type');
      print('   📝 Title: $title');
    } catch (e) {
      // Bắt lỗi nếu không thể lưu vào Firestore
      // Không throw lại để không làm app crash
      print('❌ Lỗi tạo thông báo: $e');
    }
  }

  /// ==========================================================================
  /// TẠO THÔNG BÁO ĐẶT TOUR THÀNH CÔNG
  /// ==========================================================================
  /// 
  /// **Khi nào gọi:**
  /// Gọi method này sau khi user đặt tour thành công
  /// 
  /// **Vị trí gọi:**
  /// File: tour_detail_screen.dart
  /// Function: _bookTour() - sau khi lưu booking vào Firestore
  /// 
  /// **Ví dụ:**
  /// ```dart
  /// final bookingId = await FirestoreService().createBooking(booking);
  /// 
  /// // Tạo thông báo ngay sau khi đặt tour thành công
  /// await UserNotificationHelper.createTourBookingNotification(
  ///   userId: userId,
  ///   tourName: 'Tour Hạ Long - Sapa',
  ///   bookingId: bookingId,
  ///   totalPrice: 8500000,
  /// );
  /// ```
  /// 
  /// **Data được lưu thêm:**
  /// - bookingId: Để navigate đến chi tiết booking
  /// - tourName: Tên tour đã đặt
  /// - totalPrice: Tổng tiền đã thanh toán (hiển thị riêng)
  /// - bookingType: 'tour' (phân biệt với hotel)
  /// ==========================================================================
  static Future<void> createTourBookingNotification({
    required String userId,
    required String tourName,
    required String bookingId,
    required double totalPrice,
  }) async {
    // Gọi method createNotification với các tham số cụ thể cho tour
    await createNotification(
      userId: userId,
      type: 'booking',                                    // Loại: booking
      title: '🎉 Đặt tour thành công!',                   // Tiêu đề với emoji
      
      // Message: Mô tả chi tiết (totalPrice sẽ hiển thị riêng ở UI)
      message: 'Tour "$tourName" đã được đặt thành công. Tổng tiền: ${_formatCurrency(totalPrice)}',
      
      // Data bổ sung để sử dụng trong UI
      data: {
        'bookingId': bookingId,           // ID để navigate
        'tourName': tourName,             // Tên tour
        'totalPrice': totalPrice,         // Số tiền (số, không phải string)
        'bookingType': 'tour',            // Phân biệt tour vs hotel
      },
    );
  }

  /// ==========================================================================
  /// TẠO THÔNG BÁO ĐẶT PHÒNG KHÁCH SẠN THÀNH CÔNG
  /// ==========================================================================
  /// 
  /// **Khi nào gọi:**
  /// Gọi sau khi user đặt phòng khách sạn thành công
  /// 
  /// **Vị trí gọi:**
  /// File: hotel_detail_screen.dart
  /// Function: _processPayment() - sau khi lưu booking và update available rooms
  /// 
  /// **Khác biệt với tour:**
  /// - Có thêm tham số `nights` (số đêm)
  /// - Title khác: "🏨 Đặt phòng thành công!"
  /// - bookingType: 'hotel'
  /// ==========================================================================
  static Future<void> createHotelBookingNotification({
    required String userId,
    required String hotelName,
    required String bookingId,
    required double totalPrice,
    required int nights,                                  // Số đêm (khác với tour)
  }) async {
    await createNotification(
      userId: userId,
      type: 'booking',
      title: '🏨 Đặt phòng thành công!',                  // Icon khách sạn
      
      // Message bao gồm số đêm
      message: 'Khách sạn "$hotelName" đã được đặt thành công ($nights đêm). Tổng tiền: ${_formatCurrency(totalPrice)}',
      
      data: {
        'bookingId': bookingId,
        'hotelName': hotelName,
        'totalPrice': totalPrice,
        'nights': nights,                                 // Thêm số đêm
        'bookingType': 'hotel',                           // Phân biệt với tour
      },
    );
  }

  /// ==========================================================================
  /// TẠO THÔNG BÁO KHUYẾN MÃI
  /// ==========================================================================
  /// 
  /// **Khi nào dùng:**
  /// - Admin muốn gửi thông báo khuyến mãi cho user
  /// - Có chương trình sale mới
  /// 
  /// **Ví dụ:**
  /// ```dart
  /// await UserNotificationHelper.createPromotionNotification(
  ///   userId: 'user123',
  ///   title: '🔥 Flash Sale 50%!',
  ///   message: 'Giảm 50% tất cả tour trong 24h',
  ///   promotionId: 'promo456',
  /// );
  /// ```
  /// ==========================================================================
  static Future<void> createPromotionNotification({
    required String userId,
    required String title,
    required String message,
    String? promotionId,                                  // Optional: ID khuyến mãi
  }) async {
    await createNotification(
      userId: userId,
      type: 'promotion',                                  // Loại: promotion
      title: title,
      message: message,
      
      // Chỉ thêm promotionId nếu có
      // If promotionId != null thì data = {'promotionId': ...}, else null
      data: promotionId != null ? {'promotionId': promotionId} : null,
    );
  }

  /// ==========================================================================
  /// TẠO THÔNG BÁO THANH TOÁN
  /// ==========================================================================
  /// 
  /// **Khi nào dùng:**
  /// - Thanh toán thành công
  /// - Thanh toán thất bại
  /// - Hoàn tiền
  /// ==========================================================================
  static Future<void> createPaymentNotification({
    required String userId,
    required String title,
    required String message,
    String? bookingId,
  }) async {
    await createNotification(
      userId: userId,
      type: 'payment',                                    // Loại: payment
      title: title,
      message: message,
      data: bookingId != null ? {'bookingId': bookingId} : null,
    );
  }

  /// ==========================================================================
  /// FORMAT TIỀN TỆ VND
  /// ==========================================================================
  /// 
  /// **Chức năng:**
  /// Convert số tiền thành chuỗi có định dạng VND
  /// 
  /// **Input:** 8500000 (double)
  /// **Output:** "8,500,000₫" (string)
  /// 
  /// **Cách hoạt động:**
  /// 1. toStringAsFixed(0): Làm tròn thành số nguyên không có phần thập phân
  /// 2. replaceAllMapped: Thêm dấu phẩy phân cách hàng nghìn
  /// 3. RegEx r'(\d{1,3})(?=(\d{3})+(?!\d))': 
  ///    - Tìm nhóm 1-3 chữ số
  ///    - Phía sau là bội số của 3 chữ số
  ///    - Không phải cuối chuỗi
  /// 4. Thêm ký hiệu ₫ ở cuối
  /// 
  /// **Ví dụ:**
  /// - 1000 → "1,000₫"
  /// - 50000 → "50,000₫"
  /// - 8500000 → "8,500,000₫"
  /// ==========================================================================
  static String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),             // Pattern tìm vị trí thêm dấu phẩy
      (Match m) => '${m[1]},',                            // Thêm dấu phẩy sau mỗi nhóm
    )}₫';                                                 // Thêm ký hiệu tiền tệ
  }
}
