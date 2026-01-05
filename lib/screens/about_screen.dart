// Import thư viện Flutter Material Design
import 'package:flutter/material.dart';
// Import các constants của app
import '../utils/constants.dart';

/// Màn hình Về chúng tôi
///
/// Màn hình này hiển thị thông tin về ứng dụng,
/// đội ngũ phát triển và các thông tin liên quan
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar với tiêu đề "Về chúng tôi"
      appBar: AppBar(title: const Text('Về chúng tôi')),

      // Body của màn hình
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ==================== LOGO ====================

            // Logo ứng dụng
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hotel,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),

            // ==================== TÊN ỨNG DỤNG ====================

            // Tên ứng dụng
            const Text(
              AppStrings.appName,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.paddingS),

            // Phiên bản
            Text(
              'Phiên bản 1.0.0',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: AppSizes.paddingXL),

            // ==================== MÔ TẢ ====================
            const Divider(),
            const SizedBox(height: AppSizes.paddingL),

            // Tiêu đề
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Giới thiệu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Mô tả ứng dụng
            const Text(
              'Ứng dụng đặt phòng khách sạn giúp bạn dễ dàng tìm kiếm và đặt phòng '
              'tại các khách sạn trên toàn quốc. Với giao diện thân thiện và tính năng '
              'đa dạng, chúng tôi cam kết mang đến trải nghiệm tốt nhất cho người dùng.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: AppSizes.paddingXL),

            // ==================== TÍNH NĂNG ====================
            const Divider(),
            const SizedBox(height: AppSizes.paddingL),

            // Tiêu đề
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tính năng chính',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Danh sách tính năng
            _FeatureItem(
              icon: Icons.search,
              title: 'Tìm kiếm khách sạn',
              description: 'Tìm kiếm khách sạn theo vị trí, giá cả và đánh giá',
            ),
            _FeatureItem(
              icon: Icons.hotel,
              title: 'Đặt phòng dễ dàng',
              description: 'Quy trình đặt phòng đơn giản và nhanh chóng',
            ),
            _FeatureItem(
              icon: Icons.history,
              title: 'Lịch sử đặt phòng',
              description: 'Theo dõi và quản lý các booking của bạn',
            ),
            _FeatureItem(
              icon: Icons.person,
              title: 'Quản lý tài khoản',
              description: 'Cập nhật thông tin cá nhân và cài đặt',
            ),

            const SizedBox(height: AppSizes.paddingXL),

            // ==================== ĐỘI NGŨ ====================
            const Divider(),
            const SizedBox(height: AppSizes.paddingL),

            // Tiêu đề
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Đội ngũ phát triển',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Thông tin đội ngũ
            const Text(
              'Ứng dụng được phát triển bởi nhóm sinh viên Khoa Công nghệ Thông tin, '
              'với mục tiêu tạo ra một nền tảng đặt phòng khách sạn tiện lợi và hiện đại.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: AppSizes.paddingXL),

            // ==================== LIÊN HỆ ====================
            const Divider(),
            const SizedBox(height: AppSizes.paddingL),

            // Tiêu đề
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Liên hệ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Email
            _ContactItem(icon: Icons.email, text: 'support@bookinghotel.com'),
            const SizedBox(height: AppSizes.paddingM),

            // Website
            _ContactItem(icon: Icons.language, text: 'www.bookinghotel.com'),
            const SizedBox(height: AppSizes.paddingM),

            // Địa chỉ
            _ContactItem(
              icon: Icons.location_on,
              text: 'TP. Hồ Chí Minh, Việt Nam',
            ),
            const SizedBox(height: AppSizes.paddingXL),

            // ==================== COPYRIGHT ====================
            const Divider(),
            const SizedBox(height: AppSizes.paddingL),

            // Copyright
            Text(
              '© 2026 ${AppStrings.appName}. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingS),

            // Made with love
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Made with ',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const Icon(Icons.favorite, size: 14, color: Colors.red),
                Text(
                  ' in Vietnam',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget _FeatureItem - Hiển thị một tính năng
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: AppSizes.paddingM),

          // Title và Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                // Description
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget _ContactItem - Hiển thị một thông tin liên hệ
class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSizes.paddingM),

        // Text
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
