import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Widget dialog hiển thị thông báo đặt phòng thành công.
/// 
/// Hiển thị icon check màu xanh lá, message chúc mừng,
/// và nút "Hoàn tất" để quay về trang danh sách.
class BookingSuccessDialog extends StatelessWidget {
  /// Tên khách sạn đã đặt
  final String hotelName;
  
  /// Context của màn hình cha (để navigation)
  final BuildContext screenContext;

  const BookingSuccessDialog({
    super.key,
    required this.hotelName,
    required this.screenContext,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon check thành công
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 64,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          
          // Tiêu đề
          const Text(
            'Đặt phòng thành công!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingM),
          
          // Message cảm ơn
          Text(
            'Cảm ơn bạn đã đặt phòng tại $hotelName',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingS),
          
          // Message liên hệ
          const Text(
            'Chúng tôi sẽ liên hệ với bạn sớm nhất!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              // Pop dialog bằng dialog context
              Navigator.of(context).pop();
              
              // Đợi dialog đóng hoàn toàn
              await Future.delayed(AppDurations.dialogCloseDelay);
              
              // Pop hotel detail screen bằng screenContext đã lưu
              if (Navigator.of(screenContext).canPop()) {
                Navigator.of(screenContext).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
            ),
            child: const Text('Hoàn tất'),
          ),
        ),
      ],
    );
  }
}
