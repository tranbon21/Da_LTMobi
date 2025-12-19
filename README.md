# Travel Booking App - Ứng dụng Đặt Phòng và Tour Du Lịch

Đây là một ứng dụng Flutter cho phép người dùng đặt phòng khách sạn và mua vé tour du lịch.

## 📌 Trạng thái hiện tại

### ✅ Đã hoàn thành
- **Cấu trúc project** - Đã tạo đầy đủ folders và files
- **UI/UX** - Đã có giao diện đầy đủ cho tất cả màn hình
- **Theme & Constants** - Đã setup màu sắc, fonts, và constants
- **Models** - Đã có data models cho User, Hotel, Tour, Booking
- **Widgets** - Đã có các custom widgets tái sử dụng
- **Navigation** - Bottom navigation đã hoạt động

### ⏳ Chưa hoàn thành (Bạn cần code tiếp)
- **Authentication Logic** - Đăng nhập/đăng ký (chỉ có UI)
- **Database Integration** - Kết nối với backend/Firebase
- **API Calls** - Lấy dữ liệu thật từ server
- **Booking Logic** - Xử lý đặt phòng/tour
- **Payment** - Thanh toán
- **State Management** - Quản lý state với Provider/Bloc

---

## 🏗️ Cấu trúc Project

```
lib/
├── models/              # Data models (✅ Đã có)
│   ├── user_model.dart
│   ├── hotel_model.dart
│   ├── tour_model.dart
│   └── booking_model.dart
│
├── services/            # Business logic & API (⏳ Cần code)
│   ├── auth_service.dart      # TODO: Implement authentication
│   └── firestore_service.dart # TODO: Implement database
│
├── screens/             # UI Screens (✅ UI đã xong, ⏳ Logic chưa)
│   ├── login_screen.dart       # TODO: Add login logic
│   ├── register_screen.dart    # TODO: Add register logic
│   ├── home_screen.dart        # ✅ Hoàn thành
│   ├── hotels_screen.dart      # TODO: Load data from API
│   ├── hotel_detail_screen.dart # TODO: Add booking logic
│   ├── tours_screen.dart       # TODO: Load data from API
│   ├── tour_detail_screen.dart # TODO: Add booking logic
│   ├── bookings_screen.dart    # TODO: Load user bookings
│   └── profile_screen.dart     # TODO: Load user data
│
├── widgets/             # Reusable widgets (✅ Đã có)
│   ├── hotel_card.dart
│   ├── tour_card.dart
│   ├── custom_text_field.dart
│   └── custom_button.dart
│
├── utils/               # Constants & Theme (✅ Đã có)
│   ├── constants.dart
│   └── theme.dart
│
├── firebase_options.dart (⏳ Cần config nếu dùng Firebase)
└── main.dart (✅ Đã setup)
```

---

## 🎯 Hướng dẫn Code tiếp theo

### Bước 1: Chọn Backend (Quan trọng!)

Bạn cần quyết định sử dụng backend nào:

#### Option A: Firebase (Khuyến nghị cho sinh viên)
**Ưu điểm:**
- ✅ Miễn phí (có quota)
- ✅ Dễ setup
- ✅ Có authentication sẵn
- ✅ Realtime database

**Cách setup:**
```bash
# 1. Uncomment Firebase trong main.dart (dòng 8-9)
# 2. Chạy lệnh:
flutterfire configure

# 3. Chọn project Firebase của bạn
# 4. Chọn platforms (Android/iOS)
```

#### Option B: REST API (Node.js, Laravel, Django...)
**Ưu điểm:**
- ✅ Kiểm soát hoàn toàn
- ✅ Học được nhiều hơn
- ✅ Phù hợp cho production

**Cần làm:**
- Tạo backend API riêng
- Sử dụng package `http` hoặc `dio` để call API

---

### Bước 2: Implement Authentication

#### Nếu dùng Firebase:

**File: `lib/services/auth_service.dart`**
```dart
// Đã có sẵn code, chỉ cần uncomment và test
```

**File: `lib/screens/login_screen.dart`**
```dart
// Tìm dòng: // TODO: Implement login logic here
// Thay bằng:
try {
  final user = await AuthService().signInWithEmailAndPassword(
    email: _emailController.text.trim(),
    password: _passwordController.text,
  );
  
  if (user != null && mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Lỗi: ${e.toString()}')),
  );
}
```

#### Nếu dùng REST API:

**Tạo file: `lib/services/api_service.dart`**
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://your-api.com/api';
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Login failed');
    }
  }
}
```

---

### Bước 3: Load dữ liệu Hotels/Tours

**File: `lib/screens/hotels_screen.dart`**

Tìm dòng:
```dart
// TODO: Replace with actual data from Firestore/API
```

Thay bằng:

**Nếu dùng Firebase:**
```dart
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance.collection('hotels').snapshots(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final hotels = snapshot.data!.docs.map((doc) {
        return HotelModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
      
      return ListView.builder(
        itemCount: hotels.length,
        itemBuilder: (context, index) {
          return HotelCard(hotel: hotels[index]);
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

**Nếu dùng REST API:**
```dart
FutureBuilder<List<HotelModel>>(
  future: ApiService().getHotels(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return ListView.builder(
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          return HotelCard(hotel: snapshot.data![index]);
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

---

### Bước 4: Implement Booking

**File: `lib/screens/hotel_detail_screen.dart`**

Tìm hàm `_bookNow()` và thay TODO bằng:

```dart
Future<void> _bookNow() async {
  if (!_formKey.currentState!.validate()) return;
  
  setState(() => _isLoading = true);
  
  try {
    // Tạo booking object
    final booking = BookingModel(
      id: '', // Firestore sẽ tự generate
      userId: 'current_user_id', // Lấy từ auth
      type: 'hotel',
      itemId: widget.hotel.id,
      itemName: widget.hotel.name,
      bookingDate: DateTime.now(),
      checkInDate: _checkInDate!,
      checkOutDate: _checkOutDate!,
      numberOfGuests: _numberOfGuests,
      totalPrice: _calculateTotalPrice(),
      status: 'pending',
    );
    
    // Lưu vào database
    await FirestoreService().createBooking(booking);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đặt phòng thành công!')),
      );
      Navigator.pop(context);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lỗi: ${e.toString()}')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
```

---

## 📦 Dependencies cần thiết

### Đã có trong pubspec.yaml:
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase (nếu dùng)
  firebase_core: ^4.3.0
  cloud_firestore: ^6.1.1
  firebase_auth: ^6.1.3
  
  # UI
  google_fonts: ^6.2.1
  intl: ^0.19.0
  flutter_rating_bar: ^4.0.1
```

### Có thể cần thêm:
```yaml
  # Nếu dùng REST API
  http: ^1.1.0
  dio: ^5.4.0
  
  # State Management
  provider: ^6.1.2
  # hoặc
  flutter_bloc: ^8.1.3
  
  # Local Storage
  shared_preferences: ^2.2.2
  
  # Image
  cached_network_image: ^3.3.1
  image_picker: ^1.0.7
```

---

## 🔥 Firebase Setup (Nếu chọn Firebase)

### 1. Tạo Firebase Project
1. Vào https://console.firebase.google.com
2. Tạo project mới
3. Thêm Android/iOS app
4. Download `google-services.json` (Android) và `GoogleService-Info.plist` (iOS)

### 2. Enable Authentication
1. Vào Firebase Console > Authentication
2. Enable Email/Password

### 3. Tạo Firestore Database
1. Vào Firebase Console > Firestore Database
2. Create database (Start in test mode)
3. Tạo collections: `users`, `hotels`, `tours`, `bookings`

### 4. Thêm dữ liệu mẫu
Vào Firestore và thêm document mẫu:

**Collection: hotels**
```json
{
  "name": "Khách sạn Hà Nội",
  "description": "Khách sạn 5 sao sang trọng",
  "city": "Hà Nội",
  "pricePerNight": 1500000,
  "rating": 4.5,
  "imageUrls": ["https://example.com/image.jpg"],
  "amenities": ["WiFi", "Bể bơi", "Gym"]
}
```

---

## 🛠️ Các lệnh thường dùng

```bash
# Chạy app
flutter run

# Clean build
flutter clean
flutter pub get

# Build APK
flutter build apk --release

# Check dependencies
flutter pub outdated

# Format code
flutter format .

# Analyze code
flutter analyze
```

---

## 📱 Testing

### Test trên Emulator
```bash
# List devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

### Test trên thiết bị thật
1. Bật USB Debugging trên điện thoại
2. Kết nối USB
3. Chạy `flutter run`

---

## 🎨 Tùy chỉnh Theme

**File: `lib/utils/theme.dart`**

Thay đổi màu sắc:
```dart
class AppColors {
  static const Color primary = Color(0xFF2196F3); // Đổi màu chính
  static const Color accent = Color(0xFFFF9800);  // Đổi màu phụ
  // ...
}
```

---

## 📝 Checklist Code tiếp theo

### Week 1: Backend Setup
- [ ] Quyết định dùng Firebase hay REST API
- [ ] Setup Firebase/Backend
- [ ] Test connection

### Week 2: Authentication
- [ ] Implement login logic
- [ ] Implement register logic
- [ ] Test authentication flow
- [ ] Add error handling

### Week 3: Data Loading
- [ ] Load hotels from database
- [ ] Load tours from database
- [ ] Add search functionality
- [ ] Add filters

### Week 4: Booking
- [ ] Implement hotel booking
- [ ] Implement tour booking
- [ ] Show booking history
- [ ] Add booking status

### Week 5: Polish
- [ ] Add loading states
- [ ] Add error handling
- [ ] Test all features
- [ ] Fix bugs
- [ ] Add comments

---

## 💡 Tips quan trọng

1. **Luôn test từng bước nhỏ** - Đừng code quá nhiều rồi mới test
2. **Đọc error messages** - Flutter error rất chi tiết
3. **Sử dụng print() để debug** - `print('Debug: $variable')`
4. **Commit code thường xuyên** - Dùng Git để backup
5. **Tham khảo documentation** - Flutter.dev có docs rất tốt

---

## 🆘 Khi gặp lỗi

### Lỗi thường gặp:

**1. "No Firebase App '[DEFAULT]' has been created"**
```dart
// Uncomment trong main.dart:
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

**2. "setState() called after dispose()"**
```dart
// Luôn check mounted:
if (mounted) {
  setState(() { ... });
}
```

**3. "RenderFlex overflowed"**
```dart
// Wrap trong SingleChildScrollView:
SingleChildScrollView(
  child: Column(...)
)
```

---

## 📚 Tài liệu tham khảo

- **Flutter Docs**: https://docs.flutter.dev
- **Firebase Docs**: https://firebase.google.com/docs/flutter
- **Dart Docs**: https://dart.dev/guides
- **Pub.dev**: https://pub.dev (tìm packages)

---

## 👨‍💻 Author

Sinh viên - Đồ án môn học Lập trình ứng dụng Mobile

---

## 📞 Hỗ trợ

Nếu gặp vấn đề, hãy:
1. Đọc error message kỹ
2. Google error đó
3. Hỏi trên Stack Overflow
4. Hỏi giảng viên/bạn bè

---

**Chúc bạn code thành công! 🚀💪**

> **Lưu ý**: File này sẽ được cập nhật khi bạn code thêm các tính năng mới.
