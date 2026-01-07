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
// Import intl để format số tiền và ngày tháng
import 'package:intl/intl.dart';
// Import EasyLoading để hiển thị loading và thông báo
import 'package:flutter_easyloading/flutter_easyloading.dart';

/// Màn hình Đặt phòng (Bookings Screen)
///
/// Màn hình này hiển thị danh sách các booking mà user đã đặt
/// Cho phép user:
/// - Xem thông tin chi tiết booking
/// - Hủy booking trong vòng 24 giờ kể từ khi đặt
class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  // ==================== HELPER METHODS ====================

  /// Kiểm tra xem booking có thể hủy không
  ///
  /// Điều kiện để hủy:
  /// 1. Status phải là pending hoặc confirmed
  /// 2. Chưa quá 24 giờ kể từ khi đặt
  bool _canCancelBooking(Booking booking) {
    // Kiểm tra status - chỉ cho phép hủy nếu đang pending hoặc confirmed
    if (booking.status != BookingStatus.pending &&
        booking.status != BookingStatus.confirmed) {
      return false;
    }

    // Lấy thời gian hiện tại
    final now = DateTime.now();
    // Lấy thời gian đặt booking
    final bookingTime = booking.bookingDate;
    // Tính khoảng cách thời gian
    final difference = now.difference(bookingTime);

    // Chỉ cho phép hủy nếu chưa quá 24 giờ
    return difference.inHours < 24;
  }

  /// Tính thời gian còn lại để có thể hủy booking
  ///
  /// Trả về Duration còn lại
  /// Nếu đã quá hạn thì trả về Duration.zero
  Duration _timeRemainingToCancel(Booking booking) {
    // Tính deadline = thời gian đặt + 24 giờ
    final deadline = booking.bookingDate.add(const Duration(hours: 24));
    // Lấy thời gian hiện tại
    final now = DateTime.now();

    // Nếu đã quá deadline thì return 0
    if (now.isAfter(deadline)) {
      return Duration.zero;
    }

    // Trả về khoảng thời gian còn lại
    return deadline.difference(now);
  }

  /// Format thời gian còn lại thành string dễ đọc
  ///
  /// Ví dụ: "Còn 18h 30m", "Còn 45m", "Sắp hết hạn"
  String _formatTimeRemaining(Duration duration) {
    // Nếu còn > 1 giờ thì hiển thị giờ và phút
    if (duration.inHours > 0) {
      return 'Còn ${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    // Nếu còn > 0 phút thì chỉ hiển thị phút
    else if (duration.inMinutes > 0) {
      return 'Còn ${duration.inMinutes}m';
    }
    // Nếu < 1 phút thì hiển thị "Sắp hết hạn"
    else {
      return 'Sắp hết hạn';
    }
  }

  /// Xử lý hủy booking
  ///
  /// Hiển thị dialog xác nhận, sau đó gọi API để hủy
  Future<void> _handleCancelBooking(Booking booking) async {
    // Hiển thị dialog xác nhận
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        // Tiêu đề dialog
        title: const Text('Xác nhận hủy'),
        // Nội dung dialog
        content: Text(
          'Bạn có chắc muốn hủy đặt phòng "${booking.itemName}"?\n\n'
          'Hành động này không thể hoàn tác.',
        ),
        // Các nút hành động
        actions: [
          // Nút "Không"
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          // Nút "Hủy đặt phòng" màu đỏ
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hủy đặt phòng'),
          ),
        ],
      ),
    );

    // Nếu user không confirm hoặc widget đã bị dispose thì return
    if (confirm != true || !mounted) return;

    try {
      // Hiển thị loading
      EasyLoading.show(status: 'Đang hủy...');

      // Gọi FirestoreService để hủy booking
      await FirestoreService().cancelBooking(booking.id);

      // Dismiss loading
      EasyLoading.dismiss();

      // Hiển thị thông báo thành công
      EasyLoading.showSuccess(
        'Đã hủy đặt phòng thành công!',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      // Có lỗi xảy ra
      EasyLoading.dismiss();

      // Hiển thị thông báo lỗi
      EasyLoading.showError(
        'Hủy thất bại: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ==================== BUILD UI ====================

  @override
  Widget build(BuildContext context) {
    // Lấy user hiện tại từ Firebase Auth
    final currentUser = FirebaseAuth.instance.currentUser;

    // Nếu chưa đăng nhập hoặc là guest thì hiển thị thông báo
    if (currentUser == null || currentUser.isAnonymous) {
      return Scaffold(
        // AppBar với tiêu đề "Đặt phòng"
        appBar: AppBar(title: const Text(AppStrings.bookings)),
        // Body hiển thị thông báo yêu cầu đăng nhập
        body: const Center(child: Text('Vui lòng đăng nhập để xem đặt phòng')),
      );
    }

    return Scaffold(
      // AppBar với tiêu đề "Đặt phòng"
      appBar: AppBar(title: const Text(AppStrings.bookings)),

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
                  // Icon lỗi
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  // Text thông báo lỗi
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
          bookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));

          // Nếu chưa có booking nào
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Icon(
                    Icons.book_online_outlined,
                    size: AppSizes.iconXL * 2,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  // Text "Chưa có đặt phòng nào"
                  Text(
                    'Chưa có đặt phòng nào',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingS),

                  // Text gợi ý
                  Text(
                    'Hãy đặt phòng đầu tiên của bạn!',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textHint),
                  ),
                ],
              ),
            );
          }

          // Hiển thị danh sách booking
          return ListView.builder(
            // Padding xung quanh list
            padding: const EdgeInsets.all(AppSizes.paddingM),
            // Số lượng items
            itemCount: bookings.length,
            // Builder cho từng item
            itemBuilder: (context, index) {
              // Lấy booking tại vị trí index
              final booking = bookings[index];
              // Trả về BookingCard widget
              return _BookingCard(
                booking: booking,
                canCancel: _canCancelBooking(booking),
                timeRemaining: _timeRemainingToCancel(booking),
                onCancel: () => _handleCancelBooking(booking),
              );
            },
          );
        },
      ),
    );
  }
}

/// Widget _BookingCard - Hiển thị một booking card
///
/// Widget này hiển thị thông tin chi tiết của một booking
/// bao gồm tên, ngày, số khách, giá, status, và nút hủy (nếu có)
class _BookingCard extends StatelessWidget {
  /// Booking cần hiển thị
  final Booking booking;

  /// Có thể hủy booking này không
  final bool canCancel;

  /// Thời gian còn lại để hủy
  final Duration timeRemaining;

  /// Callback khi user click nút hủy
  final VoidCallback onCancel;

  const _BookingCard({
    required this.booking,
    required this.canCancel,
    required this.timeRemaining,
    required this.onCancel,
  });

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

            // Tên booking và status badge
            Row(
              children: [
                // Icon - hotel hoặc tour (dựa vào itemType nếu có)
                // Tạm thời dùng icon chung
                const Icon(Icons.hotel, size: 24, color: AppColors.primary),
                const SizedBox(width: AppSizes.paddingS),

                // Tên (có thể rất dài nên cần Expanded)
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

            // ==================== NÚT HỦY / THÔNG BÁO ====================

            // Nếu có thể hủy thì hiển thị countdown và nút hủy
            if (canCancel) ...[
              const SizedBox(height: AppSizes.paddingM),
              const Divider(),
              const SizedBox(height: AppSizes.paddingM),

              // Countdown timer
              Row(
                children: [
                  // Icon đồng hồ
                  const Icon(Icons.access_time, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  // Text hiển thị thời gian còn lại
                  Text(
                    _formatTimeRemaining(timeRemaining),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    ' để hủy',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.paddingS),

              // Nút "Hủy đặt phòng"
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  // Gọi callback onCancel khi click
                  onPressed: onCancel,
                  // Icon
                  icon: const Icon(Icons.cancel_outlined),
                  // Text
                  label: const Text('Hủy đặt phòng'),
                  // Style - màu đỏ
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ]
            // Nếu không thể hủy và status không phải cancelled thì hiển thị thông báo
            else if (booking.status != BookingStatus.cancelled) ...[
              const SizedBox(height: AppSizes.paddingM),
              const Divider(),
              const SizedBox(height: AppSizes.paddingM),

              // Thông báo "Quá hạn hủy"
              Row(
                children: [
                  // Icon
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  // Text
                  const Text(
                    'Đã quá thời gian cho phép hủy (24 giờ)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Helper method để format thời gian còn lại
  ///
  /// Copy từ parent widget để sử dụng trong _BookingCard
  String _formatTimeRemaining(Duration duration) {
    // Nếu còn > 1 giờ thì hiển thị giờ và phút
    if (duration.inHours > 0) {
      return 'Còn ${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    // Nếu còn > 0 phút thì chỉ hiển thị phút
    else if (duration.inMinutes > 0) {
      return 'Còn ${duration.inMinutes}m';
    }
    // Nếu < 1 phút thì hiển thị "Sắp hết hạn"
    else {
      return 'Sắp hết hạn';
    }
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
