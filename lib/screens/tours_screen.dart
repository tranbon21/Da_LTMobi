// Import thư viện Flutter Material Design
import 'package:flutter/material.dart';
// Import các constants của app (màu sắc, kích thước, strings)
import '../utils/constants.dart';

/// Màn hình Danh sách Tour Du lịch
///
/// Màn hình này hiển thị danh sách các tour du lịch
/// Hiện tại đang ở trạng thái TODO - chưa load dữ liệu từ database
///
/// Các tính năng sẽ có:
/// - Tìm kiếm tour theo điểm đến
/// - Lọc tour theo giá, thời gian
/// - Hiển thị danh sách tour với ảnh, giá, rating
/// - Navigate đến màn hình chi tiết tour
class ToursScreen extends StatefulWidget {
  const ToursScreen({super.key});

  @override
  State<ToursScreen> createState() => _ToursScreenState();
}

class _ToursScreenState extends State<ToursScreen> {
  // ==================== CONTROLLERS ====================

  /// Controller cho TextField tìm kiếm
  /// Dùng để lấy giá trị điểm đến mà user nhập vào
  final TextEditingController _searchController = TextEditingController();

  // ==================== STATE ====================

  /// Chuỗi tìm kiếm điểm đến hiện tại
  /// Được cập nhật khi user nhập vào search bar
  String _searchDestination = '';

  // ==================== LIFECYCLE ====================

  /// Hàm dispose - được gọi khi widget bị hủy
  ///
  /// Giải phóng bộ nhớ của controller để tránh memory leak
  @override
  void dispose() {
    // Giải phóng controller tìm kiếm
    _searchController.dispose();
    // Gọi dispose của parent class
    super.dispose();
  }

  // ==================== BUILD UI ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ==================== APP BAR ====================

      // AppBar với tiêu đề "Tour du lịch"
      appBar: AppBar(
        // Tiêu đề lấy từ constants
        title: const Text(AppStrings.tours),
        // Actions ở góc phải
        actions: [
          // Nút filter (TODO: chưa implement)
          IconButton(
            // Icon filter list
            icon: const Icon(Icons.filter_list),
            // Callback khi bấm nút
            onPressed: () {
              // TODO: Implement filter theo giá, thời gian, loại tour
              // Hiển thị thông báo tạm thời
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('TODO: Implement filter')),
              );
            },
          ),
        ],
      ),

      // ==================== BODY ====================

      // Body của màn hình
      body: Column(
        children: [
          // ==================== SEARCH BAR ====================

          // Padding cho search bar
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            // TextField tìm kiếm
            child: TextField(
              // Controller để lấy giá trị
              controller: _searchController,
              // Decoration (giao diện) của TextField
              decoration: InputDecoration(
                // Hint text hiển thị khi chưa nhập
                hintText: AppStrings.searchTours,
                // Icon search ở bên trái
                prefixIcon: const Icon(Icons.search),
                // Icon clear ở bên phải (chỉ hiển thị khi có text)
                suffixIcon: _searchDestination.isNotEmpty
                    ? IconButton(
                        // Icon X để xóa
                        icon: const Icon(Icons.clear),
                        // Callback khi bấm nút clear
                        onPressed: () {
                          // Cập nhật state
                          setState(() {
                            // Xóa text trong controller
                            _searchController.clear();
                            // Reset search destination
                            _searchDestination = '';
                          });
                        },
                      )
                    : null, // Không hiển thị icon nếu chưa có text
              ),
              // Callback khi text thay đổi
              onChanged: (value) {
                // Cập nhật state với giá trị mới
                setState(() {
                  _searchDestination = value;
                });
              },
            ),
          ),

          // ==================== TOURS LIST ====================

          // Expanded để chiếm hết không gian còn lại
          Expanded(
            // Center để căn giữa nội dung
            child: Center(
              // Column chứa icon và text
              child: Column(
                // Căn giữa theo chiều dọc
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ==================== ICON ====================

                  // Icon tour (lớn, màu xám nhạt)
                  Icon(
                    Icons.tour_outlined, // Icon tour outline
                    size: AppSizes.iconXL * 2, // Kích thước lớn (gấp đôi XL)
                    color: AppColors.textHint, // Màu xám nhạt
                  ),

                  const SizedBox(height: AppSizes.paddingM),

                  // ==================== TEXT THÔNG BÁO ====================

                  // Text chính: "Chưa có dữ liệu tour"
                  Text(
                    'Chưa có dữ liệu tour',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary, // Màu text secondary
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingS),

                  // Text phụ: "TODO: Load tours từ database"
                  Text(
                    'TODO: Load tours từ database',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textHint, // Màu hint (xám nhạt hơn)
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
