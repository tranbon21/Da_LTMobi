// Import thư viện Flutter Material Design
import 'package:flutter/material.dart';
// Import AuthService để xử lý đăng ký
import '../services/auth_service.dart';
// Import EasyLoading để hiển thị loading indicator đẹp
import 'package:flutter_easyloading/flutter_easyloading.dart';

/// Màn hình đăng ký tài khoản mới
///
/// Màn hình này cho phép người dùng tạo tài khoản mới với:
/// - Họ tên
/// - Email
/// - Mật khẩu
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ==================== FORM KEY ====================

  /// Key để quản lý và validate form
  /// Dùng để kiểm tra tất cả các field có hợp lệ không trước khi submit
  final _formKey = GlobalKey<FormState>();

  // ==================== CONTROLLERS ====================

  /// Controller cho TextField họ tên
  final _nameCtrl = TextEditingController();

  /// Controller cho TextField email
  final _emailCtrl = TextEditingController();

  /// Controller cho TextField mật khẩu
  final _passwordCtrl = TextEditingController();

  // ==================== STATE ====================

  /// Biến theo dõi trạng thái loading
  /// true = đang xử lý đăng ký, false = không loading
  bool _loading = false;

  /// Thông báo lỗi (nếu có)
  /// null = không có lỗi, String = thông báo lỗi
  String? _error;

  // ==================== LIFECYCLE ====================

  /// Hàm dispose - được gọi khi widget bị hủy
  ///
  /// Giải phóng bộ nhớ của các controllers để tránh memory leak
  @override
  void dispose() {
    // Giải phóng controller họ tên
    _nameCtrl.dispose();
    // Giải phóng controller email
    _emailCtrl.dispose();
    // Giải phóng controller mật khẩu
    _passwordCtrl.dispose();
    // Gọi dispose của parent class
    super.dispose();
  }

  // ==================== METHODS ====================

  /// Xử lý đăng ký tài khoản mới
  ///
  /// Hàm này sẽ:
  /// 1. Validate form (kiểm tra các field có hợp lệ không)
  /// 2. Gọi AuthService để tạo tài khoản
  /// 3. Hiển thị EasyLoading khi đang chuyển trang
  /// 4. Hiển thị thông báo thành công hoặc lỗi
  /// 5. AuthGate sẽ tự động chuyển sang HomeScreen nếu đăng ký thành công
  Future<void> _register() async {
    // Validate form trước khi submit
    // Nếu form không hợp lệ thì return (không thực hiện đăng ký)
    if (!_formKey.currentState!.validate()) return;

    // Bắt đầu loading - cập nhật UI
    setState(() {
      _loading = true; // Hiển thị loading indicator
      _error = null; // Xóa thông báo lỗi cũ (nếu có)
    });

    try {
      // Hiển thị EasyLoading với thông báo "Đang tạo tài khoản..."
      EasyLoading.show(
        status: 'Đang tạo tài khoản...',
        maskType: EasyLoadingMaskType.black,
      );

      // Gọi AuthService để đăng ký tài khoản mới
      // trim() để xóa khoảng trắng thừa ở đầu/cuối
      await AuthService().registerWithEmailAndPassword(
        email: _emailCtrl.text.trim(), // Email người dùng
        password:
            _passwordCtrl.text, // Mật khẩu (không trim vì có thể có space)
        name: _nameCtrl.text.trim(), // Họ tên người dùng
      );

      // Đăng ký thành công
      // Dismiss loading indicator
      EasyLoading.dismiss();

      // Hiển thị EasyLoading với thông báo thành công
      EasyLoading.showSuccess(
        'Đăng ký thành công!\nĐang chuyển đến trang chủ...',
        duration: const Duration(seconds: 2),
      );

      // Đợi 1 giây để user đọc thông báo
      await Future.delayed(const Duration(seconds: 1));

      // Lưu ý: KHÔNG cần Navigator.push vì AuthGate sẽ tự động
      // chuyển sang HomeScreen khi phát hiện user đã đăng nhập

      // Kiểm tra xem widget còn mounted (chưa bị dispose) không
      if (mounted) {
        // Hiển thị SnackBar thông báo (optional, vì đã có EasyLoading)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chào mừng bạn đến với ứng dụng!')),
        );
      }
    } catch (e) {
      // Có lỗi xảy ra (email đã tồn tại, password yếu, network error, etc.)

      // Dismiss loading indicator
      EasyLoading.dismiss();

      // Hiển thị thông báo lỗi với EasyLoading
      EasyLoading.showError(
        'Đăng ký thất bại!\n${e.toString()}',
        duration: const Duration(seconds: 3),
      );

      // Cập nhật state để hiển thị thông báo lỗi
      setState(() => _error = e.toString());
    } finally {
      // Kết thúc loading - cập nhật UI
      // Kiểm tra mounted trước khi setState
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // ==================== BUILD UI ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar với tiêu đề "Đăng ký"
      appBar: AppBar(
        title: const Text('Đăng ký'),
        // Tự động hiển thị nút back để quay lại màn hình trước
      ),

      // Body của màn hình
      body: Padding(
        // Padding xung quanh toàn bộ nội dung
        padding: const EdgeInsets.all(16),

        // Form widget để quản lý và validate các TextFormField
        child: Form(
          key: _formKey, // Key để truy cập form state
          // SingleChildScrollView để có thể scroll khi bàn phím hiện lên
          child: SingleChildScrollView(
            child: Column(
              // Căn trái các widget con
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Khoảng trống phía trên
                const SizedBox(height: 20),

                // Logo hoặc icon (optional)
                const Icon(Icons.person_add, size: 80, color: Colors.blue),
                const SizedBox(height: 20),

                // Tiêu đề
                const Text(
                  'Tạo tài khoản mới',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Mô tả
                const Text(
                  'Điền thông tin để đăng ký',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // ==================== FORM FIELDS ====================

                // TextFormField nhập họ tên
                TextFormField(
                  controller: _nameCtrl, // Controller để lấy giá trị
                  decoration: const InputDecoration(
                    labelText: 'Họ tên', // Label hiển thị
                    hintText: 'Nhập họ tên đầy đủ', // Hint text
                    prefixIcon: Icon(Icons.person), // Icon người dùng
                    border: OutlineInputBorder(), // Border xung quanh
                  ),
                  // Validator để kiểm tra input
                  // Trả về String nếu có lỗi, null nếu hợp lệ
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Vui lòng nhập họ tên' : null,
                  enabled: !_loading, // Disable khi đang loading
                ),
                const SizedBox(height: 16),

                // TextFormField nhập email
                TextFormField(
                  controller: _emailCtrl, // Controller để lấy giá trị
                  decoration: const InputDecoration(
                    labelText: 'Email', // Label hiển thị
                    hintText: 'Nhập email của bạn', // Hint text
                    prefixIcon: Icon(Icons.email), // Icon email
                    border: OutlineInputBorder(), // Border xung quanh
                  ),
                  keyboardType: TextInputType.emailAddress, // Bàn phím email
                  // Validator kiểm tra email có chứa @ không
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Email không hợp lệ'
                      : null,
                  enabled: !_loading, // Disable khi đang loading
                ),
                const SizedBox(height: 16),

                // TextFormField nhập mật khẩu
                TextFormField(
                  controller: _passwordCtrl, // Controller để lấy giá trị
                  obscureText: true, // Ẩn text (hiển thị dấu chấm)
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu', // Label hiển thị
                    hintText: 'Nhập mật khẩu', // Hint text
                    prefixIcon: Icon(Icons.lock), // Icon khóa
                    border: OutlineInputBorder(), // Border xung quanh
                  ),
                  // Validator kiểm tra mật khẩu có ít nhất 6 ký tự
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Mật khẩu tối thiểu 6 ký tự'
                      : null,
                  enabled: !_loading, // Disable khi đang loading
                ),
                const SizedBox(height: 20),

                // ==================== THÔNG BÁO LỖI ====================

                // Hiển thị thông báo lỗi nếu có
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                // Khoảng cách
                const SizedBox(height: 16),

                // ==================== NÚT ĐĂNG KÝ ====================

                // Nút đăng ký với chiều rộng full
                SizedBox(
                  width: double.infinity, // Chiều rộng full
                  child: ElevatedButton(
                    // Disable nút khi đang loading, enable khi không loading
                    onPressed: _loading ? null : _register,
                    // Style cho nút
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    // Hiển thị loading indicator hoặc text "Đăng ký"
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Đăng ký', style: TextStyle(fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 16),

                // ==================== NÚT QUAY LẠI ĐĂNG NHẬP ====================

                // Text button để quay lại màn hình đăng nhập
                TextButton(
                  onPressed: _loading
                      ? null // Disable khi đang loading
                      : () {
                          // Pop màn hình hiện tại để quay lại màn hình trước (LoginScreen)
                          Navigator.pop(context);
                        },
                  child: const Text(
                    'Đã có tài khoản? Đăng nhập',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
