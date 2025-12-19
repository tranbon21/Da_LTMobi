import 'package:flutter/material.dart';
import '../utils/constants.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Load bookings from your database
    // For now, showing empty state

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.bookings)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_online_outlined,
              size: AppSizes.iconXL * 2,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              'Chưa có đặt phòng nào',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              'TODO: Load bookings từ database',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}
