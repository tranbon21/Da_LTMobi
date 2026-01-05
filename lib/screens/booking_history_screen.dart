// Import thư viện Flutter Material Design
import 'package:flutter/material.dart';
// Import Firebase Auth để lấy user hiện tại
import 'package:firebase_auth/firebase_auth.dart';
// Import các constants của app
import '../utils/constants.dart';
// Import FirestoreService để lấy danh sách booking
import '../services/firestore_service.dart';
// Import BookingModel
import '../models/booking_model.dart';
// Import intl để format số tiền
import 'package:intl/intl.dart';

/// Màn hình Lịch sử đặt phòng
///
/// Màn hình này hiển thị danh sách các booking mà user đã đặt,
/// bao gồm cả booking đang chờ, đã xác nhận, đã hoàn thành và đã hủy
class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy user hiện tại từ Firebase Auth
    final currentUser = FirebaseAuth.instance.currentUser;

    // Nếu không có user hoặc là guest thì hiển thị thông báo
    if (currentUser == null || currentUser.isAnonymous) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lịch sử đặt phòng')),
        body: const Center(
          child: Text('Vui lòng đăng nhập để xem lịch sử đặt phòng'),
        ),
      );
    }

    return Scaffold(
      // AppBar với tiêu đề "Lịch sử đặt phòng"
      appBar: AppBar(title: const Text('Lịch sử đặt phòng')),

      // Body của màn hình - sử dụng StreamBuilder để lắng nghe realtime updates
      body: StreamBuilder<List<Booking>>(
        // Stream từ FirestoreService - tự động cập nhật khi có thay đổi
        stream: FirestoreService().getUserBookings(currentUser.uid),

        // Builder để xây dựng UI dựa trên snapshot của stream
        builder: (context, snapshot) {
          // Kiểm tra trạng thái của stream

          // Nếu đang chờ dữ liệu (loading)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Nếu có lỗi
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Có lỗi xảy ra: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Lấy danh sách booking từ snapshot
          final bookings = snapshot.data ?? [];

          // Sắp xếp bookings theo bookingDate (mới nhất trước)
          // Sắp xếp ở client side vì đã bỏ orderBy trong query
          bookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));

          // Nếu chưa có booking nào
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Icon(Icons.history, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: AppSizes.paddingL),

                  // Text
                  Text(
                    'Chưa có lịch sử đặt phòng',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: AppSizes.paddingS),

                  Text(
                    'Hãy đặt phòng đầu tiên của bạn!',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          // Hiển thị danh sách booking
          // Lưu ý: Dữ liệu đã được sắp xếp theo bookingDate descending trong query
          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _BookingCard(booking: booking);
            },
          );
        },
      ),
    );
  }
}

/// Widget _BookingCard - Hiển thị một booking card
class _BookingCard extends StatelessWidget {
  /// Booking cần hiển thị
  final Booking booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    // Format tiền tệ theo định dạng Việt Nam
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    // Format ngày tháng theo định dạng dd/MM/yyyy
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Xác định màu và text cho status
    Color statusColor;
    String statusText;
    switch (booking.status) {
      case BookingStatus.pending:
        // Đang chờ xác nhận - màu cam
        statusColor = Colors.orange;
        statusText = 'Đang chờ';
        break;
      case BookingStatus.confirmed:
        // Đã xác nhận - màu xanh lá
        statusColor = Colors.green;
        statusText = 'Đã xác nhận';
        break;
      case BookingStatus.completed:
        // Đã hoàn thành - màu xanh dương
        statusColor = Colors.blue;
        statusText = 'Đã hoàn thành';
        break;
      case BookingStatus.cancelled:
        // Đã hủy - màu đỏ
        statusColor = Colors.red;
        statusText = 'Đã hủy';
        break;
    }

    return Card(
      // Margin giữa các card
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),

      // Nội dung của card
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== HEADER ====================

            // Tên khách sạn và status badge
            Row(
              children: [
                // Tên khách sạn (có thể rất dài nên cần Expanded)
                Expanded(
                  child: Text(
                    booking.itemName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: AppSizes.paddingS),

                // Status badge với màu tương ứng
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    // Màu nền nhạt
                    color: statusColor.withValues(alpha: 0.1),
                    // Bo góc
                    borderRadius: BorderRadius.circular(12),
                    // Viền với màu đậm hơn
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.paddingM),

            // ==================== THÔNG TIN BOOKING ====================

            // Ngày nhận phòng
            _InfoRow(
              icon: Icons.login,
              label: 'Nhận phòng',
              value: dateFormat.format(booking.checkInDate),
            ),

            const SizedBox(height: AppSizes.paddingS),

            // Ngày trả phòng
            _InfoRow(
              icon: Icons.logout,
              label: 'Trả phòng',
              value: dateFormat.format(booking.checkOutDate),
            ),

            const SizedBox(height: AppSizes.paddingS),

            // Số khách
            _InfoRow(
              icon: Icons.people,
              label: 'Số khách',
              value: '${booking.numberOfGuests} người',
            ),

            const SizedBox(height: AppSizes.paddingM),
            const Divider(),
            const SizedBox(height: AppSizes.paddingM),

            // ==================== FOOTER ====================

            // Tổng tiền
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng tiền',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  currencyFormat.format(booking.totalPrice),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget _InfoRow - Hiển thị một dòng thông tin
///
/// Widget này hiển thị:
/// - Icon bên trái
/// - Label và value
class _InfoRow extends StatelessWidget {
  /// Icon hiển thị
  final IconData icon;

  /// Label của thông tin
  final String label;

  /// Giá trị của thông tin
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSizes.paddingS),

        // Label
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),

        // Value
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
