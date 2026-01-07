# 🏨 Booking Hotel App - Đồ Án Mobile

## 📱 Giới Thiệu
Ứng dụng đặt phòng khách sạn và tour du lịch được phát triển bằng Flutter và Firebase.

## 👥 Thành Viên Nhóm
- **Bôn** - Leader - Authentication & Profile
- **Trí** - Hotels & Hotel Details
- **Hậu** - Tours & Tour Details  
- **Bằng** - Trang Chủ (Home Screen)

## 🎯 Phân Công Công Việc

### 👤 Bôn - Authentication & Profile
**Branch:** `feature/auth-bon`

**Files:**
- ✅ `lib/screens/login_screen.dart`
- ✅ `lib/screens/register_screen.dart`
- ✅ `lib/screens/profile_screen.dart`
- ✅ `lib/screens/bookings_screen.dart`
- ✅ `lib/services/auth_service.dart`
- ✅ `lib/models/user.dart`
- ✅ `lib/models/booking.dart`

**Nhiệm vụ:**
- Đăng nhập/đăng ký với Firebase Auth
- Màn hình profile user
- Màn hình lịch sử bookings
- Service authentication
- Models User và Booking

---

### 👤 Trí - Hotels
**Branch:** `feature/hotels-member-a`

**Files:**
- ✅ `lib/screens/hotels_screen.dart`
- ✅ `lib/screens/hotel_detail_screen.dart`
- ✅ `lib/services/hotel_service.dart`
- ✅ `lib/models/hotel.dart`

**Nhiệm vụ:**
- Màn hình danh sách hotels với filter/search
- Màn hình chi tiết hotel
- Service đọc/ghi Firestore cho hotels
- Model Hotel với fromFirestore/toFirestore

---

### 👤  Hậu - Tours
**Branch:** `feature/tours-member-b`

**Files:**
- ✅ `lib/screens/tours_screen.dart`
- ✅ `lib/screens/tour_detail_screen.dart`
- ✅ `lib/services/tour_service.dart`
- ✅ `lib/models/tour.dart`

**Nhiệm vụ:**
- Màn hình danh sách tours với filter/search
- Màn hình chi tiết tour
- Service đọc/ghi Firestore cho tours
- Model Tour với fromFirestore/toFirestore

---

### 👤 Bằng - Trang Chủ
**Branch:** `feature/home-screen-bang`

**Files:**
- ✅ `lib/main.dart`
- ✅ `lib/screens/home_screen.dart`
- ✅ `lib/widgets/hotel_card.dart`
- ✅ `lib/widgets/tour_card.dart`

**Nhiệm vụ:**
- Tích hợp Firebase vào `main.dart`
- Hiển thị danh sách hotels và tours từ Firestore
- Tạo UI cards cho hotels và tours

---

## 🚀 Bắt Đầu

### 1. Clone Repository
```bash
git clone <repository-url>
cd da_booking_hotel
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Setup Firebase
- Đảm bảo file `google-services.json` có trong `android/app/`
- Tạo collections trong Firestore Console:
  - `hotels`
  - `tours`
  - `bookings`
  - `users`
- Thêm sample data (xem file `TEAM_ASSIGNMENT.md`)

### 4. Tạo Branch Riêng
làm xong thì merge vào branch test r báo cho leader kiểm tra kh được tự ý merge vào main
```bash
# Bôn
git checkout -b feature/auth-bon

# Trí
git checkout -b feature/hotels-member-a

# Hậu
git checkout -b feature/tours-member-b

# Bằng
git checkout -b feature/home-screen-bang
```

### 5. Chạy App
```bash
flutter run
```

---

## 🔄 Git Workflow

### Làm Việc Hàng Ngày
```bash
# 1. Pull code mới nhất
git pull origin main

# 2. Chuyển về branch của mình
git checkout feature/auth-bon  # hoặc branch của bạn

# 3. Làm việc trên files được phân công

# 4. Commit thường xuyên
git add .
git commit -m "feat: implement feature"

# 5. Push lên branch của mình
git push origin feature/auth-bon  # hoặc branch của bạn
```

### Merge Code
1. Push code lên branch của bạn
2. Tạo Pull Request trên GitHub/GitLab
3. Đợi review từ team
4. Merge vào `main`
5. Thông báo team đã merge

---

## 🚨 QUY TẮC QUAN TRỌNG

### ✅ PHẢI LÀM:
1. **Luôn tạo branch riêng** - KHÔNG làm việc trên `main`
2. **Chỉ chỉnh sửa files được phân công**
3. **Pull code mới trước khi bắt đầu**
4. **Commit thường xuyên** với message rõ ràng
5. **Thông báo team** khi merge

### ❌ KHÔNG ĐƯỢC:
1. ❌ Chỉnh sửa files của người khác
2. ❌ Commit trực tiếp lên `main`
3. ❌ Force push (`git push -f`)
4. ❌ Merge mà không thông báo

---

## 📚 Tài Liệu

- **TEAM_ASSIGNMENT.md** - Phân công chi tiết + hướng dẫn
- **GIT_GUIDE.md** - Git commands và workflow
- **FIREBASE_SETUP.md** - Hướng dẫn Firebase

---

## 🛠️ Tech Stack

- **Framework:** Flutter 3.10+
- **Language:** Dart
- **Backend:** Firebase
  - Firebase Auth (Authentication)
  - Cloud Firestore (Database)
  - Firebase Core
- **State Management:** Provider
- **UI:** Material Design

---

## 📞 Liên Hệ

- **Leader:** Bôn
- **Group Chat:** [Link group chat]

---

## ✅ Checklist Tổng Thể

### Setup
- [ ] Clone repository
- [ ] Install dependencies
- [ ] Setup Firebase
- [ ] Tạo sample data trong Firestore
- [ ] Tạo branch riêng

### Development
- [ ] Bôn: Hoàn thành authentication & profile
- [ ] Trí: Hoàn thành hotels
- [ ] Hậu: Hoàn thành tours
- [ ] Bằng: Hoàn thành trang chủ

### Integration
- [ ] Merge tất cả branches
- [ ] Test tích hợp
- [ ] Fix bugs
- [ ] Final testing

### Deployment
- [ ] Build APK
- [ ] Test trên device thật
- [ ] Demo

---

**🚀 Chúc nhóm làm việc hiệu quả!**


Yêu cầu Cấu trúc & Nguyên tắc Lập trình:
Công nghệ Cơ bản: Sử dụng Dart và Flutter để xây dựng ứng dụng đa nền tảng.
Cấu trúc Dự án: Cung cấp cấu trúc thư mục rõ ràng theo mô hình MVVM (Model-View-ViewModel) hoặc Repository Pattern.
Quản lý Trạng thái (State Management):
Sử dụng thư viện [Chọn 1 trong 3: Provider, BLoC (Cubit), hoặc GetX] để quản lý trạng thái toàn cục (Global State) của ứng dụng (ví dụ: trạng thái đăng nhập, danh sách khách sạn).
Minh họa việc sử dụng StatelessWidget và StatefulWidget đúng mục đích.
Yêu cầu Triển khai Code các Tính năng Chính:
1. Giao diện & Bố cục (Áp dụng Bài 3 & 4):
Thành phần cơ bản: Sử dụng Scaffold, AppBar, và các Widget Material Design/Cupertino.
Bố cục Hiển thị: Xây dựng màn hình danh sách khách sạn (Home) và màn hình Lịch sử Đơn hàng. Cả hai đều phải sử dụng ListView.builder (hoặc GridView.builder nếu phù hợp) để tối ưu hóa hiệu suất hiển thị.
Thiết kế Card: Sử dụng Widget Card và Padding để thiết kế giao diện từng mục khách sạn, bên trong sử dụng Row và Column kết hợp với Expanded để căn chỉnh bố cục một cách linh hoạt.
Tương tác Form: Thiết kế màn hình Đăng nhập/Đăng ký và màn hình Đặt phòng (Booking Form) sử dụng TextField (với InputDecoration đầy đủ) và ElevatedButton.
2. Điều hướng (Navigation) (Áp dụng Bài 3 & 4):
Sử dụng Named Routes (Định tuyến có tên) để quản lý việc chuyển đổi giữa các màn hình (Home, Detail, Booking).
Minh họa cách chuyển đối tượng dữ liệu (Model Khách sạn) khi chuyển từ màn hình Home sang màn hình Chi tiết thông qua Navigator.pushNamed (sử dụng thuộc tính arguments).
3. Giao tiếp Dữ liệu & Firebase (Áp dụng Bài 6-P1, P2, P3):
Model Dữ liệu & JSON: Tạo các lớp (Class) HotelModel, RoomModel, và BookingModel với các phương thức fromJson và toJson để thực hiện JSON Serialization/Deserialization (chuyển đổi dữ liệu).
Khởi tạo Firebase: Minh họa cách sử dụng Firebase.initializeApp() trong hàm main() để khởi tạo cấu hình.
Firebase Authentication: Viết một lớp AuthService với các hàm cơ bản để mô phỏng Đăng nhập ẩn danh (signInAnonymously) hoặc Đăng ký/Đăng nhập bằng Email/Mật khẩu.
Firebase Cloud Firestore (Data Management):
Viết một lớp HotelRepository chuyên trách việc giao tiếp với Firestore.
Minh họa cách tạo CollectionReference để trỏ đến bộ sưu tập hotels và bookings.
Triển khai hàm fetchHotels sử dụng truy vấn Firestore có điều kiện (where()) và sắp xếp (orderBy()) để mô phỏng tính năng Tìm kiếm/Lọc.
Triển khai hàm streamBookings sử dụng snapshots() để minh họa việc lấy dữ liệu theo thời gian thực cho màn hình Lịch sử Đơn hàng.
Triển khai thao tác Thêm/Cập nhật/Xóa dữ liệu đơn hàng (ví dụ: add(), update(), delete()).
4. Lưu trữ Dữ liệu Bổ sung (Áp dụng Bài 6-P2, P3):
Lưu trữ Cục bộ: Minh họa việc sử dụng Shared Preferences để lưu trữ token hoặc trạng thái đăng nhập của người dùng.
Hoặc nếu cần quản lý cấu trúc dữ liệu phức tạp hơn ngoài Firestore: Viết một lớp DatabaseHelper với các hàm để mở/đóng cơ sở dữ liệu và thực hiện thao tác CRUD với SQFLite (SQLite).
5. Áp dụng Thư viện Nâng cao (Áp dụng Bài 5 & Đề tài Thư viện):
Tích hợp thư viện cached_network_image hoặc image_picker để xử lý hiển thị/tương tác với hình ảnh khách sạn.
Minh họa cách xử lý Toast Notification hoặc SnackBar để hiển thị thông báo thành công/thất bại sau khi Đặt phòng.