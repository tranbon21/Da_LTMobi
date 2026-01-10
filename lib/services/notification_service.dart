// File: lib/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Khởi tạo notifications
  Future<void> initialize() async {
    // Yêu cầu quyền thông báo
    await _requestPermissions();
    
    // Lấy FCM token
    await _getFCMToken();
    
    // Lắng nghe thông báo
    _setupInteractedMessage();
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Cấp quyền thông báo: ${settings.authorizationStatus}');
  }

  Future<void> _getFCMToken() async {
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
  }

  void _setupInteractedMessage() {
    // Khi app đang mở (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Thông báo khi app đang mở: ${message.notification?.title}');
      _showLocalNotificationSimple(message);
    });

    // Khi app ở background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Thông báo mở từ background: ${message.notification?.title}');
    });

    // Khi app bị đóng (terminated)
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('Thông báo mở từ terminated: ${message.notification?.title}');
      }
    });
  }

  // Hiển thị thông báo đơn giản không cần flutter_local_notifications
  void _showLocalNotificationSimple(RemoteMessage message) {
    print('📱 Thông báo mới:');
    print('   Tiêu đề: ${message.notification?.title}');
    print('   Nội dung: ${message.notification?.body}');
    
    // Có thể thêm SnackBar hoặc dialog thay vì local notification
    // ScaffoldMessenger.of(context).showSnackBar(...)
  }

  // Gửi thông báo đặt phòng thành công
  Future<void> sendBookingSuccessNotification({
    required String hotelName,
    required String bookingId,
  }) async {
    print('🎉 Đặt phòng thành công!');
    print('🏨 Khách sạn: $hotelName');
    print('📋 Mã đặt phòng: $bookingId');
    
    // Có thể thêm SnackBar ở đây nếu có context
  }

  // Đăng ký topic
  Future<void> subscribeToPromotionTopic() async {
    await _firebaseMessaging.subscribeToTopic('promotions');
    print('Đã đăng ký nhận thông báo khuyến mại');
  }

  // Hủy đăng ký topic
  Future<void> unsubscribeFromPromotionTopic() async {
    await _firebaseMessaging.unsubscribeFromTopic('promotions');
    print('Đã hủy đăng ký thông báo khuyến mại');
  }
}