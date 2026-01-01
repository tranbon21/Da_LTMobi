import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Dialog lọc theo giá tối đa cho danh sách khách sạn.
/// 
/// Chức năng:
/// - TextField nhập giá tối đa (chỉ nhận số)
/// - Icon X để xóa text trong TextField
/// - Validation: giá phải > 0
/// - Nút "Hủy" (nền trắng, viền xanh, text đen)
/// - Nút "Áp dụng" (nền xanh, text trắng)
/// 
/// Trả về:
/// - `double?`: giá tối đa mới khi bấm "Áp dụng"
/// - `null`: khi bấm "Hủy", để trống và bấm "Áp dụng", hoặc tap outside
class PriceFilterDialog extends StatefulWidget {
  /// Giá tối đa hiện tại (để pre-fill vào TextField)
  final double? currentMaxPrice;

  const PriceFilterDialog({
    super.key,
    this.currentMaxPrice,
  });

  @override
  State<PriceFilterDialog> createState() => _PriceFilterDialogState();
}

class _PriceFilterDialogState extends State<PriceFilterDialog> {
  late final TextEditingController _priceController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    // Pre-fill giá hiện tại nếu có
    _priceController = TextEditingController(
      text: widget.currentMaxPrice?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  /// Áp dụng filter
  void _applyFilter() {
    final priceText = _priceController.text.trim();
    
    if (priceText.isNotEmpty) {
      final price = double.tryParse(priceText);
      if (price != null && price > 0) {
        // Giá hợp lệ - trả về giá mới
        Navigator.pop(context, price);
      } else {
        // Giá không hợp lệ - hiển thị error
        setState(() {
          _errorText = 'Vui lòng nhập giá hợp lệ (số > 0)';
        });
      }
    } else {
      // Để trống = xóa filter - trả về null
      Navigator.pop(context, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.attach_money, color: AppColors.primary),
          SizedBox(width: AppSizes.paddingS),
          Text('Lọc theo giá'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Giá tối đa (VNĐ)',
              hintText: 'Ví dụ: 900000',
              prefixIcon: const Icon(Icons.money),
              helperText: 'Nhập giá tối đa để lọc khách sạn',
              errorText: _errorText,
              // Icon X để xóa text
              suffixIcon: _priceController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _priceController.clear();
                          _errorText = null;
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              // Clear error và update UI để show/hide icon X
              setState(() {
                if (_errorText != null) {
                  _errorText = null;
                }
              });
            },
          ),
        ],
      ),
      actions: [
        // Nút Hủy - nền trắng, viền xanh, text đen
        SizedBox(
          width: 100,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Hủy'),
          ),
        ),
        const SizedBox(width: AppSizes.paddingS),
        // Nút Áp dụng - nền xanh, text trắng
        SizedBox(
          width: 100,
          child: ElevatedButton(
            onPressed: _applyFilter,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Áp dụng'),
          ),
        ),
      ],
    );
  }
}
