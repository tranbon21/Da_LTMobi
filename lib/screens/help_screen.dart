// Import thư viện Flutter Material Design
import 'package:flutter/material.dart';
// Import các constants của app
import '../utils/constants.dart';

/// Màn hình Trợ giúp
///
/// Màn hình này cung cấp các câu hỏi thường gặp (FAQ)
/// và hướng dẫn sử dụng ứng dụng
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar với tiêu đề "Trợ giúp"
      appBar: AppBar(title: const Text('Trợ giúp')),

      // Body của màn hình
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        children: [
          // ==================== GIỚI THIỆU ====================

          // Icon
          const Center(
            child: Icon(Icons.help_outline, size: 80, color: AppColors.primary),
          ),
          const SizedBox(height: AppSizes.paddingL),

          // Tiêu đề
          const Center(
            child: Text(
              'Câu hỏi thường gặp',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: AppSizes.paddingXL),

          // ==================== FAQ ====================

          // FAQ 1: Làm thế nào để đặt phòng?
          _FAQItem(
            question: 'Làm thế nào để đặt phòng?',
            answer:
                '1. Vào tab "Khách sạn"\n'
                '2. Chọn khách sạn bạn muốn đặt\n'
                '3. Chọn ngày nhận và trả phòng\n'
                '4. Chọn số phòng và số khách\n'
                '5. Nhập thông tin liên hệ\n'
                '6. Bấm "Đặt phòng" và xác nhận thanh toán',
          ),

          // FAQ 2: Tôi có thể hủy đặt phòng không?
          _FAQItem(
            question: 'Tôi có thể hủy đặt phòng không?',
            answer:
                'Hiện tại tính năng hủy đặt phòng đang được phát triển. '
                'Vui lòng liên hệ với chúng tôi qua email hoặc hotline để được hỗ trợ.',
          ),

          // FAQ 3: Làm thế nào để xem lịch sử đặt phòng?
          _FAQItem(
            question: 'Làm thế nào để xem lịch sử đặt phòng?',
            answer:
                '1. Vào tab "Tài khoản"\n'
                '2. Chọn "Lịch sử đặt phòng"\n'
                '3. Bạn sẽ thấy danh sách tất cả các booking đã đặt',
          ),

          // FAQ 4: Chế độ khách là gì?
          _FAQItem(
            question: 'Chế độ khách là gì?',
            answer:
                'Chế độ khách cho phép bạn xem thông tin khách sạn mà không cần đăng ký tài khoản. '
                'Tuy nhiên, bạn cần đăng nhập bằng tài khoản để có thể đặt phòng.',
          ),

          // FAQ 5: Làm thế nào để chỉnh sửa thông tin cá nhân?
          _FAQItem(
            question: 'Làm thế nào để chỉnh sửa thông tin cá nhân?',
            answer:
                '1. Vào tab "Tài khoản"\n'
                '2. Chọn "Thông tin cá nhân"\n'
                '3. Chỉnh sửa họ tên hoặc số điện thoại\n'
                '4. Bấm icon "Lưu" ở góc trên bên phải',
          ),

          const SizedBox(height: AppSizes.paddingXL),

          // ==================== LIÊN HỆ ====================
          const Divider(),
          const SizedBox(height: AppSizes.paddingL),

          // Tiêu đề
          const Text(
            'Liên hệ hỗ trợ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.paddingM),

          // Email
          _ContactRow(
            icon: Icons.email,
            label: 'Email',
            value: 'support@bookinghotel.com',
          ),
          const SizedBox(height: AppSizes.paddingM),

          // Hotline
          _ContactRow(icon: Icons.phone, label: 'Hotline', value: '1900 xxxx'),
          const SizedBox(height: AppSizes.paddingM),

          // Giờ làm việc
          _ContactRow(
            icon: Icons.access_time,
            label: 'Giờ làm việc',
            value: '8:00 - 22:00 (Hàng ngày)',
          ),
        ],
      ),
    );
  }
}

/// Widget _FAQItem - Hiển thị một câu hỏi và câu trả lời
class _FAQItem extends StatelessWidget {
  /// Câu hỏi
  final String question;

  /// Câu trả lời
  final String answer;

  const _FAQItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: ExpansionTile(
        // Tiêu đề (câu hỏi)
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        // Icon
        leading: const Icon(Icons.help_outline, color: AppColors.primary),
        // Nội dung (câu trả lời)
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget _ContactRow - Hiển thị một dòng thông tin liên hệ
class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon
        Icon(icon, size: 24, color: AppColors.primary),
        const SizedBox(width: AppSizes.paddingM),

        // Label và Value
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),

              // Value
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
