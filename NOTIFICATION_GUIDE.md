# 🔔 HƯỚNG DẪN SỬ DỤNG NOTIFICATION SERVICE

## 📋 MỤC LỤC
1. [Cài đặt](#cài-đặt)
2. [Khởi tạo](#khởi-tạo)
3. [Sử dụng cơ bản](#sử-dụng-cơ-bản)
4. [Test Notification](#test-notification)
5. [Gửi Notification từ Server](#gửi-notification-từ-server)

---

## 1. CÀI ĐẶT

### Bước 1: Thêm dependencies vào `pubspec.yaml`

```yaml
dependencies:
  firebase_messaging: ^14.7.9
  flutter_local_notifications: ^16.3.0
```

### Bước 2: Chạy lệnh install

```bash
flutter pub get
```

### Bước 3: Cấu hình Android

Mở `android/app/src/main/AndroidManifest.xml` và thêm:

```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <application>
        <!-- Thêm vào trong tag <application> -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="booking_channel" />
    </application>
</manifest>
```

---

## 2. KHỞI TẠO

### Trong `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'services/notification_service.dart';

void main() async {
  // Khởi tạo Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Firebase
  await Firebase.initializeApp();
  
  // 🔔 KHỞI TẠO NOTIFICATION SERVICE
  await NotificationService().initialize();
  
  // Chạy app
  runApp(const MyApp());
}
```

---

## 3. SỬ DỤNG CƠ BẢN

### Subscribe/Unsubscribe Topics

```dart
// Subscribe để nhận thông báo khuyến mãi
await NotificationService().subscribeToPromotionTopic();

// Unsubscribe khi không muốn nhận nữa
await NotificationService().unsubscribeFromPromotionTopic();
```

### Gửi notification khi đặt tour thành công

```dart
// Trong tour_detail_screen.dart sau khi đặt tour thành công
await NotificationService().sendTourBookingSuccess(
  tourName: widget.tour.name,
  bookingId: booking.id,
);
```

### Gửi notification khi đặt phòng thành công

```dart
// Trong hotel_detail_screen.dart sau khi đặt phòng thành công
await NotificationService().sendHotelBookingSuccess(
  hotelName: hotel.name,
  bookingId: booking.id,
);
```

### Xóa token khi logout

```dart
// Trong logout function
await NotificationService().unsubscribe();
```

---

## 4. TEST NOTIFICATION

### Thêm nút test vào màn hình bất kỳ:

```dart
// Trong screens/home_screen.dart hoặc profile_screen.dart
FloatingActionButton(
  onPressed: () async {
    await NotificationService().sendTestNotification();
  },
  child: const Icon(Icons.notifications),
  tooltip: 'Test Notification',
)
```

---

## 5. GỬI NOTIFICATION TỪ SERVER

### Option 1: Sử dụng Firebase Console

1. Vào [Firebase Console](https://console.firebase.google.com)
2. Chọn project của bạn
3. Vào **Cloud Messaging**
4. Click **Send your first message**
5. Điền:
   - Title: `Khuyến mãi hot!`
   - Text: `Giảm 50% tất cả tour ngày mai`
   - Target: All users hoặc Topic `promotions`

### Option 2: Gửi từ Backend (Node.js example)

```javascript
const admin = require('firebase-admin');

// Gửi đến topic
await admin.messaging().send({
  topic: 'promotions',
  notification: {
    title: '🎉 Khuyến mãi đặc biệt!',
    body: 'Giảm 50% tất cả tour trong ngày hôm nay!'
  },
  data: {
    type: 'promotion',
    id: 'PROMO123'
  }
});

// Gửi đến device cụ thể (dùng FCM token)
await admin.messaging().send({
  token: 'USER_FCM_TOKEN_HERE',
  notification: {
    title: '✅ Đặt tour thành công!',
    body: 'Tour Hạ Long - Sapa đã được xác nhận'
  },
  data: {
    type: 'tour_booking',
    id: 'BOOKING123'
  }
});
```

### Option 3: Gửi bằng HTTP Request (Postman/cURL)

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "USER_FCM_TOKEN",
    "notification": {
      "title": "🎉 Khuyến mãi!",
      "body": "Giảm 50% các tour hot"
    },
    "data": {
      "type": "promotion",
      "id": "123"
    }
  }'
```

---

## 📝 LƯU Ý QUAN TRỌNG

### 1. Notification khi app đang mở (Foreground)
- ✅ Sẽ hiển thị notification bằng `flutter_local_notifications`
- ✅ User thấy popup notification ngay cả khi đang dùng app

### 2. Notification khi app ở background
- ✅ Tự động hiển thị bởi hệ thống
- ✅ Tap vào sẽ mở app và xử lý bằng `onMessageOpenedApp`

### 3. Notification khi app đã tắt (Terminated)
- ✅ Tap vào sẽ mở app
- ✅ Xử lý bằng `getInitialMessage()`

### 4. Data Payload
- Luôn gửi kèm `data` để biết loại notification và navigate đúng màn hình
- Format: `{"type": "booking", "id": "123"}`

### 5. Topics
- `promotions`: Khuyến mãi chung
- `new_tours`: Tour mới
- Tạo thêm topics khác tùy nhu cầu

---

## 🐛 TROUBLESHOOTING

### Không nhận được notification?

1. **Kiểm tra quyền:**
   ```dart
   NotificationSettings settings = await FirebaseMessaging.instance.getNotificationSettings();
   print('Permission: ${settings.authorizationStatus}');
   ```

2. **Kiểm tra FCM token:**
   ```dart
   String? token = await FirebaseMessaging.instance.getToken();
   print('Token: $token');
   ```

3. **Kiểm tra Firebase Console:**
   - Project Settings → Cloud Messaging
   - Đảm bảo đã enable Cloud Messaging API

4. **Test bằng Firebase Console:**
   - Cloud Messaging → Send test message
   - Paste FCM token

### Notification không hiển thị khi app mở?

- Đảm bảo đã gọi `_showLocalNotification()` trong `onMessage` handler
- Kiểm tra channel ID khớp với AndroidManifest.xml

---

## 🎯 KẾ HOẠCH TIẾP THEO

- [ ] Lưu FCM token vào Firestore
- [ ] Navigate đến màn hình chi tiết khi tap notification
- [ ] Thêm notification sound custom
- [ ] Badge counter cho số thông báo chưa đọc
- [ ] Notification history screen
- [ ] Rich notifications (images, buttons)

---

Happy coding! 🚀
