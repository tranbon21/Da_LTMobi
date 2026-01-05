// Import thư viện Flutter Material Design
import 'package:flutter/material.dart';
// Import thư viện EasyLoading để hiển thị loading indicators đẹp
import 'package:flutter_easyloading/flutter_easyloading.dart';
// Import các file cấu hình theme, constants, và screens
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'screens/home_screen.dart';
// Import Firebase Core để khởi tạo Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// Import AuthService để quản lý xác thực
import 'services/auth_service.dart';
// Import màn hình đăng nhập
import 'screens/login_screen.dart';
// Import Firebase Auth để lắng nghe trạng thái đăng nhập
import 'package:firebase_auth/firebase_auth.dart';

/// Hàm main - điểm khởi đầu của ứng dụng
///
/// Hàm này sẽ:
/// 1. Khởi tạo Flutter binding
/// 2. Khởi tạo Firebase
/// 3. Cấu hình EasyLoading
/// 4. Chạy ứng dụng
void main() async {
  // Đảm bảo Flutter binding đã được khởi tạo trước khi gọi các hàm async
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase với cấu hình từ firebase_options.dart
  // File này được tạo tự động bởi FlutterFire CLI
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Cấu hình EasyLoading với theme xanh dương
  configEasyLoading();

  // Chạy ứng dụng
  runApp(const MyApp());
}

/// Cấu hình EasyLoading với theme xanh dương
///
/// EasyLoading là thư viện hiển thị loading indicators đẹp
/// Hàm này cấu hình các thuộc tính mặc định cho EasyLoading
void configEasyLoading() {
  EasyLoading.instance
    // Thời gian hiển thị loading (2 giây)
    ..displayDuration = const Duration(milliseconds: 2000)
    // Kiểu indicator: vòng tròn mờ dần
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    // Style tùy chỉnh
    ..loadingStyle = EasyLoadingStyle.custom
    // Kích thước indicator
    ..indicatorSize = 45.0
    // Bo góc của background
    ..radius = 10.0
    // Màu của progress indicator
    ..progressColor = AppColors.primary
    // Màu nền của loading dialog
    ..backgroundColor = Colors.white
    // Màu của indicator
    ..indicatorColor = AppColors.primary
    // Màu chữ
    ..textColor = AppColors.textPrimary
    // Màu của mask (lớp phủ mờ phía sau)
    ..maskColor = Colors.black.withOpacity(0.5)
    // Không cho phép tương tác khi đang loading
    ..userInteractions = false
    // Không tắt loading khi tap vào màn hình
    ..dismissOnTap = false;
}

/// Widget gốc của ứng dụng
///
/// Widget này tạo MaterialApp và cấu hình:
/// - Theme
/// - Home screen (AuthGate)
/// - EasyLoading builder
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Tên ứng dụng
      title: AppStrings.appName,
      // Theme sáng (light theme)
      theme: AppTheme.lightTheme,
      // Tắt banner "Debug" ở góc trên bên phải
      debugShowCheckedModeBanner: false,
      // Màn hình home là AuthGate - widget kiểm tra trạng thái đăng nhập
      home: const AuthGate(),
      // Thêm EasyLoading builder để EasyLoading hoạt động globally trong toàn bộ app
      builder: EasyLoading.init(),
    );
  }
}

/// Widget AuthGate - Cổng xác thực
///
/// Widget này lắng nghe trạng thái đăng nhập của user và:
/// - Nếu chưa đăng nhập (user == null) → Hiển thị LoginScreen
/// - Nếu đã đăng nhập (user != null) → Hiển thị HomeScreen
///
/// Widget này sử dụng StreamBuilder để tự động cập nhật UI
/// khi trạng thái đăng nhập thay đổi
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder lắng nghe stream authStateChanges từ AuthService
    // Stream này sẽ emit giá trị mới mỗi khi trạng thái đăng nhập thay đổi
    return StreamBuilder<User?>(
      // Stream theo dõi trạng thái đăng nhập
      stream: AuthService().authStateChanges,

      // Builder function được gọi mỗi khi stream emit giá trị mới
      builder: (context, snapshot) {
        // Kiểm tra xem stream có đang chờ dữ liệu không
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Hiển thị loading indicator khi đang chờ
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Lấy dữ liệu user từ snapshot
        final user = snapshot.data;

        // Nếu user == null nghĩa là chưa đăng nhập
        if (user == null) {
          // Hiển thị màn hình đăng nhập
          return const LoginScreen();
        }

        // Nếu user != null nghĩa là đã đăng nhập (có thể là guest hoặc user thông thường)
        // Hiển thị màn hình home
        return const HomeScreen();
      },
    );
  }
}
