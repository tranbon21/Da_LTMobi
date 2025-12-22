# 🔥 Firebase Setup Guide

## ✅ Đã Hoàn Thành
- [x] Cài đặt Firebase packages
- [x] Thêm Firebase initialization vào `main.dart`

## 📱 Bước 1: Tạo Firebase Project

1. **Truy cập Firebase Console**
   - Vào: https://console.firebase.google.com/
   - Đăng nhập Google

2. **Tạo Project**
   - Click "Add project"
   - Tên: `booking-hotel`
   - Tắt Google Analytics
   - Click "Create project"

## 🤖 Bước 2: Thêm Android App

1. **Trong Firebase Console**
   - Click biểu tượng Android

2. **Điền Thông Tin**
   - Package name: `com.example.da_booking_hotel`
   - App nickname: `Booking Hotel`
   - Click "Register app"

3. **Download google-services.json**
   - Click "Download google-services.json"
   - Copy vào: `android/app/google-services.json`
   - Click "Next" → "Next" → "Continue to console"

## 🔐 Bước 3: Bật Firebase Services

### 3.1 Authentication
1. Vào **Build** → **Authentication**
2. Click "Get started"
3. Chọn **Email/Password**
4. Click "Enable" → "Save"

### 3.2 Firestore Database
1. Vào **Build** → **Firestore Database**
2. Click "Create database"
3. Chọn **"Start in test mode"**
4. Location: **asia-southeast1** (Singapore)
5. Click "Enable"

### 3.3 Storage (Optional)
Nếu cần upload ảnh:
1. Vào **Build** → **Storage**
2. Click "Get started"
3. Chọ "Start in test mode"
4. Location: **asia-southeast1**

## 📦 Bước 4: Thêm Sample Data

### Tạo Collection: hotels

1. Vào Firestore Database
2. Click "Start collection"
3. Collection ID: `hotels`
4. Click "Next"

### Thêm Document Đầu Tiên

**Document ID:** `hotel_001`

**Fields:**
| Field | Type | Value |
|-------|------|-------|
| name | string | Sunrise Beach Resort |
| description | string | Khách sạn 5 sao view biển |
| location | string | Nha Trang, Việt Nam |
| price | number | 1500000 |
| rating | number | 4.8 |
| imageUrl | string | https://images.unsplash.com/photo-1566073771259-6a8506099945 |
| amenities | array | ["WiFi", "Bể bơi", "Gym"] |

Click "Save"

### Thêm Thêm Hotels

Lặp lại với các hotels khác:

**Hotel 2:**
```
Document ID: hotel_002
name: City Grand Hotel
location: Hà Nội, Việt Nam
price: 1200000
rating: 4.6
imageUrl: https://images.unsplash.com/photo-1542314831-068cd1dbfeeb
amenities: ["WiFi", "Bể bơi", "Nhà hàng"]
```

**Hotel 3:**
```
Document ID: hotel_003
name: Mountain View Resort
location: Đà Lạt, Việt Nam
price: 1800000
rating: 4.9
imageUrl: https://images.unsplash.com/photo-1571896349842-33c89424de2d
amenities: ["WiFi", "Spa", "Sân golf"]
```

### Tạo Collection: tours

Tương tự, tạo collection `tours`:

**Tour 1:**
```
Document ID: tour_001
name: Tour Hạ Long 2N1Đ
description: Khám phá vịnh Hạ Long
duration: 2 ngày 1 đêm
price: 2500000
rating: 4.9
imageUrl: https://images.unsplash.com/photo-1528127269322-539801943592
includes: ["Xe đưa đón", "Khách sạn", "Ăn uống"]
```

**Tour 2:**
```
Document ID: tour_002
name: Tour Sapa 3N2Đ
description: Chinh phục Fansipan
duration: 3 ngày 2 đêm
price: 3200000
rating: 4.8
imageUrl: https://images.unsplash.com/photo-1559628376-f3fe5f782a2e
includes: ["Xe đưa đón", "Khách sạn", "Vé cáp treo"]
```

## ✅ Bước 5: Test

Chạy app:
```bash
flutter run
```

Nếu không có lỗi Firebase → Thành công! 🎉

## 🐛 Troubleshooting

### Lỗi: "google-services.json not found"
- Đảm bảo file ở đúng vị trí: `android/app/google-services.json`

### Lỗi: "Failed to initialize Firebase"
- Kiểm tra package name khớp với Firebase Console
- Package name: `com.example.da_booking_hotel`

### Lỗi: "Firestore permission denied"
- Đảm bảo Firestore ở **test mode**
- Vào Firestore → Rules → Kiểm tra:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

## 🌐 Nguồn Hình Ảnh

Dùng URL từ Unsplash (miễn phí):
- Hotels: https://unsplash.com/s/photos/hotel
- Tours: https://unsplash.com/s/photos/travel

Click chuột phải → Copy image address → Paste vào `imageUrl`

## 📞 Cần Trợ Giúp?

Nếu gặp lỗi:
1. Copy error message
2. Hỏi trong group chat
3. Liên hệ Bôn

**Chúc setup thành công! 🚀**
