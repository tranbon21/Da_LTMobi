import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Accent colors
  static const Color accent = Color(0xFFFF9800);
  static const Color accentDark = Color(0xFFF57C00);
  static const Color accentLight = Color(0xFFFFB74D);

  // Neutral colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Border colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);
}

class AppSizes {
  // Padding
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Border radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusRound = 100.0;

  // Icon sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Image sizes
  static const double imageThumbS = 60.0;
  static const double imageThumbM = 100.0;
  static const double imageThumbL = 150.0;
  static const double imageCard = 200.0;

  // Button heights
  static const double buttonHeightS = 36.0;
  static const double buttonHeightM = 48.0;
  static const double buttonHeightL = 56.0;
}

class AppStrings {
  // App
  static const String appName = 'Travel Booking';

  // Auth
  static const String login = 'Đăng nhập';
  static const String register = 'Đăng ký';
  static const String logout = 'Đăng xuất';
  static const String email = 'Email';
  static const String password = 'Mật khẩu';
  static const String confirmPassword = 'Xác nhận mật khẩu';
  static const String name = 'Họ và tên';
  static const String phoneNumber = 'Số điện thoại';
  static const String forgotPassword = 'Quên mật khẩu?';
  static const String dontHaveAccount = 'Chưa có tài khoản?';
  static const String alreadyHaveAccount = 'Đã có tài khoản?';

  // Navigation
  static const String home = 'Trang chủ';
  static const String hotels = 'Khách sạn';
  static const String tours = 'Tour du lịch';
  static const String bookings = 'Đặt phòng';
  static const String profile = 'Tài khoản';

  // Hotel
  static const String searchHotels = 'Tìm khách sạn';
  static const String hotelDetails = 'Chi tiết khách sạn';
  static const String pricePerNight = 'Giá/đêm';
  static const String availableRooms = 'Phòng trống';
  static const String amenities = 'Tiện nghi';

  // Tour
  static const String searchTours = 'Tìm tour';
  static const String tourDetails = 'Chi tiết tour';
  static const String duration = 'Thời gian';
  static const String tourGuide = 'Hướng dẫn viên';
  static const String highlights = 'Điểm nổi bật';

  // Booking
  static const String bookNow = 'Đặt ngay';
  static const String checkIn = 'Nhận phòng';
  static const String checkOut = 'Trả phòng';
  static const String guests = 'Số khách';
  static const String totalPrice = 'Tổng giá';
  static const String confirmBooking = 'Xác nhận đặt phòng';
  static const String cancelBooking = 'Hủy đặt phòng';
  static const String bookingHistory = 'Lịch sử đặt phòng';

  // Common
  static const String search = 'Tìm kiếm';
  static const String filter = 'Lọc';
  static const String sort = 'Sắp xếp';
  static const String cancel = 'Hủy';
  static const String confirm = 'Xác nhận';
  static const String save = 'Lưu';
  static const String edit = 'Sửa';
  static const String delete = 'Xóa';
  static const String loading = 'Đang tải...';
  static const String error = 'Lỗi';
  static const String success = 'Thành công';
  static const String noData = 'Không có dữ liệu';
}

/// Class chứa các duration constants cho animations và delays
class AppDurations {
  // Dialog & Navigation
  static const dialogCloseDelay = Duration(milliseconds: 200);
  static const navigationDelay = Duration(milliseconds: 100);
  
  // Carousel
  static const carouselAutoPlayInterval = Duration(seconds: 4);
  static const carouselAnimationDuration = Duration(milliseconds: 800);
  
  // Toast
  static const toastShort = Duration(seconds: 2);
  static const toastLong = Duration(seconds: 4);
  
  // Loading
  static const loadingMinDisplay = Duration(milliseconds: 500);
  static const loadingTimeout = Duration(seconds: 30);
}
