// ==================== NOTIFICATION SERVICE ====================
// Service quản lý Push Notification cho app
// File: lib/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service quản lý Push Notification (Thông báo đẩy)
/// 
/// **Chức năng:**
/// - Xin quyền thông báo từ user
/// - Nhận notification từ Firebase Cloud Messaging
/// - Hiển thị notification khi app đang mở hoặc background
/// - Xử lý khi user tap vào notification
/// 
/// **Cách sử dụng:**
/// ```dart
/// // 1. Khởi tạo trong main.dart
/// await NotificationService().initialize();
/// 
/// // 2. Gửi test notification
/// await NotificationService().sendTestNotification();
/// 
/// // 3. Subscribe/Unsubscribe topics
/// await NotificationService().subscribeToPromotionTopic();
/// ```
class NotificationService {
  // ==================== SINGLETON ====================
  // Đảm bảo chỉ có 1 instance duy nhất trong app
  
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // ==================== INSTANCES ====================
  
  /// Firebase Cloud Messaging - Nhận notification từ server
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  
  /// Flutter Local Notifications - Hiển thị notification trên device
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  /// Lưu FCM token (dùng để gửi notification đến device này)
  String? _fcmToken;

  // ==================== 1. KHỞI TẠO ====================
  
  /// **Khởi tạo Notification Service**
  /// 
  /// Gọi hàm này trong main.dart khi app khởi động
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await Firebase.initializeApp();
  ///   await NotificationService().initialize(); // <- Gọi ở đây
  ///   runApp(MyApp());
  /// }
  /// ```
  Future<void> initialize() async {
    try {
      print('\n========================================');
      print('🔔 KHỞI TẠO NOTIFICATION SERVICE');
      print('========================================\n');
      
      // Bước 1: Xin quyền thông báo
      await _requestPermission();
      
      // Bước 2: Setup local notifications
      await _setupLocalNotifications();
      
      // Bước 3: Lấy FCM token
      await _getFCMToken();
      
      // Bước 4: Setup handlers
      _setupMessageHandlers();
      
      print('\n✅ Notification Service đã sẵn sàng!\n');
    } catch (e) {
      print('\n❌ LỖI khởi tạo Notification Service: $e\n');
    }
  }

  // ==================== 2. XIN QUYỀN ====================
  
  /// **Xin quyền hiển thị thông báo**
  /// 
  /// User sẽ thấy popup hỏi "Cho phép app gửi thông báo?"
  Future<void> _requestPermission() async {
    print('📱 Đang xin quyền thông báo...');
    
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,      // Hiển thị popup thông báo
      badge: true,      // Hiển thị số badge trên app icon
      sound: true,      // Phát âm thanh
      provisional: false,
    );

    // Kiểm tra kết quả
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('   ✅ User ĐÃ CHO PHÉP thông báo');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('   ⚠️ User cho phép TẠM THỜI');
    } else {
      print('   ❌ User TỪ CHỐI thông báo');
    }
  }

  // ==================== 3. SETUP LOCAL NOTIFICATIONS ====================
  
  /// **Setup Flutter Local Notifications**
  /// 
  /// Để hiển thị notification khi app đang MỞ (foreground)
  Future<void> _setupLocalNotifications() async {
    print('⚙️ Đang setup Local Notifications...');
    
    // Cấu hình cho ANDROID
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Icon của app
    
    // Cấu hình cho iOS
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // Gộp cấu hình Android + iOS
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    // Khởi tạo với callback khi user tap notification
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('   👆 User đã tap vào notification');
        print('   📦 Payload: ${response.payload}');
        // TODO: Navigate đến màn hình tương ứng
      },
    );
    
    print('   ✅ Đã setup Local Notifications');
  }

  // ==================== 4. LẤY FCM TOKEN ====================
  
  /// **Lấy FCM Token của device**
  /// 
  /// FCM Token = Địa chỉ duy nhất của device này
  /// Dùng token này để gửi notification đến device cụ thể
  Future<void> _getFCMToken() async {
    print('🔑 Đang lấy FCM Token...');
    
    try {
      _fcmToken = await _fcm.getToken();
      
      if (_fcmToken != null) {
        // In ra 30 ký tự đầu
        print('   ✅ Token: ${_fcmToken!.substring(0, 30)}...');
        
        // TODO: Lưu token vào database
        // await FirestoreService().saveUserFCMToken(userId, _fcmToken!);
      }
    } catch (e) {
      print('   ❌ Lỗi lấy FCM Token: $e');
    }
  }

  // ==================== 5. XỬ LÝ MESSAGES ====================
  
  /// **Setup các handlers để xử lý notification**
  void _setupMessageHandlers() {
    print('📬 Đang setup Message Handlers...');
    
    // HANDLER 1: App đang MỞ (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('\n📨 Nhận notification (App đang MỞ):');
      print('   📌 Title: ${message.notification?.title}');
      print('   💬 Body: ${message.notification?.body}');
      
      // Hiển thị notification
      if (message.notification != null) {
        _showLocalNotification(
          title: message.notification!.title ?? 'Thông báo',
          body: message.notification!.body ?? '',
          payload: message.data.toString(),
        );
      }
    });
    
    // HANDLER 2: User TAP vào notification (App ở background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('\n👆 User tap notification (App ở BACKGROUND):');
      print('   📦 Data: ${message.data}');
      _handleNotificationTap(message.data);
    });
    
    // HANDLER 3: App được mở từ notification (App đã TẮT)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print('\n🚀 App mở từ notification (App đã TẮT):');
        print('   📦 Data: ${message.data}');
        _handleNotificationTap(message.data);
      }
    });
    
    print('   ✅ Đã setup Message Handlers');
  }

  // ==================== 6. HIỂN THỊ NOTIFICATION ====================
  
  /// **Hiển thị Local Notification**
  /// 
  /// Dùng khi app đang mở và nhận được notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Cấu hình cho ANDROID
    const AndroidNotificationDetails androidDetails = 
        AndroidNotificationDetails(
      'booking_channel',           // Channel ID (unique)
      'Booking Notifications',     // Channel Name
      channelDescription: 'Thông báo về booking và tour',
      importance: Importance.high,  // Độ ưu tiên CAO
      priority: Priority.high,
      showWhen: true,               // Hiển thị thời gian
      enableVibration: true,        // Rung
      playSound: true,              // Phát âm thanh
    );
    
    // Cấu hình cho iOS
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    // Gộp cấu hình
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // HIỂN THỊ notification
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000, // ID unique
      title,
      body,
      details,
      payload: payload,
    );
    
    print('   ✅ Đã hiển thị notification: $title');
  }

  // ==================== 7. XỬ LÝ TAP NOTIFICATION ====================
  
  /// **Xử lý khi user tap vào notification**
  /// 
  /// Navigate đến màn hình tương ứng dựa vào data
  void _handleNotificationTap(Map<String, dynamic> data) {
    // Xử lý data từ notification
    String? type = data['type'];
    String? id = data['id'];
    
    print('   🎯 Loại: $type');
    print('   🆔 ID: $id');
    
    // TODO: Navigate based on type
    // Example:
    // switch (type) {
    //   case 'booking':
    //     Navigator.push(BookingDetailScreen(id: id));
    //     break;
    //   case 'tour':
    //     Navigator.push(TourDetailScreen(id: id));
    //     break;
    // }
  }

  // ==================== 8. TEST NOTIFICATION ====================
  
  /// **Gửi test notification**
  /// 
  /// Để test xem notification có hoạt động không
  Future<void> sendTestNotification() async {
    await _showLocalNotification(
      title: '🎉 Test Notification',
      body: 'Đây là notification test! Thời gian: ${DateTime.now().hour}:${DateTime.now().minute}',
      payload: '{"type": "test", "id": "123"}',
    );
    
    print('🧪 Đã gửi test notification');
  }

  // ==================== 9. TOPICS ====================
  
  /// **Subscribe topic "promotions"**
  /// 
  /// Tất cả user subscribe topic này sẽ nhận được notification
  /// khi admin gửi đến topic "promotions"
  Future<void> subscribeToPromotionTopic() async {
    await _fcm.subscribeToTopic('promotions');
    print('✅ Đã subscribe topic "promotions"');
  }

  /// **Unsubscribe topic "promotions"**
  Future<void> unsubscribeFromPromotionTopic() async {
    await _fcm.unsubscribeFromTopic('promotions');
    print('❌ Đã unsubscribe topic "promotions"');
  }

  // ==================== 10. GỬI NOTIFICATION CỤ THỂ ====================
  
  /// **Gửi notification đặt tour thành công**
  /// 
  /// Hiển thị thông báo local khi user đặt tour thành công
  Future<void> sendTourBookingSuccess({
    required String tourName,
    required String bookingId,
  }) async {
    await _showLocalNotification(
      title: '🎉 Đặt tour thành công!',
      body: 'Tour: $tourName\nMã booking: $bookingId',
      payload: '{"type": "tour_booking", "id": "$bookingId"}',
    );
  }

  /// **Gửi notification đặt phòng thành công**
  Future<void> sendHotelBookingSuccess({
    required String hotelName,
    required String bookingId,
  }) async {
    await _showLocalNotification(
      title: '🎉 Đặt phòng thành công!',
      body: 'Khách sạn: $hotelName\nMã booking: $bookingId',
      payload: '{"type": "hotel_booking", "id": "$bookingId"}',
    );
  }

  // ==================== 11. CLEAN UP ====================
  
  /// **Xóa FCM token**
  /// 
  /// Gọi khi user logout
  Future<void> unsubscribe() async {
    await _fcm.deleteToken();
    _fcmToken = null;
    print('✅ Đã xóa FCM token');
  }
}