import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Widget counter tile với icon, title, subtitle và buttons +/-.
/// 
/// Dùng để select số phòng, số người lớn, số trẻ em, v.v.
class CounterTile extends StatelessWidget {
  /// Icon hiển thị bên trái
  final IconData icon;
  
  /// Tiêu đề chính
  final String title;
  
  /// Mô tả phụ (hiển thị dưới title)
  final String subtitle;
  
  /// Giá trị hiện tại
  final int value;
  
  /// Callback khi bấm nút trừ (-)
  final VoidCallback? onRemove;
  
  /// Callback khi bấm nút cộng (+)
  final VoidCallback? onAdd;

  const CounterTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.onRemove,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nút trừ (-)
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: onRemove,
            color: onRemove != null ? AppColors.primary : AppColors.textHint,
          ),
          
          // Giá trị hiện tại
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingS,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Text(
              value.toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
          ),
          
          // Nút cộng (+)
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: onAdd,
            color: onAdd != null ? AppColors.primary : AppColors.textHint,
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        side: const BorderSide(color: AppColors.border),
      ),
    );
  }
}
