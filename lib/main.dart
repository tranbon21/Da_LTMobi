import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart'; // Loading indicators đẹp
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Initialize Firebase here if you need it later
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AuthService().signInAnonymouslyIfNeeded();

  // Cấu hình EasyLoading với màu chủ đạo xanh dương
  configEasyLoading();

  runApp(const MyApp());
}

/// Cấu hình EasyLoading với theme xanh dương
void configEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = AppColors.primary
    ..backgroundColor = Colors.white
    ..indicatorColor = AppColors.primary
    ..textColor = AppColors.textPrimary
    ..maskColor = Colors.black.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      // TODO: Add authentication logic here if needed
      // For now, app starts directly at HomeScreen
      home: const HomeScreen(),
      // Thêm EasyLoading builder để hoạt động globally
      builder: EasyLoading.init(),
    );
  }
}
