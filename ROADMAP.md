# 🗺️ ROADMAP PHÁT TRIỂN ỨNG DỤNG

> **Trạng thái hiện tại**: Đã có giao diện đầy đủ, chưa có logic xử lý dữ liệu

---

## 📊 TỔNG QUAN TIẾN TRÌNH

### ✅ Đã hoàn thành (Week 0)
- [x] Cấu trúc project
- [x] Giao diện UI đầy đủ
- [x] Theme & styling
- [x] Models (User, Hotel, Tour, Booking)
- [x] Custom widgets
- [x] Navigation
- [x] Tài liệu hướng dẫn

### 🎯 Cần làm tiếp
- [ ] Backend setup
- [ ] Authentication
- [ ] Load dữ liệu
- [ ] Booking logic
- [ ] Testing & polish

---

## 🚀 LỘ TRÌNH CHI TIẾT

## TUẦN 1: SETUP BACKEND & AUTHENTICATION

### Ngày 1-2: Quyết định & Setup Backend

#### Option A: Dùng Firebase (Khuyến nghị)

**Bước 1: Tạo Firebase Project**
```bash
# 1. Vào https://console.firebase.google.com
# 2. Click "Add project"
# 3. Tên project: travel-booking-app
# 4. Tắt Google Analytics
# 5. Click "Create project"
```

**Bước 2: Add Android App**
```bash
# 1. Click biểu tượng Android
# 2. Lấy package name từ: android/app/build.gradle
#    Tìm dòng: applicationId "com.example.da_booking_hotel"
# 3. Nhập package name vào Firebase
# 4. Download google-services.json
# 5. Copy vào: android/app/
```

**Bước 3: Cấu hình Android**

File: `android/build.gradle`
```gradle
buildscript {
    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        classpath 'com.google.gms:google-services:4.4.0'  // Thêm dòng này
    }
}
```

File: `android/app/build.gradle`
```gradle
// Thêm ở cuối file
apply plugin: 'com.google.gms.google-services'
```

**Bước 4: Enable Firebase Services**

1. **Authentication:**
   - Firebase Console > Authentication
   - Click "Get started"
   - Enable "Email/Password"

2. **Firestore Database:**
   - Firebase Console > Firestore Database
   - Click "Create database"
   - Chọn "Start in test mode"
   - Location: asia-southeast1 (Singapore)

**Bước 5: Uncomment Firebase trong code**

File: `lib/main.dart`
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // UNCOMMENT 2 dòng này:
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  
  runApp(const MyApp());
}
```

**Bước 6: Test Firebase Connection**
```bash
flutter run
# Nếu không có lỗi Firebase = thành công!
```

#### Option B: Dùng REST API

**Bước 1: Tạo API Service**

File: `lib/services/api_service.dart`
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'YOUR_API_URL_HERE';
  
  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Login failed');
    }
  }
  
  // Get hotels
  Future<List<dynamic>> getHotels() async {
    final response = await http.get(
      Uri.parse('$baseUrl/hotels'),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load hotels');
    }
  }
  
  // TODO: Add more methods
}
```

**Bước 2: Add http package**

File: `pubspec.yaml`
```yaml
dependencies:
  http: ^1.1.0
```

```bash
flutter pub get
```

---

### Ngày 3-4: Implement Authentication

#### Nếu dùng Firebase:

**File: `lib/screens/login_screen.dart`**

Tìm hàm `_login()` (dòng ~30), thay TODO:

```dart
Future<void> _login() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);

    try {
      // 1. Import AuthService ở đầu file
      // import '../services/auth_service.dart';
      
      final authService = AuthService();
      final user = await authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
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

**File: `lib/screens/register_screen.dart`**

Tương tự cho hàm `_register()`:

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

**File: `lib/main.dart`** - Enable authentication check

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
```

**Testing:**
```bash
# 1. Chạy app
flutter run

# 2. Test đăng ký tài khoản mới
# 3. Kiểm tra Firebase Console > Authentication > Users
# 4. Test đăng nhập với tài khoản vừa tạo
# 5. Test đăng xuất
```

---

### Ngày 5-7: Load dữ liệu Hotels & Tours

#### Bước 1: Thêm dữ liệu mẫu vào Firestore

**Vào Firebase Console > Firestore Database**

**Collection: hotels**
```json
{
  "name": "Khách sạn Metropole Hà Nội",
  "description": "Khách sạn 5 sao sang trọng tại trung tâm Hà Nội với kiến trúc Pháp cổ điển",
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

Thêm thêm 3-4 hotels nữa với các thành phố khác nhau.

**Collection: tours**
```json
{
  "name": "Tour Hạ Long 2N1Đ",
  "description": "Khám phá vịnh Hạ Long - Di sản thiên nhiên thế giới",
  "destination": "Vịnh Hạ Long",
  "country": "Việt Nam",
  "price": 1500000,
  "duration": 2,
  "rating": 4.7,
  "reviewCount": 850,
  "imageUrls": [
    "https://images.unsplash.com/photo-1528127269322-539801943592?w=800"
  ],
  "highlights": [
    "Tham quan động Thiên Cung",
    "Chèo kayak",
    "Bơi lội tại bãi biển",
    "Ăn tối trên du thuyền"
  ],
  "startDate": "2024-02-01T00:00:00.000Z",
  "endDate": "2024-02-02T00:00:00.000Z",
  "maxParticipants": 20,
  "currentParticipants": 5,
  "tourGuide": "Nguyễn Văn A"
}
```

Thêm thêm 3-4 tours nữa.

#### Bước 2: Code Hotels Screen

**File: `lib/screens/hotels_screen.dart`**

Thay toàn bộ phần `Expanded` (từ dòng ~70):

```dart
// Hotels list
Expanded(
  child: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('hotels')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Center(
          child: Text('Lỗi: ${snapshot.error}'),
        );
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hotel_outlined,
                size: AppSizes.iconXL * 2,
                color: AppColors.textHint,
              ),
              const SizedBox(height: AppSizes.paddingM),
              Text(
                'Không có khách sạn nào',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      // Convert Firestore docs to HotelModel
      final hotels = snapshot.data!.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Hotel.fromMap(data);
      }).toList();

      // Filter by search
      final filteredHotels = _searchCity.isEmpty
          ? hotels
          : hotels.where((hotel) {
              return hotel.city
                  .toLowerCase()
                  .contains(_searchCity.toLowerCase());
            }).toList();

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
  ),
)
```

**Thêm import:**
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hotel_model.dart';
import 'hotel_detail_screen.dart';
```

#### Bước 3: Code Tours Screen (Tương tự)

**File: `lib/screens/tours_screen.dart`**

Làm tương tự như hotels_screen, thay `hotels` bằng `tours`.

**Testing:**
```bash
# 1. Chạy app
flutter run

# 2. Vào tab "Khách sạn" - Phải thấy danh sách hotels
# 3. Vào tab "Tour du lịch" - Phải thấy danh sách tours
# 4. Test search
# 5. Click vào từng item để xem chi tiết
```

---

## TUẦN 2: BOOKING & PROFILE

### Ngày 8-10: Implement Booking

**File: `lib/screens/hotel_detail_screen.dart`**

Tìm hàm `_bookHotel()`, thay TODO:

```dart
Future<void> _bookHotel() async {
  if (_checkInDate == null || _checkOutDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vui lòng chọn ngày nhận và trả phòng')),
    );
    return;
  }

  setState(() => _isBooking = true);

  try {
    // 1. Get current user
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('Vui lòng đăng nhập');
    }

    // 2. Calculate total price
    final nights = _checkOutDate!.difference(_checkInDate!).inDays;
    final totalPrice = widget.hotel.pricePerNight * nights;

    // 3. Create booking
    final bookingData = {
      'userId': currentUser.uid,
      'type': 'hotel',
      'itemId': widget.hotel.id,
      'itemName': widget.hotel.name,
      'bookingDate': Timestamp.now(),
      'checkInDate': Timestamp.fromDate(_checkInDate!),
      'checkOutDate': Timestamp.fromDate(_checkOutDate!),
      'numberOfGuests': _numberOfGuests,
      'totalPrice': totalPrice,
      'status': 'pending',
    };

    // 4. Save to Firestore
    await FirebaseFirestore.instance
        .collection('bookings')
        .add(bookingData);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đặt phòng thành công!'),
          backgroundColor: AppColors.success,
        ),
      );
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
      setState(() => _isBooking = false);
    }
  }
}
```

**Thêm imports:**
```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
```

Làm tương tự cho `tour_detail_screen.dart`.

---

### Ngày 11-12: Bookings History

**File: `lib/screens/bookings_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.bookings)),
        body: const Center(
          child: Text('Vui lòng đăng nhập'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.bookings)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: currentUser.uid)
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

          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              return Card(
                margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
                child: ListTile(
                  leading: Icon(
                    data['type'] == 'hotel' ? Icons.hotel : Icons.tour,
                  ),
                  title: Text(data['itemName']),
                  subtitle: Text(
                    'Số khách: ${data['numberOfGuests']}',
                  ),
                  trailing: Text(
                    NumberFormat.currency(
                      locale: 'vi_VN',
                      symbol: '₫',
                    ).format(data['totalPrice']),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

---

### Ngày 13-14: Profile & Logout

**File: `lib/screens/profile_screen.dart`**

Thay phần load user data:

```dart
@override
Widget build(BuildContext context) {
  final currentUser = FirebaseAuth.instance.currentUser;
  
  if (currentUser == null) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: const Center(child: Text('Vui lòng đăng nhập')),
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: const Text(AppStrings.profile),
    ),
    body: FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get(),
      builder: (context, snapshot) {
        String userName = 'User';
        String userEmail = currentUser.email ?? '';
        
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          userName = data['name'] ?? 'User';
          userEmail = data['email'] ?? currentUser.email ?? '';
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // ... existing UI code ...
              
              // Logout button
              _ProfileOption(
                icon: Icons.logout,
                title: 'Đăng xuất',
                textColor: AppColors.error,
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Xác nhận đăng xuất'),
                      content: const Text('Bạn có chắc muốn đăng xuất?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Đăng xuất'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await FirebaseAuth.instance.signOut();
                    // App sẽ tự động chuyển về LoginScreen
                  }
                },
              ),
            ],
          ),
        );
      },
    ),
  );
}
```

---

## TUẦN 3: TESTING & POLISH

### Ngày 15-17: Testing

**Checklist:**
- [ ] Test đăng ký tài khoản mới
- [ ] Test đăng nhập
- [ ] Test xem danh sách hotels
- [ ] Test xem danh sách tours
- [ ] Test search hotels/tours
- [ ] Test đặt hotel
- [ ] Test đặt tour
- [ ] Test xem lịch sử booking
- [ ] Test profile
- [ ] Test đăng xuất

**Bug fixes:**
- Sửa các lỗi phát hiện khi test
- Thêm error handling
- Thêm loading states

---

### Ngày 18-21: Polish & Improvements

**1. Thêm loading states**
```dart
// Thêm vào mọi nơi có async operations
if (_isLoading) {
  return const Center(child: CircularProgressIndicator());
}
```

**2. Thêm error handling**
```dart
try {
  // Your code
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Lỗi: ${e.toString()}')),
  );
}
```

**3. Thêm validation**
- Validate email format
- Validate password strength
- Validate dates
- Validate số lượng khách

**4. UI improvements**
- Thêm animations
- Thêm empty states
- Thêm error states
- Cải thiện UX

**5. Code cleanup**
- Format code: `flutter format .`
- Remove unused imports
- Add comments
- Fix warnings

---

## 📝 CHECKLIST TỔNG THỂ

### Backend
- [ ] Firebase project created
- [ ] Authentication enabled
- [ ] Firestore database created
- [ ] Sample data added
- [ ] Firebase connected to app

### Features
- [ ] Login works
- [ ] Register works
- [ ] Hotels list loads
- [ ] Tours list loads
- [ ] Search works
- [ ] Hotel booking works
- [ ] Tour booking works
- [ ] Booking history shows
- [ ] Profile loads
- [ ] Logout works

### Quality
- [ ] No errors
- [ ] No warnings
- [ ] All features tested
- [ ] Code formatted
- [ ] Comments added
- [ ] README updated

---

## 🎯 MỤC TIÊU CUỐI CÙNG

Sau 3 tuần, bạn sẽ có:
- ✅ App hoạt động đầy đủ
- ✅ Có thể đăng ký/đăng nhập
- ✅ Xem và tìm kiếm hotels/tours
- ✅ Đặt phòng/tour
- ✅ Xem lịch sử
- ✅ Quản lý profile

---

## 💡 TIPS QUAN TRỌNG

1. **Code từng bước nhỏ** - Đừng code quá nhiều cùng lúc
2. **Test sau mỗi thay đổi** - Đảm bảo code chạy được
3. **Commit thường xuyên** - Backup code với Git
4. **Đọc error messages** - Flutter error rất chi tiết
5. **Tham khảo docs** - Flutter.dev và Firebase docs
6. **Đừng ngại hỏi** - Hỏi khi gặp khó khăn

---

## 📚 TÀI LIỆU THAM KHẢO

- **Flutter Docs**: https://docs.flutter.dev
- **Firebase Flutter**: https://firebase.google.com/docs/flutter
- **Firestore**: https://firebase.google.com/docs/firestore
- **Firebase Auth**: https://firebase.google.com/docs/auth

---

**Chúc bạn code thành công! 🚀💪**

> Nhớ: Làm từng bước, test kỹ, và đừng vội vàng!
