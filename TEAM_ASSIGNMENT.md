# 👥 Phân Công Chi Tiết - Nhóm Booking Hotel

## 📋 Tổng Quan

Mỗi thành viên làm việc trên **branch riêng** và chỉ chỉnh sửa **files được phân công** để tránh conflict.

---

## 👤 BÔN - Authentication & Profile

### Branch
```bash
feature/auth-bon
```

### Files Được Phân Công
```
✅ lib/screens/login_screen.dart
✅ lib/screens/register_screen.dart
✅ lib/screens/profile_screen.dart
✅ lib/screens/bookings_screen.dart
✅ lib/services/auth_service.dart
✅ lib/models/user.dart
✅ lib/models/booking.dart
```

### Nhiệm Vụ Chi Tiết

#### 1. `lib/main.dart`
- Khởi tạo Firebase
- Setup MaterialApp
- Routing cơ bản

**Code mẫu:**
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Booking Hotel',
      home: const HomeScreen(),
    );
  }
}
```

#### 2. `lib/screens/home_screen.dart`
- Hiển thị danh sách hotels từ Firestore (StreamBuilder)
- Hiển thị danh sách tours từ Firestore (StreamBuilder)
- Search bar (optional)
- Bottom navigation

**Code mẫu:**
```dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/hotel_card.dart';
import '../widgets/tour_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trang Chủ')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hotels Section
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('🏨 Khách Sạn', 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('hotels').limit(5).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                return SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var hotel = snapshot.data!.docs[index];
                      return HotelCard(
                        name: hotel['name'],
                        location: hotel['location'],
                        price: hotel['price'].toDouble(),
                        imageUrl: hotel['imageUrl'],
                      );
                    },
                  ),
                );
              },
            ),
            // Tours Section (tương tự)
          ],
        ),
      ),
    );
  }
}
```

#### 3. `lib/widgets/hotel_card.dart`
- Widget card hiển thị thông tin hotel
- Hình ảnh, tên, location, giá, rating
- OnTap navigate to detail (sau khi A làm xong)

#### 4. `lib/widgets/tour_card.dart`
- Widget card hiển thị thông tin tour
- Hình ảnh, tên, duration, giá, rating
- OnTap navigate to detail (sau khi B làm xong)

### Git Commands
```bash
git checkout -b feature/auth-bon
# Làm việc...
git add lib/screens/login_screen.dart lib/services/auth_service.dart
git commit -m "feat: implement authentication"
git push origin feature/auth-bon
```

---

## 👤 Trí - Hotels

### Branch
```bash
feature/hotels-member-a
```

### Files Được Phân Công
```
✅ lib/screens/hotels_screen.dart
✅ lib/screens/hotel_detail_screen.dart
✅ lib/services/hotel_service.dart
✅ lib/models/hotel.dart
```

### Nhiệm Vụ Chi Tiết

#### 1. `lib/models/hotel.dart`
- Model class cho Hotel
- fromFirestore() method
- toFirestore() method

**Code mẫu:**
```dart
class Hotel {
  final String id;
  final String name;
  final String description;
  final String location;
  final double price;
  final double rating;
  final String imageUrl;
  final List<String> amenities;

  Hotel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.amenities,
  });

  factory Hotel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Hotel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      rating: (data['rating'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      amenities: List<String>.from(data['amenities'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'price': price,
      'rating': rating,
      'imageUrl': imageUrl,
      'amenities': amenities,
    };
  }
}
```

#### 2. `lib/services/hotel_service.dart`
- getHotels() - Lấy tất cả hotels
- getHotelById(id) - Lấy 1 hotel
- searchHotels(query) - Tìm kiếm

**Code mẫu:**
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hotel.dart';

class HotelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Hotel>> getHotels() {
    return _firestore.collection('hotels').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => 
        Hotel.fromFirestore(doc)).toList(),
    );
  }

  Future<Hotel?> getHotelById(String id) async {
    var doc = await _firestore.collection('hotels').doc(id).get();
    if (doc.exists) {
      return Hotel.fromFirestore(doc);
    }
    return null;
  }
}
```

#### 3. `lib/screens/hotels_screen.dart`
- Hiển thị tất cả hotels
- Filter, search
- Grid/List view

#### 4. `lib/screens/hotel_detail_screen.dart`
- Hiển thị chi tiết hotel
- Image gallery
- Amenities list
- Nút "Book Now"

### Git Commands
```bash
git checkout -b feature/hotels-member-a
# Làm việc...
git add lib/models/hotel.dart lib/services/hotel_service.dart
git commit -m "feat: add hotel model and service"
git push origin feature/hotels-member-a
```

---

## 👤 Hậu - Tours

### Branch
```bash
feature/tours-member-b
```

### Files Được Phân Công
```
✅ lib/screens/tours_screen.dart
✅ lib/screens/tour_detail_screen.dart
✅ lib/services/tour_service.dart
✅ lib/models/tour.dart
```

### Nhiệm Vụ Chi Tiết

#### 1. `lib/models/tour.dart`
- Model class cho Tour
- fromFirestore() method
- toFirestore() method

**Code mẫu:** (Tương tự Hotel model)

#### 2. `lib/services/tour_service.dart`
- getTours() - Lấy tất cả tours
- getTourById(id) - Lấy 1 tour
- searchTours(query) - Tìm kiếm

**Code mẫu:** (Tương tự HotelService)

#### 3. `lib/screens/tours_screen.dart`
- Hiển thị tất cả tours
- Filter, search
- Grid/List view

#### 4. `lib/screens/tour_detail_screen.dart`
- Hiển thị chi tiết tour
- Image gallery
- Includes list
- Nút "Book Now"

### Git Commands
```bash
git checkout -b feature/tours-member-b
# Làm việc...
git add lib/models/tour.dart lib/services/tour_service.dart
git commit -m "feat: add tour model and service"
git push origin feature/tours-member-b
```

---

## 👤 BẰNG - Trang Chủ

### Branch
```bash
feature/home-screen-bang
```

### Files Được Phân Công
```
✅ lib/main.dart
✅ lib/screens/home_screen.dart
✅ lib/widgets/hotel_card.dart
✅ lib/widgets/tour_card.dart
```

### Nhiệm Vụ Chi Tiết

#### 1. `lib/main.dart`
- Khởi tạo Firebase
- Setup MaterialApp
- Routing cơ bản

**Code mẫu:** (Xem phần Bôn ở trên)

#### 2. `lib/screens/home_screen.dart`
- Hiển thị danh sách hotels và tours từ Firestore
- Search bar (optional)
- Bottom navigation

**Code mẫu:** (Xem phần Bôn ở trên)

#### 3. `lib/widgets/hotel_card.dart`
- Widget card hiển thị thông tin hotel

#### 4. `lib/widgets/tour_card.dart`
- Widget card hiển thị thông tin tour

**Code mẫu:**
```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User?> register(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Lưu thông tin user vào Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return result.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
```

#### 2. `lib/models/user.dart`
- User model
- fromFirestore()

#### 3. `lib/models/booking.dart`
- Booking model
- fromFirestore()

#### 4. `lib/screens/login_screen.dart`
- Email/Password login form
- Validation
- Navigate to home sau khi login

#### 5. `lib/screens/register_screen.dart`
- Registration form
- Validation
- Tạo user trong Firestore

#### 6. `lib/screens/profile_screen.dart`
- Hiển thị thông tin user
- Edit profile
- Logout button

#### 7. `lib/screens/bookings_screen.dart`
- Hiển thị lịch sử bookings của user
- Chi tiết từng booking

### Git Commands
```bash
git checkout -b feature/home-screen-bang
# Làm việc...
git add lib/main.dart lib/screens/home_screen.dart
git commit -m "feat: implement home screen"
git push origin feature/home-screen-bang
```

---

## 📅 Timeline

### Tuần 1
- **Ngày 1-2:** Setup, tạo branches, Firebase setup
- **Ngày 3-5:** Implement basic screens
- **Ngày 6-7:** Testing cơ bản

### Tuần 2
- **Ngày 1-3:** Tích hợp, merge branches
- **Ngày 4-5:** Bug fixes
- **Ngày 6-7:** Final testing, demo

---

## 🚨 Lưu Ý Quan Trọng

1. **Chỉ chỉnh sửa files được phân công** - Tránh conflict!
2. **Pull thường xuyên** từ main
3. **Commit thường xuyên** với message rõ ràng
4. **Thông báo team** khi merge
5. **Test kỹ** trước khi push

---

## 📞 Communication

- Daily standup: Update tiến độ mỗi ngày
- Group chat: Hỏi đáp, thông báo
- Code review: Review lẫn nhau trước khi merge

**Chúc nhóm thành công! 🚀**
