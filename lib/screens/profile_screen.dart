import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual user data from your backend/database
    final String userName = 'Người dùng';
    final String userEmail = 'user@example.com';

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implement edit profile
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('')));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSizes.paddingL),

            // Profile picture
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(
                Icons.person,
                size: AppSizes.iconXL * 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),

            // User name
            Text(userName, style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: AppSizes.paddingS),

            // Email
            Text(
              userEmail,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.paddingXL),

            // Profile options
            _ProfileOption(
              icon: Icons.person,
              title: 'Thông tin cá nhân',
              onTap: () {
                // TODO: Navigate to personal info
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('')));
              },
            ),
            _ProfileOption(
              icon: Icons.history,
              title: 'Lịch sử đặt phòng',
              onTap: () {
                // TODO: Navigate to booking history
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('')));
              },
            ),
            _ProfileOption(
              icon: Icons.favorite,
              title: 'Yêu thích',
              onTap: () {
                // TODO: Navigate to favorites
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('')));
              },
            ),
            _ProfileOption(
              icon: Icons.settings,
              title: 'Cài đặt',
              onTap: () {
                // TODO: Navigate to settings
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('')));
              },
            ),
            _ProfileOption(
              icon: Icons.help,
              title: 'Trợ giúp',
              onTap: () {
                // TODO: Navigate to help
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('')));
              },
            ),
            _ProfileOption(
              icon: Icons.info,
              title: 'Về chúng tôi',
              onTap: () {
                // TODO: Navigate to about
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('')));
              },
            ),
            const Divider(height: 1),
            _ProfileOption(
              icon: Icons.logout,
              title: 'Đăng xuất',
              textColor: AppColors.error,
              onTap: () async {
                // TODO: Implement logout functionality
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

                if (confirm == true && context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('')));
                }
              },
            ),
            const SizedBox(height: AppSizes.paddingL),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.textPrimary),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: textColor),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
