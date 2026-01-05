// Import thư viện Flutter Material Design
import 'package:flutter/material.dart';
// Import Firebase Auth để lấy thông tin user hiện tại
import 'package:firebase_auth/firebase_auth.dart';
// Import các constants của app
import '../utils/constants.dart';
// Import FirestoreService để cập nhật thông tin user
import '../services/firestore_service.dart';
// Import UserModel
import '../models/user_model.dart';

/// Màn hình Thông tin cá nhân
///
/// Màn hình này cho phép user xem và chỉnh sửa:
/// - Họ tên
/// - Email (không thể chỉnh sửa)
/// - Số điện thoại
/// - Ngày tạo tài khoản
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  // ==================== SERVICES ====================

  /// Instance của FirestoreService để lấy và cập nhật dữ liệu user
  final FirestoreService _firestoreService = FirestoreService();

  // ==================== CONTROLLERS ====================

  /// Controller cho TextField họ tên
  final TextEditingController _nameController = TextEditingController();

  /// Controller cho TextField số điện thoại
  final TextEditingController _phoneController = TextEditingController();

  // ==================== STATE ====================

  /// Dữ liệu user từ Firestore
  UserModel? _userData;

  /// Biến theo dõi trạng thái loading
  bool _isLoading = true;

  /// Biến theo dõi trạng thái saving
  bool _isSaving = false;

  // ==================== LIFECYCLE ====================

  @override
  void initState() {
    super.initState();
    // Load dữ liệu user khi màn hình được khởi tạo
    _loadUserData();
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ của các controllers
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ==================== METHODS ====================

  /// Load thông tin user từ Firestore
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      // Lấy user hiện tại từ Firebase Auth
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && !currentUser.isAnonymous) {
        // Lấy thông tin chi tiết từ Firestore
        final userData = await _firestoreService.getUser(currentUser.uid);

        if (mounted && userData != null) {
          setState(() {
            _userData = userData;
            // Điền dữ liệu vào các TextFields
            _nameController.text = userData.name;
            _phoneController.text = userData.phoneNumber ?? '';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Lỗi khi load thông tin user: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể tải thông tin: $e')));
      }
    }
  }

  /// Lưu thông tin user đã chỉnh sửa
  Future<void> _saveUserInfo() async {
    // Kiểm tra xem có dữ liệu không
    if (_userData == null) return;

    // Validate input
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập họ tên')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Tạo UserModel mới với thông tin đã cập nhật
      final updatedUser = _userData!.copyWith(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );

      // Cập nhật vào Firestore
      await _firestoreService.updateUser(updatedUser);

      if (mounted) {
        setState(() {
          _userData = updatedUser;
          _isSaving = false;
        });

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã lưu thông tin')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lưu thất bại: $e')));
      }
    }
  }

  // ==================== BUILD UI ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar với tiêu đề "Thông tin cá nhân"
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        // Nút lưu ở góc phải
        actions: [
          if (!_isLoading && _userData != null)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveUserInfo,
            ),
        ],
      ),

      // Body của màn hình
      body: _isLoading
          ? // Hiển thị loading indicator khi đang load
            const Center(child: CircularProgressIndicator())
          : _userData == null
          ? // Hiển thị thông báo lỗi nếu không có dữ liệu
            const Center(child: Text('Không thể tải thông tin người dùng'))
          : // Hiển thị form thông tin
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================== AVATAR ====================

                  // Avatar ở giữa
                  Center(
                    child: Stack(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.primary,
                          ),
                        ),
                        // Nút chỉnh sửa avatar (TODO)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                // TODO: Implement change avatar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tính năng đang phát triển'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingXL),

                  // ==================== FORM FIELDS ====================

                  // Label "Họ tên"
                  const Text(
                    'Họ tên',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingS),

                  // TextField nhập họ tên
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập họ tên',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !_isSaving,
                  ),

                  const SizedBox(height: AppSizes.paddingL),

                  // Label "Email"
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingS),

                  // TextField hiển thị email (không thể chỉnh sửa)
                  TextField(
                    controller: TextEditingController(text: _userData!.email),
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                      // Thêm suffix icon để chỉ rõ không thể chỉnh sửa
                      suffixIcon: Icon(Icons.lock_outline, size: 20),
                    ),
                    enabled: false, // Không cho phép chỉnh sửa email
                  ),

                  const SizedBox(height: AppSizes.paddingL),

                  // Label "Số điện thoại"
                  const Text(
                    'Số điện thoại',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingS),

                  // TextField nhập số điện thoại
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập số điện thoại',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    enabled: !_isSaving,
                  ),

                  const SizedBox(height: AppSizes.paddingL),

                  // ==================== THÔNG TIN BỔ SUNG ====================

                  // Divider
                  const Divider(),
                  const SizedBox(height: AppSizes.paddingL),

                  // Label "Thông tin tài khoản"
                  const Text(
                    'Thông tin tài khoản',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  // Ngày tạo tài khoản
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: 'Ngày tạo tài khoản',
                    value: _formatDate(_userData!.createdAt),
                  ),

                  const SizedBox(height: AppSizes.paddingM),

                  // User ID
                  _InfoRow(
                    icon: Icons.fingerprint,
                    label: 'ID người dùng',
                    value: _userData!.id,
                  ),
                ],
              ),
            ),
    );
  }

  /// Format ngày tháng thành chuỗi dễ đọc
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }
}

/// Widget _InfoRow - Hiển thị một dòng thông tin (read-only)
class _InfoRow extends StatelessWidget {
  /// Icon hiển thị bên trái
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
        Icon(icon, size: 20, color: AppColors.textSecondary),
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
