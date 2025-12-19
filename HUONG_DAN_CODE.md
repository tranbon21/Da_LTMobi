# 📖 HƯỚNG DẪN CODE CHI TIẾT

> File này hướng dẫn bạn từng bước để hoàn thiện ứng dụng Travel Booking

---

## 🎯 MỤC TIÊU

Sau khi đọc file này, bạn sẽ biết:
1. ✅ Cách kết nối với Firebase/Backend
2. ✅ Cách implement authentication (đăng nhập/đăng ký)
3. ✅ Cách load và hiển thị dữ liệu
4. ✅ Cách xử lý booking
5. ✅ Cách debug và fix lỗi

---

## 📋 CHUẨN BỊ

### Bước 1: Hiểu cấu trúc hiện tại

```
✅ ĐÃ CÓ:
- Giao diện UI đầy đủ
- Models (User, Hotel, Tour, Booking)
- Widgets tái sử dụng
- Theme và constants

⏳ CHƯA CÓ:
- Logic xử lý dữ liệu
- Kết nối database
- Authentication thực tế
```

### Bước 2: Chọn công nghệ Backend

#### Option 1: Firebase (Khuyến nghị)
**Phù hợp nếu:**
- Bạn muốn làm nhanh
- Chưa có kinh nghiệm backend
- Cần authentication sẵn có

#### Option 2: REST API
**Phù hợp nếu:**
- Bạn đã có backend
- Muốn học sâu hơn
- Cần custom logic phức tạp

---

## 🔥 PHẦN 1: SETUP FIREBASE (Nếu chọn Firebase)

### Bước 1.1: Tạo Firebase Project

1. Vào https://console.firebase.google.com
2. Click "Add project"
3. Đặt tên project: `travel-booking-app`
4. Tắt Google Analytics (không cần thiết)
5. Click "Create project"

### Bước 1.2: Thêm Android App

1. Click biểu tượng Android
2. **Android package name**: Mở file `android/app/build.gradle`, tìm `applicationId`
   ```gradle
   // Ví dụ: com.example.da_booking_hotel
   ```
3. Nhập package name vào Firebase
4. Download file `google-services.json`
5. Copy vào `android/app/`

### Bước 1.3: Cấu hình Android

**File: `android/build.gradle`**
```gradle
buildscript {
    dependencies {
        // Thêm dòng này
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

**File: `android/app/build.gradle`**
```gradle
// Thêm ở cuối file
apply plugin: 'com.google.gms.google-services'
```

### Bước 1.4: Enable Firebase Services

1. **Authentication:**
   - Vào Firebase Console > Authentication
   - Click "Get started"
   - Enable "Email/Password"

2. **Firestore Database:**
   - Vào Firebase Console > Firestore Database
   - Click "Create database"
   - Chọn "Start in test mode"
   - Chọn location: `asia-southeast1` (Singapore)

### Bước 1.5: Uncomment Firebase trong code

**File: `lib/main.dart`**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // UNCOMMENT 2 dòng này:
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  
  runApp(const MyApp());
}
```

### Bước 1.6: Test Firebase Connection

Chạy app và kiểm tra console, không có lỗi Firebase = thành công!

---

## 🔐 PHẦN 2: IMPLEMENT AUTHENTICATION

### Bước 2.1: Hiểu flow Authentication

```
User nhập email/password
    ↓
Validate input
    ↓
Call AuthService.signIn()
    ↓
Firebase xác thực
    ↓
Lưu user session
    ↓
Navigate to HomeScreen
```

### Bước 2.2: Code Login Screen

**File: `lib/screens/login_screen.dart`**

Tìm hàm `_login()` (dòng ~30), thay TODO bằng:

```dart
Future<void> _login() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);

    try {
      // 1. Import AuthService ở đầu file
      // import '../services/auth_service.dart';
      
      // 2. Call Firebase authentication
      final authService = AuthService();
      final user = await authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // 3. Navigate to home nếu thành công
      if (user != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      // 4. Hiển thị lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng nhập thất bại: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
```

**Giải thích:**
- `_formKey.currentState!.validate()`: Kiểm tra validation
- `setState(() => _isLoading = true)`: Hiển thị loading
- `authService.signInWithEmailAndPassword()`: Gọi Firebase
- `Navigator.pushReplacement()`: Chuyển màn hình
- `try-catch-finally`: Xử lý lỗi

### Bước 2.3: Code Register Screen

**File: `lib/screens/register_screen.dart`**

Tương tự, tìm hàm `_register()` và thay TODO:

```dart
Future<void> _register() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final user = await authService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );

      if (user != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng ký thất bại: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
```

### Bước 2.4: Test Authentication

1. Chạy app
2. Thử đăng ký tài khoản mới
3. Kiểm tra Firebase Console > Authentication > Users
4. Thử đăng nhập với tài khoản vừa tạo

---

## 📊 PHẦN 3: LOAD DỮ LIỆU HOTELS/TOURS

### Bước 3.1: Thêm dữ liệu mẫu vào Firestore

1. Vào Firebase Console > Firestore Database
2. Click "Start collection"
3. Collection ID: `hotels`
4. Thêm document với data:

```json
{
  "name": "Khách sạn Metropole Hà Nội",
  "description": "Khách sạn 5 sao sang trọng tại trung tâm Hà Nội",
  "address": "15 Ngô Quyền, Hoàn Kiếm",
  "city": "Hà Nội",
  "country": "Việt Nam",
  "pricePerNight": 2500000,
  "rating": 4.8,
  "reviewCount": 1250,
  "imageUrls": [
    "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800"
  ],
  "amenities": ["WiFi miễn phí", "Bể bơi", "Gym", "Spa", "Nhà hàng"],
  "availableRooms": 15
}
```

5. Thêm thêm 2-3 hotels nữa để có dữ liệu test

### Bước 3.2: Code Hotels Screen

**File: `lib/screens/hotels_screen.dart`**

Tìm phần TODO (dòng ~50), thay bằng:

```dart
// 1. Import Firebase
import 'package:cloud_firestore/cloud_firestore.dart';

// 2. Trong build method, thay ListView.builder bằng:
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('hotels')
      .snapshots(),
  builder: (context, snapshot) {
    // Loading state
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error state
    if (snapshot.hasError) {
      return Center(
        child: Text('Lỗi: ${snapshot.error}'),
      );
    }

    // No data
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(
        child: Text('Không có khách sạn nào'),
      );
    }

    // Convert documents to HotelModel
    final hotels = snapshot.data!.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Thêm ID từ Firestore
      return HotelModel.fromMap(data);
    }).toList();

    // Filter by search
    final filteredHotels = _searchQuery.isEmpty
        ? hotels
        : hotels.where((hotel) {
            return hotel.city
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
          }).toList();

    // Display list
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      itemCount: filteredHotels.length,
      itemBuilder: (context, index) {
        return HotelCard(
          hotel: filteredHotels[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HotelDetailScreen(
                  hotel: filteredHotels[index],
                ),
              ),
            );
          },
        );
      },
    );
  },
)
```

**Giải thích:**
- `StreamBuilder`: Tự động update khi data thay đổi
- `FirebaseFirestore.instance.collection('hotels')`: Lấy collection
- `.snapshots()`: Lắng nghe realtime changes
- `snapshot.data!.docs`: Danh sách documents
- `HotelModel.fromMap()`: Convert Firestore data sang model

### Bước 3.3: Tương tự cho Tours

Làm tương tự cho `tours_screen.dart` với collection `tours`

---

## 🎫 PHẦN 4: IMPLEMENT BOOKING

### Bước 4.1: Code Booking Logic

**File: `lib/screens/hotel_detail_screen.dart`**

Tìm hàm `_bookNow()`, thay TODO:

```dart
Future<void> _bookNow() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  if (_checkInDate == null || _checkOutDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vui lòng chọn ngày nhận/trả phòng')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    // 1. Lấy user ID hiện tại
    final authService = AuthService();
    final currentUser = authService.currentUser;
    
    if (currentUser == null) {
      throw Exception('Vui lòng đăng nhập');
    }

    // 2. Tính tổng tiền
    final nights = _checkOutDate!.difference(_checkInDate!).inDays;
    final totalPrice = widget.hotel.pricePerNight * nights;

    // 3. Tạo booking object
    final booking = BookingModel(
      id: '', // Firestore sẽ tự generate
      userId: currentUser.uid,
      type: 'hotel',
      itemId: widget.hotel.id,
      itemName: widget.hotel.name,
      bookingDate: DateTime.now(),
      checkInDate: _checkInDate!,
      checkOutDate: _checkOutDate!,
      numberOfGuests: _numberOfGuests,
      totalPrice: totalPrice,
      status: 'pending',
      specialRequests: _specialRequestsController.text.trim().isEmpty
          ? null
          : _specialRequestsController.text.trim(),
    );

    // 4. Lưu vào Firestore
    final firestoreService = FirestoreService();
    await firestoreService.createBooking(booking);

    // 5. Thông báo thành công
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đặt phòng thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // 6. Quay lại màn hình trước
      Navigator.pop(context);
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
```

### Bước 4.2: Hiển thị Booking History

**File: `lib/screens/bookings_screen.dart`**

Thay TODO bằng:

```dart
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('bookings')
      .where('userId', isEqualTo: AuthService().currentUser?.uid)
      .orderBy('bookingDate', descending: true)
      .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(
        child: Text('Chưa có đặt phòng nào'),
      );
    }

    final bookings = snapshot.data!.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return BookingModel.fromMap(data);
    }).toList();

    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return BookingCard(booking: booking);
      },
    );
  },
)
```

---

## 🐛 PHẦN 5: DEBUG VÀ FIX LỖI

### Lỗi thường gặp:

#### 1. "No Firebase App has been created"
**Nguyên nhân:** Chưa initialize Firebase

**Cách fix:**
```dart
// Trong main.dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform
);
```

#### 2. "setState() called after dispose()"
**Nguyên nhân:** Widget đã bị dispose nhưng vẫn gọi setState

**Cách fix:**
```dart
if (mounted) {
  setState(() { ... });
}
```

#### 3. "RenderFlex overflowed"
**Nguyên nhân:** Nội dung quá dài, không fit trong màn hình

**Cách fix:**
```dart
SingleChildScrollView(
  child: Column(...)
)
```

#### 4. "The argument type 'X' can't be assigned to 'Y'"
**Nguyên nhân:** Sai kiểu dữ liệu

**Cách fix:** Kiểm tra type, dùng `as` để cast nếu cần

---

## 💡 TIPS QUAN TRỌNG

### 1. Debug bằng print()
```dart
print('Debug - User ID: ${currentUser.uid}');
print('Debug - Hotels count: ${hotels.length}');
```

### 2. Sử dụng try-catch
```dart
try {
  // Code có thể lỗi
} catch (e) {
  print('Error: $e');
  // Xử lý lỗi
}
```

### 3. Check null safety
```dart
// Sai
final name = user.name; // Có thể null

// Đúng
final name = user.name ?? 'Unknown';
```

### 4. Format code thường xuyên
```bash
flutter format .
```

### 5. Commit code thường xuyên
```bash
git add .
git commit -m "Add login functionality"
```

---

## 📝 CHECKLIST HOÀN THÀNH

### Week 1: Setup
- [ ] Setup Firebase project
- [ ] Add google-services.json
- [ ] Test Firebase connection
- [ ] Add sample data to Firestore

### Week 2: Authentication
- [ ] Implement login
- [ ] Implement register
- [ ] Test với nhiều accounts
- [ ] Add error handling

### Week 3: Data
- [ ] Load hotels from Firestore
- [ ] Load tours from Firestore
- [ ] Implement search
- [ ] Test với nhiều data

### Week 4: Booking
- [ ] Implement hotel booking
- [ ] Implement tour booking
- [ ] Show booking history
- [ ] Test booking flow

### Week 5: Polish
- [ ] Fix all bugs
- [ ] Add loading states everywhere
- [ ] Test toàn bộ app
- [ ] Add comments
- [ ] Prepare demo

---

## 🎓 HỌC THÊM

### Tài liệu nên đọc:
1. **Flutter Docs**: https://docs.flutter.dev
2. **Firebase Flutter**: https://firebase.google.com/docs/flutter/setup
3. **Dart Language**: https://dart.dev/guides

### Video tutorials:
1. Search YouTube: "Flutter Firebase Tutorial"
2. Search YouTube: "Flutter CRUD Firestore"

---

## 📞 KHI CẦN TRỢ GIÚP

1. **Đọc error message kỹ** - Flutter error rất chi tiết
2. **Google error** - Copy error message và search
3. **Stack Overflow** - Hỏi nếu không tìm được
4. **Hỏi bạn/giảng viên** - Đừng ngại hỏi!

---

**Chúc bạn code thành công! 💪🚀**

> Nhớ: Code từng bước nhỏ, test thường xuyên, đừng code quá nhiều rồi mới test!
