// Import thư viện Flutter Material Design
import 'package:flutter/material.dart';
// Import AuthService để xử lý đăng nhập
import '../services/auth_service.dart';
// Import UserModel để quản lý thông tin người dùng
import '../models/user_model.dart';
// Import màn hình đăng ký
import 'register_screen.dart';

/// Màn hình đăng nhập
///
/// Màn hình này cung cấp 3 tùy chọn cho người dùng:
/// 1. Đăng nhập với email và password
/// 2. Đăng ký tài khoản mới
/// 3. Đăng nhập với tư cách khách (guest mode)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ==================== SERVICES ====================

  /// Instance của AuthService để xử lý các thao tác xác thực
  final AuthService _authService = AuthService();

  // ==================== CONTROLLERS ====================

  /// Controller cho TextField email
  /// Dùng để lấy giá trị email mà user nhập vào
  final TextEditingController _emailController = TextEditingController();

  /// Controller cho TextField password
  /// Dùng để lấy giá trị password mà user nhập vào
  final TextEditingController _passwordController = TextEditingController();

  // ==================== STATE ====================

  /// Biến theo dõi trạng thái loading
  /// true = đang xử lý đăng nhập, false = không loading
  bool _isLoading = false;

  /// Thông báo lỗi (nếu có)
  /// null = không có lỗi, String = thông báo lỗi
  String? _errorMessage;

  // ==================== LIFECYCLE ====================

  /// Hàm dispose - được gọi khi widget bị hủy
  ///
  /// Giải phóng bộ nhớ của các controllers để tránh memory leak
  @override
  void dispose() {
    // Giải phóng controller email
    _emailController.dispose();
    // Giải phóng controller password
    _passwordController.dispose();
    // Gọi dispose của parent class
    super.dispose();
  }

  // ==================== METHODS ====================

  /// Xử lý đăng nhập với email và password
  ///
  /// Hàm này sẽ:
  /// 1. Validate input (email và password không rỗng)
  /// 2. Gọi AuthService để đăng nhập
  /// 3. Hiển thị thông báo thành công hoặc lỗi
  /// 4. AuthGate sẽ tự động chuyển sang HomeScreen nếu đăng nhập thành công
  Future<void> _login() async {
    // Bắt đầu loading - cập nhật UI
    setState(() {
      _isLoading = true; // Hiển thị loading indicator
      _errorMessage = null; // Xóa thông báo lỗi cũ (nếu có)
    });

    try {
      // Gọi AuthService để đăng nhập với email và password
      // trim() để xóa khoảng trắng thừa ở đầu/cuối
      final UserModel? user = await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Kiểm tra kết quả đăng nhập
      if (user != null) {
        // Đăng nhập thành công
        // Kiểm tra xem widget còn mounted (chưa bị dispose) không
        if (mounted) {
          // Hiển thị thông báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng nhập thành công!')),
          );
          // Lưu ý: Không cần Navigator.push vì AuthGate sẽ tự động
          // chuyển sang HomeScreen khi phát hiện user đã đăng nhập
        }
      } else {
        // Đăng nhập thất bại (user == null)
        if (mounted) {
          setState(() {
            _errorMessage =
                'Đăng nhập thất bại. Vui lòng kiểm tra email và mật khẩu.';
          });
        }
      }
    } catch (e) {
      // Có lỗi xảy ra (network error, wrong password, etc.)
      if (mounted) {
        setState(() {
          // Hiển thị thông báo lỗi
          _errorMessage = 'Có lỗi xảy ra: $e';
        });
      }
    } finally {
      // Kết thúc loading - cập nhật UI
      if (mounted) {
        setState(() {
          _isLoading = false; // Ẩn loading indicator
        });
      }
    }
  }

  /// Xử lý đăng nhập với tư cách khách (guest mode)
  ///
  /// Hàm này sẽ:
  /// 1. Gọi AuthService để đăng nhập anonymous
  /// 2. AuthGate sẽ tự động chuyển sang HomeScreen
  /// 3. User khách sẽ có một số hạn chế (không thể đặt phòng)
  Future<void> _loginAsGuest() async {
    // Bắt đầu loading
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Gọi AuthService để đăng nhập với tư cách khách
      await _authService.signInAsGuest();

      // Đăng nhập thành công
      if (mounted) {
        // Hiển thị thông báo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập với tư cách khách')),
        );
        // AuthGate sẽ tự động chuyển sang HomeScreen
      }
    } catch (e) {
      // Có lỗi xảy ra
      if (mounted) {
        setState(() {
          _errorMessage = 'Không thể đăng nhập với tư cách khách: $e';
        });
      }
    } finally {
      // Kết thúc loading
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ==================== BUILD UI ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar với tiêu đề "Đăng nhập"
      appBar: AppBar(
        title: const Text('Đăng nhập'),
        // Tự động hiển thị nút back nếu có màn hình trước đó
        automaticallyImplyLeading: false,
      ),

      // Body của màn hình
      body: Padding(
        // Padding xung quanh toàn bộ nội dung
        padding: const EdgeInsets.all(16.0),

        // SingleChildScrollView để có thể scroll khi bàn phím hiện lên
        child: SingleChildScrollView(
          child: Column(
            // Căn trái các widget con
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Khoảng trống phía trên
              const SizedBox(height: 40),

              // Logo hoặc tiêu đề app (optional)
              const Icon(Icons.hotel, size: 80, color: Colors.blue),
              const SizedBox(height: 20),

              // Tiêu đề chào mừng
              const Text(
                'Chào mừng!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Mô tả
              const Text(
                'Đăng nhập để tiếp tục',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // ==================== THÔNG BÁO LỖI ====================

              // Hiển thị thông báo lỗi nếu có
              if (_errorMessage != null) ...[
                // Container chứa thông báo lỗi
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ==================== FORM ĐĂNG NHẬP ====================

              // TextField nhập email
              TextField(
                controller: _emailController, // Controller để lấy giá trị
                decoration: const InputDecoration(
                  labelText: 'Email', // Label hiển thị
                  hintText: 'Nhập email của bạn', // Hint text
                  prefixIcon: Icon(Icons.email), // Icon email
                  border: OutlineInputBorder(), // Border xung quanh
                ),
                keyboardType: TextInputType.emailAddress, // Bàn phím email
                enabled: !_isLoading, // Disable khi đang loading
              ),
              const SizedBox(height: 16),

              // TextField nhập password
              TextField(
                controller: _passwordController, // Controller để lấy giá trị
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu', // Label hiển thị
                  hintText: 'Nhập mật khẩu', // Hint text
                  prefixIcon: Icon(Icons.lock), // Icon khóa
                  border: OutlineInputBorder(), // Border xung quanh
                ),
                obscureText: true, // Ẩn text (hiển thị dấu chấm)
                enabled: !_isLoading, // Disable khi đang loading
              ),
              const SizedBox(height: 24),

              // ==================== NÚT ĐĂNG NHẬP ====================

              // Nút đăng nhập hoặc loading indicator
              _isLoading
                  ? const Center(
                      // Hiển thị loading indicator khi đang xử lý
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      // Gọi hàm _login khi bấm nút
                      onPressed: _login,
                      // Style cho nút
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Đăng nhập',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

              const SizedBox(height: 16),

              // ==================== NÚT ĐĂNG KÝ ====================

              // Nút chuyển sang màn hình đăng ký
              TextButton(
                onPressed: _isLoading
                    ? null // Disable khi đang loading
                    : () {
                        // Navigate đến màn hình đăng ký
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                child: const Text(
                  'Chưa có tài khoản? Đăng ký',
                  style: TextStyle(fontSize: 14),
                ),
              ),

              // ==================== DIVIDER ====================
              const SizedBox(height: 20),

              // Divider với text "HOẶC"
              Row(
                children: [
                  // Đường kẻ bên trái
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                  // Text "HOẶC"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'HOẶC',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Đường kẻ bên phải
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                ],
              ),

              const SizedBox(height: 20),

              // ==================== NÚT ĐĂNG NHẬP KHÁCH ====================

              // Nút đăng nhập với tư cách khách
              OutlinedButton.icon(
                onPressed: _isLoading
                    ? null // Disable khi đang loading
                    : _loginAsGuest, // Gọi hàm đăng nhập khách
                // Icon người dùng
                icon: const Icon(Icons.person_outline),
                // Text trên nút
                label: const Text(
                  'Đăng nhập với tư cách khách',
                  style: TextStyle(fontSize: 16),
                ),
                // Style cho nút
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                ),
              ),

              const SizedBox(height: 16),

              // ==================== GHI CHÚ KHÁCH ====================

              // Ghi chú về chế độ khách
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    // Icon thông tin
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    // Text ghi chú
                    Expanded(
                      child: Text(
                        'Lưu ý: Khách không thể đặt phòng. Vui lòng đăng ký để sử dụng đầy đủ tính năng.',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
