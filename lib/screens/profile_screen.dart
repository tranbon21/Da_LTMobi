// Import thư viện Flutter Material Design
import 'package:flutter/material.dart';
// Import Firebase Auth để lấy thông tin user hiện tại
import 'package:firebase_auth/firebase_auth.dart';
// Import các constants của app (màu sắc, kích thước, strings)
import '../utils/constants.dart';
// Import AuthService để xử lý đăng xuất
import '../services/auth_service.dart';
// Import FirestoreService để lấy thông tin user từ database
import '../services/firestore_service.dart';
// Import UserModel để quản lý dữ liệu user
import '../models/user_model.dart';
// Import các màn hình con
import 'personal_info_screen.dart';
import 'booking_history_screen.dart';
import 'help_screen.dart';
import 'about_screen.dart';
import 'create_hotel_post_screen.dart';
import 'create_tour_post_screen.dart';
import 'my_promotions_screen.dart';


/// Màn hình Tài khoản (Profile Screen)
///
/// Màn hình này hiển thị:
/// - Thông tin cá nhân của user (tên, email, avatar)
/// - Các tùy chọn: Thông tin cá nhân, Lịch sử đặt phòng, Trợ giúp, Về chúng tôi
/// - Nút đăng xuất
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ==================== SERVICES ====================

  /// Instance của FirestoreService để lấy dữ liệu user từ Firestore
  final FirestoreService _firestoreService = FirestoreService();

  /// Instance của AuthService để xử lý đăng xuất
  final AuthService _authService = AuthService();

  // ==================== STATE ====================

  /// Dữ liệu user từ Firestore (null nếu chưa load hoặc là guest)
  UserModel? _userData;

  /// Biến theo dõi trạng thái loading
  bool _isLoading = true;

  // ==================== LIFECYCLE ====================

  @override
  void initState() {
    super.initState();
    // Load dữ liệu user khi màn hình được khởi tạo
    _loadUserData();
  }

  // ==================== METHODS ====================

  /// Load thông tin user từ Firebase/Firestore
  ///
  /// Hàm này sẽ:
  /// 1. Lấy user hiện tại từ FirebaseAuth
  /// 2. Kiểm tra xem user có phải là guest không
  /// 3. Nếu không phải guest, lấy thông tin chi tiết từ Firestore
  Future<void> _loadUserData() async {
    // Bắt đầu loading
    setState(() => _isLoading = true);

    try {
      // Lấy user hiện tại từ Firebase Auth
      final currentUser = FirebaseAuth.instance.currentUser;

      // Nếu user đã đăng nhập
      if (currentUser != null) {
        // Kiểm tra xem có phải là guest không
        if (!currentUser.isAnonymous) {
          // Không phải guest - lấy thông tin từ Firestore
          final userData = await _firestoreService.getUser(currentUser.uid);

          // Cập nhật state với dữ liệu user
          if (mounted) {
            setState(() {
              _userData = userData;
              _isLoading = false;
            });
          }
        } else {
          // Là guest - không có dữ liệu trong Firestore
          if (mounted) {
            setState(() {
              _userData = null;
              _isLoading = false;
            });
          }
        }
      } else {
        // Chưa đăng nhập
        if (mounted) {
          setState(() {
            _userData = null;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Có lỗi khi load dữ liệu
      print('Lỗi khi load thông tin user: $e');
      if (mounted) {
        setState(() {
          _userData = null;
          _isLoading = false;
        });
      }
    }
  }

  /// Xử lý đăng xuất
  ///
  /// Hiển thị dialog xác nhận, sau đó đăng xuất khỏi Firebase Auth
  Future<void> _handleLogout() async {
    // Hiển thị dialog xác nhận đăng xuất
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        // Tiêu đề dialog
        title: const Text('Xác nhận đăng xuất'),
        // Nội dung dialog
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        // Các nút hành động
        actions: [
          // Nút "Hủy"
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          // Nút "Đăng xuất"
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    // Nếu user không xác nhận hoặc widget đã bị dispose thì return
    if (confirm != true || !mounted) return;

    try {
      // Gọi AuthService để đăng xuất
      await _authService.signOut();

      // Hiển thị thông báo đăng xuất thành công
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã đăng xuất')));
      }
      // Lưu ý: AuthGate sẽ tự động chuyển về LoginScreen
      // khi phát hiện user đã đăng xuất
    } catch (e) {
      // Có lỗi khi đăng xuất
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đăng xuất thất bại: $e')));
      }
    }
  }

  // ==================== BUILD UI ====================

  @override
  Widget build(BuildContext context) {
    // Lấy user hiện tại từ Firebase Auth
    final currentUser = FirebaseAuth.instance.currentUser;

    // Kiểm tra xem user có phải là guest không
    final isGuest = currentUser?.isAnonymous ?? false;

    // Xác định tên hiển thị
    String displayName;
    if (isGuest) {
      // Nếu là guest
      displayName = 'Khách';
    } else if (_userData != null) {
      // Nếu có dữ liệu từ Firestore
      displayName = _userData!.name;
    } else {
      // Fallback
      displayName = currentUser?.displayName ?? 'Người dùng';
    }

    // Xác định email hiển thị
    String displayEmail;
    if (isGuest) {
      // Nếu là guest
      displayEmail = 'Chế độ khách';
    } else if (_userData != null) {
      // Nếu có dữ liệu từ Firestore
      displayEmail = _userData!.email;
    } else {
      // Fallback
      displayEmail = currentUser?.email ?? 'user@example.com';
    }

    return Scaffold(
      // AppBar với tiêu đề "Tài khoản"
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        // Nút chỉnh sửa profile (chỉ hiển thị nếu không phải guest)
        actions: [
          if (!isGuest)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Navigate đến màn hình Personal Info
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PersonalInfoScreen(),
                  ),
                ).then((_) {
                  // Reload dữ liệu khi quay lại từ Personal Info
                  _loadUserData();
                });
              },
            ),
        ],
      ),

      // Body của màn hình
      body: _isLoading
          ? // Hiển thị loading indicator khi đang load dữ liệu
            const Center(child: CircularProgressIndicator())
          : // Hiển thị nội dung khi đã load xong
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: AppSizes.paddingL),

                  // ==================== AVATAR ====================

                  // Avatar của user
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Icon(
                      // Icon khác nhau cho guest và user thông thường
                      isGuest ? Icons.person_outline : Icons.person,
                      size: AppSizes.iconXL * 2,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  // ==================== TÊN NGƯỜI DÙNG ====================

                  // Tên người dùng
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: AppSizes.paddingS),

                  // ==================== EMAIL ====================

                  // Email hoặc "Chế độ khách"
                  Text(
                    displayEmail,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  // ==================== ROLE BADGE ====================

                  // Hiển thị badge role cho tất cả user
                  const SizedBox(height: AppSizes.paddingS),

                  // Badge hiển thị role của user
                  if (isGuest)
                    // Badge cho guest
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Text(
                        'Chế độ khách',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else if (_userData != null)
                    // Badge cho registered user (hiển thị role)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        // Màu khác nhau cho từng role
                        color: _userData!.role == UserRole.hotelOwner
                            ? Colors.orange.shade100
                            : _userData!.role == UserRole.tourOperator
                            ? Colors.purple.shade100
                            : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _userData!.role == UserRole.hotelOwner
                              ? Colors.orange.shade300
                              : _userData!.role == UserRole.tourOperator
                              ? Colors.purple.shade300
                              : Colors.blue.shade300,
                        ),
                      ),
                      child: Text(
                        // Hiển thị tên role bằng tiếng Việt
                        _userData!.role.displayName,
                        style: TextStyle(
                          color: _userData!.role == UserRole.hotelOwner
                              ? Colors.orange.shade700
                              : _userData!.role == UserRole.tourOperator
                              ? Colors.purple.shade700
                              : Colors.blue.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  const SizedBox(height: AppSizes.paddingXL),

                  // ==================== CÁC TÙY CHỌN ====================

                  // ==================== OPTIONS CHO HOTEL OWNER ====================

                  // Nút "Đăng bài khách sạn" - chỉ hiển thị cho hotel_owner
                  if (!isGuest && _userData?.role == UserRole.hotelOwner)
                    _ProfileOption(
                      icon: Icons.hotel,
                      title: 'Đăng bài khách sạn',
                      onTap: () {
                        // Navigate đến màn hình CreateHotelPostScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateHotelPostScreen(),
                          ),
                        );
                      },
                    ),

                  // ==================== OPTIONS CHO TOUR OPERATOR ====================

                  // Nút "Đăng bài tour" - chỉ hiển thị cho tour_operator
                  if (!isGuest && _userData?.role == UserRole.tourOperator)
                    _ProfileOption(
                      icon: Icons.tour,
                      title: 'Đăng bài tour du lịch',
                      onTap: () {
                        // Navigate đến màn hình CreateTourPostScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateTourPostScreen(),
                          ),
                        );
                      },
                    ),

                  // ==================== OPTIONS CHUNG ====================

                  // Thông tin cá nhân (ẩn nếu là guest)
                  if (!isGuest)
                    _ProfileOption(
                      icon: Icons.person,
                      title: 'Thông tin cá nhân',
                      onTap: () {
                        // Navigate đến màn hình Personal Info
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PersonalInfoScreen(),
                          ),
                        ).then((_) {
                          // Reload dữ liệu khi quay lại
                          _loadUserData();
                        });
                      },
                    ),

                  // Lịch sử đặt phòng (ẩn nếu là guest)
                  if (!isGuest)
                    _ProfileOption(
                      icon: Icons.history,
                      title: 'Lịch sử đặt phòng',
                      onTap: () {
                        // Navigate đến màn hình Booking History
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BookingHistoryScreen(),
                          ),
                        );
                      },
                    ),

                  // ==================== ƯU ĐÃI CỦA TÔI ====================

                  if (!isGuest)
                    _ProfileOption(
                      icon: Icons.local_offer_outlined,
                      title: 'Ưu đãi của tôi',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyPromotionsScreen(),
                          ),
                        );
                      },
                    ), 

                  // Trợ giúp
                  _ProfileOption(
                    icon: Icons.help,
                    title: 'Trợ giúp',
                    onTap: () {
                      // Navigate đến màn hình Help
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpScreen(),
                        ),
                      );
                    },
                  ),

                  // Về chúng tôi
                  _ProfileOption(
                    icon: Icons.info,
                    title: 'Về chúng tôi',
                    onTap: () {
                      // Navigate đến màn hình About
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutScreen(),
                        ),
                      );
                    },
                  ),

                  // Divider trước nút đăng xuất
                  const Divider(height: 1),

                  // ==================== NÚT ĐĂNG XUẤT ====================

                  // Nút đăng xuất (màu đỏ)
                  _ProfileOption(
                    icon: Icons.logout,
                    title: 'Đăng xuất',
                    textColor: AppColors.error,
                    onTap: _handleLogout,
                  ),

                  const SizedBox(height: AppSizes.paddingL),
                ],
              ),
            ),
    );
  }
}

/// Widget _ProfileOption - Một dòng option trong profile
///
/// Widget này hiển thị:
/// - Icon bên trái
/// - Tiêu đề
/// - Icon mũi tên bên phải
/// - Có thể tùy chỉnh màu text (dùng cho nút đăng xuất màu đỏ)
class _ProfileOption extends StatelessWidget {
  /// Icon hiển thị bên trái
  final IconData icon;

  /// Tiêu đề của option
  final String title;

  /// Callback khi tap vào option
  final VoidCallback onTap;

  /// Màu của text và icon (optional, mặc định là màu chữ primary)
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
      // Icon bên trái
      leading: Icon(icon, color: textColor ?? AppColors.textPrimary),

      // Tiêu đề
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: textColor),
      ),

      // Icon mũi tên bên phải
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),

      // Callback khi tap
      onTap: onTap,
    );
  }
}
